CC = gcc
CFLAGS = -Wall -Wextra -O2
LDFLAGS = -lusb-1.0
TARGET = kinect-watchdog

$(TARGET): kinect-watchdog.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

install: $(TARGET)
	install -Dm755 $(TARGET) /usr/local/bin/$(TARGET)
	install -Dm644 kinect-watchdog.service /etc/systemd/system/kinect-watchdog.service
	systemctl daemon-reload

uninstall:
	systemctl disable --now kinect-watchdog.service 2>/dev/null || true
	rm -f /usr/local/bin/$(TARGET)
	rm -f /etc/systemd/system/kinect-watchdog.service
	systemctl daemon-reload

clean:
	rm -f $(TARGET)

.PHONY: install uninstall clean
