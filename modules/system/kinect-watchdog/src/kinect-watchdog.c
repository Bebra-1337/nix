/*
 * kinect-watchdog - Kinect V1 tilt/LED daemon
 *
 * When the Kinect camera (/dev/video0) is not in use:
 *   - Tilt motor moves to maximum UP (+31 degrees)
 *   - LED is solid RED
 *
 * When an application opens /dev/video0:
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
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <dirent.h>
#include <syslog.h>
#include <sys/stat.h>
#include <libusb-1.0/libusb.h>

/* USB IDs */
#define KINECT_VENDOR       0x045e
#define KINECT_MOTOR_NUI    0x02b0  /* Xbox 360 Kinect motor */
#define KINECT_MOTOR_K4W    0x02c2  /* K4W motor (USB hub) */
#define KINECT_AUDIO_K4W    0x02bb  /* K4W audio (motor/LED ctrl) */

/* K4W bulk protocol */
#define K4W_MAGIC           0x06022009
#define K4W_REPLY_MAGIC     0x0a6fe000
#define K4W_CMD_LED         0x10
#define K4W_CMD_TILT        0x803b

/* K4W LED modes (different from Xbox 360!) */
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

#define VIDEO_DEV      "/dev/video0"
#define POLL_INTERVAL  2  /* seconds */
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
} kinect_ctx;

static volatile sig_atomic_t running = 1;

static void handle_signal(int sig)
{
	(void)sig;
	running = 0;
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
	unsigned char buf[512];
	int transferred = 0;
	int ret = libusb_bulk_transfer(kctx->dev, 0x81, buf, 512, &transferred, 500);
	if (ret != 0) {
		syslog(LOG_WARNING, "k4w reply failed: %s", libusb_strerror(ret));
		return -1;
	}
	if (transferred < 12) {
		syslog(LOG_WARNING, "k4w reply too short: %d bytes", transferred);
		return -1;
	}
	k4w_reply reply;
	memcpy(&reply, buf, sizeof(reply));
	if (reply.magic != K4W_REPLY_MAGIC) {
		syslog(LOG_WARNING, "k4w bad reply magic: %08x", reply.magic);
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
		return -1;
	}
	return k4w_get_reply(kctx);
}

/* ---- Unified motor/LED API ---- */

static int kinect_set_led(kinect_ctx *kctx, int led_on /* 1=red, 2=blink_green, 0=off */)
{
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
		return libusb_control_transfer(kctx->dev, NUI_REQ_TYPE, NUI_REQ_LED,
		                               nui_led, 0, NULL, 0, 1000);
	}
}

static int kinect_set_tilt(kinect_ctx *kctx, int angle_degs)
{
	if (angle_degs > 31) angle_degs = 31;
	if (angle_degs < -31) angle_degs = -31;

	if (kctx->mode == MODE_K4W) {
		return k4w_send_cmd(kctx, K4W_CMD_TILT, (uint32_t)(int32_t)angle_degs);
	} else {
		int16_t val = (int16_t)(angle_degs * 2);
		return libusb_control_transfer(kctx->dev, NUI_REQ_TYPE, NUI_REQ_TILT,
		                               (uint16_t)val, 0, NULL, 0, 1000);
	}
}

/*
 * Check if /dev/video0 is opened by any process.
 * Scans /proc/<pid>/fd/ for symlinks pointing to the video device.
 */
static int is_camera_in_use(void)
{
	DIR *proc_dir = opendir("/proc");
	if (!proc_dir)
		return 0;

	pid_t my_pid = getpid();
	struct dirent *pid_entry;
	char fd_dir_path[256];
	char link_target[256];
	struct stat video_stat;

	if (stat(VIDEO_DEV, &video_stat) < 0)
		goto not_in_use;

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

			ssize_t len = readlink(fd_path, link_target, sizeof(link_target) - 1);
			if (len < 0)
				continue;
			link_target[len] = '\0';

			if (strcmp(link_target, VIDEO_DEV) == 0) {
				closedir(fd_dir);
				closedir(proc_dir);
				return 1;
			}

			struct stat fd_stat;
			if (stat(fd_path, &fd_stat) == 0 &&
			    S_ISCHR(fd_stat.st_mode) &&
			    fd_stat.st_rdev == video_stat.st_rdev) {
				closedir(fd_dir);
				closedir(proc_dir);
				return 1;
			}
		}
		closedir(fd_dir);
	}

not_in_use:
	closedir(proc_dir);
	return 0;
}

static int open_kinect(kinect_ctx *kctx)
{
	kctx->tag_seq = 0;

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
	if (open_kinect(&kctx) < 0) {
		syslog(LOG_ERR, "no Kinect motor device found");
		libusb_exit(NULL);
		closelog();
		return 1;
	}

	/* Start in idle state: tilt up, LED red */
	int in_use = 0;
	kinect_set_tilt(&kctx, TILT_UP);
	kinect_set_led(&kctx, 1);  /* 1 = red */
	syslog(LOG_INFO, "idle: tilt UP, LED RED");

	while (running) {
		int now_in_use = is_camera_in_use();

		if (now_in_use != in_use) {
			in_use = now_in_use;
			if (in_use) {
				kinect_set_tilt(&kctx, TILT_DOWN);
				kinect_set_led(&kctx, 2);  /* 2 = blink green */
				syslog(LOG_INFO, "camera in use: tilt DOWN, LED BLINK GREEN");
			} else {
				kinect_set_tilt(&kctx, TILT_UP);
				kinect_set_led(&kctx, 1);  /* 1 = red */
				syslog(LOG_INFO, "camera idle: tilt UP, LED RED");
			}
		}

		sleep(POLL_INTERVAL);
	}

	/* Clean shutdown: neutral tilt, LED off */
	syslog(LOG_INFO, "shutting down, resetting tilt and LED");
	kinect_set_tilt(&kctx, 0);
	kinect_set_led(&kctx, 0);  /* 0 = off */
	sleep(1);

	libusb_release_interface(kctx.dev, 0);
	libusb_close(kctx.dev);
	libusb_exit(NULL);

	syslog(LOG_INFO, "stopped");
	closelog();
	return 0;
}
