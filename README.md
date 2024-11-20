# orbit-notifier

Sends a desktop notification every time orbit [fleetdm](https://fleetdm.com/) performs a distributed query on your host.


## Requirements

1. `notify-send` (on Ubuntu, this is `libnotify-bin`)

## Orbit setup

This script inspect orbit log file which isn't write by default. Thus we need to enable it this way:

```sh
sudo mkdir -p /etc/systemd/system/orbit.service.d
sudo bash -c 'cat <<EOF >$SYSTEMD_ORBIT_OVERRIDE
[Service]
Environment=ORBIT_DEBUG=true
Environment=ORBIT_LOG_FILE=/var/log/orbit/orbit.log
EOF'
sudo systemctl daemon-reload
sudo systemctl restart orbit
```

## Install

1. Copy `orbit-notifier.sh` to `/usr/local/bin/orbit-notifier`.
1. Copy `orbit-notifier.service` to `/etc/systemd/user/orbit-notifier.service`.
1. Run `systemctl --user enable --now orbit-notifier`.

## Good to know

Due to debug output, the `/var/log/orbit/orbit.log` file can grows to several megabytes after few months. Consider to run `truncate -s 50M /var/log/orbit/orbit.log` from time to time.

## License

MIT
