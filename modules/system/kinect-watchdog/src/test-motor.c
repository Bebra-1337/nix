/* Test K4W motor/LED protocol via audio device bulk transfers */
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <libusb-1.0/libusb.h>

#define KINECT_VENDOR    0x045e
#define KINECT_AUDIO_K4W 0x02bb

#define K4W_MAGIC        0x06022009
#define K4W_REPLY_MAGIC  0x0a6fe000

typedef struct {
	uint32_t magic;
	uint32_t tag;
	uint32_t arg1;
	uint32_t cmd;
	uint32_t arg2;
} __attribute__((packed)) k4w_cmd;

static int tag_seq = 0;

static int k4w_send(libusb_device_handle *dev, uint32_t cmd, uint32_t arg)
{
	k4w_cmd c = { K4W_MAGIC, tag_seq++, 0, cmd, arg };
	unsigned char buf[512];
	memcpy(buf, &c, 20);
	int transferred = 0;

	int ret = libusb_bulk_transfer(dev, 0x01, buf, 20, &transferred, 500);
	printf("  send: ret=%d transferred=%d\n", ret, transferred);
	if (ret != 0) return ret;

	memset(buf, 0, 512);
	ret = libusb_bulk_transfer(dev, 0x81, buf, 512, &transferred, 500);
	printf("  recv: ret=%d transferred=%d", ret, transferred);
	if (ret == 0 && transferred >= 12) {
		uint32_t magic, tag, status;
		memcpy(&magic, buf, 4);
		memcpy(&tag, buf+4, 4);
		memcpy(&status, buf+8, 4);
		printf(" magic=%08x tag=%u status=%u", magic, tag, status);
	}
	printf("\n");
	return ret;
}

int main(void)
{
	libusb_init(NULL);

	libusb_device_handle *dev = libusb_open_device_with_vid_pid(NULL, KINECT_VENDOR, KINECT_AUDIO_K4W);
	if (!dev) { printf("Audio device not found\n"); return 1; }
	printf("K4W audio device opened\n");

	if (libusb_kernel_driver_active(dev, 0) == 1) {
		printf("Detaching kernel driver...\n");
		libusb_detach_kernel_driver(dev, 0);
	}
	int ret = libusb_claim_interface(dev, 0);
	printf("claim_interface: %d (%s)\n\n", ret, ret < 0 ? libusb_strerror(ret) : "ok");
	if (ret < 0) return 1;

	printf("Setting LED to SOLID RED (cmd=0x10, arg=4):\n");
	k4w_send(dev, 0x10, 4);

	printf("\nSetting tilt to +15 degrees (cmd=0x803b, arg=15):\n");
	k4w_send(dev, 0x803b, 15);

	printf("\nWaiting 3 seconds to observe...\n");
	sleep(3);

	printf("Setting LED to OFF (cmd=0x10, arg=1):\n");
	k4w_send(dev, 0x10, 1);

	printf("\nSetting tilt to 0 (cmd=0x803b, arg=0):\n");
	k4w_send(dev, 0x803b, 0);

	libusb_release_interface(dev, 0);
	libusb_close(dev);
	libusb_exit(NULL);
	return 0;
}
