/*
 * kinect-watchdog - Kinect V1 tilt/LED daemon
 *
 * When the Kinect camera (/dev/video*) is not in use:
 *   - Tilt motor moves to maximum UP (+31 degrees)
 *   - LED is solid RED
 *
 * When an application opens /dev/video*:
 *   - Tilt motor moves to maximum DOWN (-31 degrees)
 *   - LED blinks GREEN
 *
 * For Kinect for Windows (K4W, 045e:02c2), motor and LED are
 * controlled via the audio USB device (045e:02bb) using bulk
 * transfers. Falls back to the classic Xbox 360 protocol
 * (control transfers to 045e:02b0) if K4W audio is not found.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <dirent.h>
#include <syslog.h>
#include <poll.h>
#include <sys/inotify.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <libusb-1.0/libusb.h>

/* USB IDs */
#define KINECT_VENDOR       0x045e
#define KINECT_MOTOR_NUI    0x02b0  /* Xbox 360 Kinect motor */
#define KINECT_MOTOR_K4W    0x02c2  /* K4W motor (USB hub) */
#define KINECT_AUDIO_K4W    0x02bb  /* K4W audio (motor/LED ctrl) */
#define KINECT_CAMERA_NUI   0x02ae  /* Xbox 360 Kinect camera (gspca -> /dev/video*) */
#define KINECT_CAMERA_K4W   0x02bf  /* K4W camera */

/* K4W bulk protocol */
#define K4W_MAGIC           0x06022009
#define K4W_REPLY_MAGIC     0x0a6fe000
#define K4W_CMD_LED         0x10
#define K4W_CMD_TILT        0x803b

/* K4W LED modes */
#define K4W_LED_OFF         1
#define K4W_LED_BLINK_GREEN 2
#define K4W_LED_SOLID_GREEN 3
#define K4W_LED_SOLID_RED   4

/* Xbox 360 classic protocol */
#define NUI_REQ_TYPE        0x40
#define NUI_REQ_LED         0x06
#define NUI_REQ_TILT        0x31

/* Xbox 360 LED modes */
#define NUI_LED_OFF         0
#define NUI_LED_GREEN       1
#define NUI_LED_RED         2
#define NUI_LED_BLINK_GREEN 4

#define POLL_INTERVAL  2   /* seconds: USB liveness / watch re-arm tick */
#define RESCAN_SAFETY  30  /* seconds: forced /proc rescan if no event arrived */
#define OPEN_SETTLE_US 100000 /* IN_OPEN fires before the fd is installed */
#define TILT_UP        31
#define TILT_DOWN     -31

typedef enum {
	MODE_K4W,     /* Kinect for Windows: bulk transfers to audio device */
	MODE_NUI,     /* Xbox 360: control transfers to motor device */
} kinect_mode;

typedef struct {
	libusb_device_handle *dev;
	kinect_mode mode;
	int tag_seq;
	int is_connected;
} kinect_ctx;

static volatile sig_atomic_t running = 1;

static void handle_signal(int sig)
{
	(void)sig;
	running = 0;
}

static void close_kinect(kinect_ctx *kctx)
{
	if (kctx->dev) {
		libusb_release_interface(kctx->dev, 0);
		libusb_close(kctx->dev);
		kctx->dev = NULL;
	}
	kctx->is_connected = 0;
}

/* ---- K4W protocol (bulk transfers to audio device) ---- */

typedef struct {
	uint32_t magic;
	uint32_t tag;
	uint32_t arg1;
	uint32_t cmd;
	uint32_t arg2;
} __attribute__((packed)) k4w_command;

typedef struct {
	uint32_t magic;
	uint32_t tag;
	uint32_t status;
} __attribute__((packed)) k4w_reply;

static int k4w_get_reply(kinect_ctx *kctx)
{
	if (!kctx->dev) return -1;

	unsigned char buf[512];
	int transferred = 0;
	int ret = libusb_bulk_transfer(kctx->dev, 0x81, buf, 512, &transferred, 500);
	if (ret != 0) {
		syslog(LOG_WARNING, "k4w reply failed: %s", libusb_strerror(ret));
		close_kinect(kctx);
		return -1;
	}
	/* Protocol errors desync command/reply pairing: drop the handle so the
	 * main loop reopens the device and reapplies the current state. */
	if (transferred < 12) {
		syslog(LOG_WARNING, "k4w reply too short: %d bytes", transferred);
		close_kinect(kctx);
		return -1;
	}
	k4w_reply reply;
	memcpy(&reply, buf, sizeof(reply));
	if (reply.magic != K4W_REPLY_MAGIC) {
		syslog(LOG_WARNING, "k4w bad reply magic: %08x", reply.magic);
		close_kinect(kctx);
		return -1;
	}
	if (reply.status != 0) {
		syslog(LOG_WARNING, "k4w command failed, status=%u", reply.status);
		return -1;
	}
	return 0;
}

static int k4w_send_cmd(kinect_ctx *kctx, uint32_t cmd, uint32_t arg)
{
	if (!kctx->dev) return -1;

	k4w_command c;
	c.magic = K4W_MAGIC;
	c.tag = kctx->tag_seq++;
	c.arg1 = 0;
	c.cmd = cmd;
	c.arg2 = arg;

	unsigned char buf[20];
	memcpy(buf, &c, 20);

	int transferred = 0;
	int ret = libusb_bulk_transfer(kctx->dev, 0x01, buf, 20, &transferred, 500);
	if (ret != 0) {
		syslog(LOG_WARNING, "k4w send failed: %s", libusb_strerror(ret));
		close_kinect(kctx);
		return -1;
	}
	return k4w_get_reply(kctx);
}

/* ---- Unified motor/LED API ---- */

static int kinect_set_led(kinect_ctx *kctx, int led_on /* 1=red, 2=blink_green, 0=off */)
{
	if (!kctx->dev) return -1;

	if (kctx->mode == MODE_K4W) {
		uint32_t k4w_led;
		switch (led_on) {
		case 1:  k4w_led = K4W_LED_SOLID_RED;   break;
		case 2:  k4w_led = K4W_LED_BLINK_GREEN; break;
		default: k4w_led = K4W_LED_OFF;          break;
		}
		return k4w_send_cmd(kctx, K4W_CMD_LED, k4w_led);
	} else {
		uint16_t nui_led;
		switch (led_on) {
		case 1:  nui_led = NUI_LED_RED;         break;
		case 2:  nui_led = NUI_LED_BLINK_GREEN; break;
		default: nui_led = NUI_LED_OFF;          break;
		}
		int ret = libusb_control_transfer(kctx->dev, NUI_REQ_TYPE, NUI_REQ_LED,
		                                  nui_led, 0, NULL, 0, 1000);
		if (ret < 0) {
			syslog(LOG_WARNING, "nui set_led failed: %s", libusb_strerror(ret));
			close_kinect(kctx);
			return -1;
		}
		return 0;
	}
}

static int kinect_set_tilt(kinect_ctx *kctx, int angle_degs)
{
	if (!kctx->dev) return -1;

	if (angle_degs > 31) angle_degs = 31;
	if (angle_degs < -31) angle_degs = -31;

	if (kctx->mode == MODE_K4W) {
		return k4w_send_cmd(kctx, K4W_CMD_TILT, (uint32_t)(int32_t)angle_degs);
	} else {
		int16_t val = (int16_t)(angle_degs * 2);
		int ret = libusb_control_transfer(kctx->dev, NUI_REQ_TYPE, NUI_REQ_TILT,
		                                  (uint16_t)val, 0, NULL, 0, 1000);
		if (ret < 0) {
			syslog(LOG_WARNING, "nui set_tilt failed: %s", libusb_strerror(ret));
			close_kinect(kctx);
			return -1;
		}
		return 0;
	}
}

/*
 * Verify the USB handle is still valid. While idle we send nothing, so an
 * unplug or re-enumeration (e.g. firmware reload) would otherwise go
 * unnoticed. GET_STATUS fails with NO_DEVICE once the device is gone.
 */
static int kinect_alive(kinect_ctx *kctx)
{
	unsigned char status[2];
	int ret = libusb_control_transfer(kctx->dev, 0x80, 0x00, 0, 0,
	                                  status, sizeof(status), 500);
	if (ret < 0) {
		syslog(LOG_WARNING, "kinect lost: %s", libusb_strerror(ret));
		close_kinect(kctx);
		return 0;
	}
	return 1;
}

#define MAX_KINECT_NODES 8

typedef struct {
	dev_t rdev;
	char path[280]; /* /dev/videoN */
} kinect_node;

/*
 * Collect the Kinect's own V4L2 nodes by walking /sys/class/video4linux/video*:
 * the "device" link leads to the USB interface, whose parent holds
 * idVendor/idProduct.
 */
static int find_kinect_video_nodes(kinect_node *nodes, int max)
{
	DIR *d = opendir("/sys/class/video4linux");
	if (!d)
		return 0;

	int n = 0;
	struct dirent *e;
	while (n < max && (e = readdir(d)) != NULL) {
		if (strncmp(e->d_name, "video", 5) != 0)
			continue;

		char path[512], buf[32];
		unsigned vid = 0, pid = 0;
		unsigned maj, min;
		FILE *f;

		snprintf(path, sizeof(path),
		         "/sys/class/video4linux/%s/device/../idVendor", e->d_name);
		if (!(f = fopen(path, "r")))
			continue;
		if (fgets(buf, sizeof(buf), f))
			vid = strtoul(buf, NULL, 16);
		fclose(f);

		snprintf(path, sizeof(path),
		         "/sys/class/video4linux/%s/device/../idProduct", e->d_name);
		if (!(f = fopen(path, "r")))
			continue;
		if (fgets(buf, sizeof(buf), f))
			pid = strtoul(buf, NULL, 16);
		fclose(f);

		if (vid != KINECT_VENDOR ||
		    (pid != KINECT_CAMERA_NUI && pid != KINECT_CAMERA_K4W))
			continue;

		snprintf(path, sizeof(path),
		         "/sys/class/video4linux/%s/dev", e->d_name);
		if (!(f = fopen(path, "r")))
			continue;
		if (fscanf(f, "%u:%u", &maj, &min) == 2) {
			nodes[n].rdev = makedev(maj, min);
			snprintf(nodes[n].path, sizeof(nodes[n].path), "/dev/%s", e->d_name);
			n++;
		}
		fclose(f);
	}
	closedir(d);
	return n;
}

/*
 * Check if the Kinect's V4L2 node is opened by any process.
 * Scans /proc/<pid>/fd/ for character devices matching the Kinect's
 * device numbers; other cameras are ignored.
 */
static int is_camera_in_use(void)
{
	kinect_node nodes[MAX_KINECT_NODES];
	int n_nodes = find_kinect_video_nodes(nodes, MAX_KINECT_NODES);
	if (n_nodes == 0)
		return 0;

	DIR *proc_dir = opendir("/proc");
	if (!proc_dir)
		return 0;

	pid_t my_pid = getpid();
	struct dirent *pid_entry;
	char fd_dir_path[256];

	while ((pid_entry = readdir(proc_dir)) != NULL) {
		char *endp;
		long pid = strtol(pid_entry->d_name, &endp, 10);
		if (*endp != '\0' || pid <= 0)
			continue;

		if ((pid_t)pid == my_pid)
			continue;

		snprintf(fd_dir_path, sizeof(fd_dir_path), "/proc/%ld/fd", pid);
		DIR *fd_dir = opendir(fd_dir_path);
		if (!fd_dir)
			continue;

		struct dirent *fd_entry;
		while ((fd_entry = readdir(fd_dir)) != NULL) {
			char fd_path[512];
			snprintf(fd_path, sizeof(fd_path), "%s/%s", fd_dir_path, fd_entry->d_name);

			struct stat fd_stat;
			if (stat(fd_path, &fd_stat) != 0 || !S_ISCHR(fd_stat.st_mode))
				continue;
			for (int i = 0; i < n_nodes; i++) {
				if (fd_stat.st_rdev == nodes[i].rdev) {
					closedir(fd_dir);
					closedir(proc_dir);
					return 1;
				}
			}
		}
		closedir(fd_dir);
	}

	closedir(proc_dir);
	return 0;
}

/*
 * inotify watches on the Kinect's /dev/videoN nodes. IN_OPEN / IN_CLOSE_*
 * tell us when something touches the camera, so the expensive /proc scan
 * only runs on demand instead of on a timer.
 */
typedef struct {
	int fd;
	int n;
	dev_t rdev[MAX_KINECT_NODES];
	int wd[MAX_KINECT_NODES];  /* -1 = not armed yet (node not created) */
} cam_watch;

static void watch_clear(cam_watch *w)
{
	for (int i = 0; i < w->n; i++)
		if (w->wd[i] >= 0)
			inotify_rm_watch(w->fd, w->wd[i]);
	w->n = 0;
}

/*
 * Re-sync watches with the current set of Kinect nodes (they vanish and
 * reappear on replug). Returns 1 if the set changed or a watch was newly
 * armed, meaning the caller should rescan.
 */
static int watch_sync(cam_watch *w)
{
	kinect_node nodes[MAX_KINECT_NODES];
	int n = find_kinect_video_nodes(nodes, MAX_KINECT_NODES);
	int changed = 0;

	int same = (n == w->n);
	for (int i = 0; same && i < n; i++)
		if (nodes[i].rdev != w->rdev[i])
			same = 0;

	if (!same) {
		watch_clear(w);
		for (int i = 0; i < n; i++) {
			w->rdev[i] = nodes[i].rdev;
			w->wd[i] = -1;
		}
		w->n = n;
		changed = 1;
	}

	for (int i = 0; i < w->n; i++) {
		if (w->wd[i] >= 0)
			continue;
		int wd = inotify_add_watch(w->fd, nodes[i].path,
		                           IN_OPEN | IN_CLOSE_WRITE | IN_CLOSE_NOWRITE);
		if (wd >= 0) {
			w->wd[i] = wd;
			changed = 1;
		}
	}
	return changed;
}

/*
 * Drain queued events and update the holder count. Every open of a struct
 * file yields exactly one IN_OPEN and, on final release, one IN_CLOSE_*, so
 * opens minus closes is the number of live openers of the node - no /proc
 * scan needed. Returns 1 if the count can no longer be trusted (queue
 * overflow or a watch was dropped) and must be resynced by a scan.
 */
static int watch_drain(cam_watch *w, int *holders)
{
	char buf[4096] __attribute__((aligned(__alignof__(struct inotify_event))));
	int untrusted = 0;
	ssize_t len;

	while ((len = read(w->fd, buf, sizeof(buf))) > 0) {
		for (char *p = buf; p < buf + len; ) {
			struct inotify_event *ev = (struct inotify_event *)p;
			if (ev->mask & IN_OPEN)
				(*holders)++;
			if (ev->mask & (IN_CLOSE_WRITE | IN_CLOSE_NOWRITE))
				(*holders)--;
			if (ev->mask & (IN_Q_OVERFLOW | IN_IGNORED))
				untrusted = 1;
			p += sizeof(*ev) + ev->len;
		}
	}
	if (*holders < 0)
		*holders = 0;
	return untrusted;
}

static int open_kinect(kinect_ctx *kctx)
{
	kctx->tag_seq = 0;
	kctx->dev = NULL;
	kctx->is_connected = 0;

	/* Try K4W first: motor/LED via audio device */
	kctx->dev = libusb_open_device_with_vid_pid(NULL, KINECT_VENDOR, KINECT_AUDIO_K4W);
	if (kctx->dev) {
		if (libusb_kernel_driver_active(kctx->dev, 0) == 1)
			libusb_detach_kernel_driver(kctx->dev, 0);
		int ret = libusb_claim_interface(kctx->dev, 0);
		if (ret < 0) {
			syslog(LOG_ERR, "K4W claim interface failed: %s", libusb_strerror(ret));
			libusb_close(kctx->dev);
			kctx->dev = NULL;
		} else {
			kctx->mode = MODE_K4W;
			kctx->is_connected = 1;
			syslog(LOG_INFO, "opened K4W audio device for motor/LED control");
			return 0;
		}
	}

	/* Fallback: Xbox 360 Kinect motor device */
	kctx->dev = libusb_open_device_with_vid_pid(NULL, KINECT_VENDOR, KINECT_MOTOR_NUI);
	if (kctx->dev) {
		if (libusb_kernel_driver_active(kctx->dev, 0) == 1)
			libusb_detach_kernel_driver(kctx->dev, 0);
		int ret = libusb_claim_interface(kctx->dev, 0);
		if (ret < 0) {
			syslog(LOG_ERR, "NUI claim interface failed: %s", libusb_strerror(ret));
			libusb_close(kctx->dev);
			kctx->dev = NULL;
		} else {
			kctx->mode = MODE_NUI;
			kctx->is_connected = 1;
			syslog(LOG_INFO, "opened Xbox 360 motor device for motor/LED control");
			return 0;
		}
	}

	return -1;
}

int main(void)
{
	struct sigaction sa;
	sa.sa_handler = handle_signal;
	sa.sa_flags = 0;
	sigemptyset(&sa.sa_mask);
	sigaction(SIGTERM, &sa, NULL);
	sigaction(SIGINT, &sa, NULL);

	openlog("kinect-watchdog", LOG_PID | LOG_CONS, LOG_DAEMON);
	syslog(LOG_INFO, "starting");

	int ret = libusb_init(NULL);
	if (ret < 0) {
		syslog(LOG_ERR, "libusb_init failed: %s", libusb_strerror(ret));
		closelog();
		return 1;
	}

	kinect_ctx kctx;
	memset(&kctx, 0, sizeof(kctx));

	if (open_kinect(&kctx) == 0) {
		/* Initial state: tilt UP, LED RED */
		kinect_set_tilt(&kctx, TILT_UP);
		kinect_set_led(&kctx, 1);  /* 1 = red */
		syslog(LOG_INFO, "idle: tilt UP, LED RED");
	} else {
		syslog(LOG_WARNING, "Kinect device not initially found, waiting for device...");
	}

	int in_use = -1; /* force update on first iteration */

	cam_watch watch;
	memset(&watch, 0, sizeof(watch));
	watch.fd = inotify_init1(IN_NONBLOCK | IN_CLOEXEC);
	if (watch.fd < 0)
		syslog(LOG_ERR, "inotify_init failed, falling back to timed rescans");

	int need_scan = 1;   /* full /proc scan required to (re)establish truth */
	int holders = 0;     /* opens - closes since watches were armed */
	int idle_ticks = 0;

	while (running) {
		/* Detect unplug/re-enumeration even when idle */
		if (kctx.is_connected)
			kinect_alive(&kctx);

		/* Attempt reconnect if device was lost */
		if (!kctx.is_connected) {
			if (open_kinect(&kctx) == 0) {
				in_use = -1; /* trigger state refresh */
				need_scan = 1;
			}
		}

		if (watch.fd >= 0 && watch_sync(&watch)) {
			holders = 0;  /* count restarts with the new watches */
			need_scan = 1;
		}

		/* Without inotify, or as a safety net, rescan periodically */
		if (watch.fd < 0 || idle_ticks * POLL_INTERVAL >= RESCAN_SAFETY)
			need_scan = 1;

		int target = holders > 0;

		/* Count says free: confirm before releasing, the count may have drifted */
		if (in_use == 1 && !target)
			need_scan = 1;

		if (need_scan) {
			need_scan = 0;
			idle_ticks = 0;
			target = is_camera_in_use();
			if (target && holders == 0)
				holders = 1;  /* held by someone we did not see open it */
			if (!target)
				holders = 0;
		}

		if (target != in_use) {
			in_use = target;
			if (in_use) {
				if (kctx.is_connected) {
					kinect_set_tilt(&kctx, TILT_DOWN);
					kinect_set_led(&kctx, 2);  /* 2 = blink green */
				}
				syslog(LOG_INFO, "camera in use: tilt DOWN, LED BLINK GREEN");
			} else {
				if (kctx.is_connected) {
					kinect_set_tilt(&kctx, TILT_UP);
					kinect_set_led(&kctx, 1);  /* 1 = red */
				}
				syslog(LOG_INFO, "camera idle: tilt UP, LED RED");
			}
		}

		if (watch.fd >= 0) {
			struct pollfd pfd = { .fd = watch.fd, .events = POLLIN };
			int pr = poll(&pfd, 1, POLL_INTERVAL * 1000);
			if (pr > 0) {
				/* Coalesce bursts: brief probes that open and close within
				 * the settle window never change the state. */
				usleep(OPEN_SETTLE_US);
				if (watch_drain(&watch, &holders))
					need_scan = 1;
			} else {
				idle_ticks++;
			}
		} else {
			sleep(POLL_INTERVAL);
		}
	}

	if (watch.fd >= 0) {
		watch_clear(&watch);
		close(watch.fd);
	}

	/* Clean shutdown: neutral tilt (0 deg), LED off */
	syslog(LOG_INFO, "shutting down, resetting tilt to 0 and turning off LED");
	if (!kctx.is_connected) {
		open_kinect(&kctx);
	}
	if (kctx.is_connected) {
		kinect_set_tilt(&kctx, 0);
		kinect_set_led(&kctx, 0);  /* 0 = off */
		usleep(200000);
		kinect_set_tilt(&kctx, 0); /* retry once to guarantee command arrival */
		sleep(2);                 /* wait 2 full seconds for physical motor to finish turning to 0° */
		close_kinect(&kctx);
	}

	libusb_exit(NULL);

	syslog(LOG_INFO, "stopped");
	closelog();
	return 0;
}
