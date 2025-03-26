.PHONY: install uninstall configure-system

PREFIX ?= /usr/local
SERVICEDIR ?= /etc/systemd/user
ORBIT_OVERRIDE_DIR = /etc/systemd/system/orbit.service.d
ORBIT_OVERRIDE_FILE = $(ORBIT_OVERRIDE_DIR)/override.conf

install:
	install -Dm755 orbit-notifier.sh $(DESTDIR)$(PREFIX)/bin/orbit-notifier
	install -Dm644 orbit-notifier.service $(DESTDIR)$(SERVICEDIR)/orbit-notifier.service
	@echo "Installation complete. To enable and start the service, run:"
	@echo "systemctl --user enable --now orbit-notifier"

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/orbit-notifier
	rm -f $(DESTDIR)$(SERVICEDIR)/orbit-notifier.service
	@echo "Uninstallation complete. To disable and stop the service, run:"
	@echo "systemctl --user disable --now orbit-notifier"

configure-system:
	@echo "Configuring system-level orbit service (requires sudo)..."
	@if [ "$$(id -u)" != "0" ]; then \
		echo "This target must be run as root (use sudo make configure-system)"; \
		exit 1; \
	fi
	mkdir -p $(ORBIT_OVERRIDE_DIR)
	@echo "[Service]" > $(ORBIT_OVERRIDE_FILE)
	@echo "Environment=ORBIT_DEBUG=true" >> $(ORBIT_OVERRIDE_FILE)
	@echo "Environment=ORBIT_LOG_FILE=/var/log/orbit/orbit.log" >> $(ORBIT_OVERRIDE_FILE)
	systemctl daemon-reload
	systemctl restart orbit
	@echo "System-level configuration complete"

all: configure-system install
