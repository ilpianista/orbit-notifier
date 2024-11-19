# orbit-notifier

Sends a desktop notification every time orbit [fleetdm](https://fleetdm.com/) performs a distributed query on your host.


## Requirements

1. `notify-send` (on Ubuntu, this is `libnotify-bin`)

## Install

1. Copy `orbit-notifier.sh` to `/usr/local/bin/orbit-notifier`.
1. Copy `orbit-notifier.service` to `/etc/systemd/user/orbit-notifier.service`.
1. Run `systemctl --user enable --now orbit-notifier`.

## Good to know

Due to debug output, the `/var/log/orbit/orbit.log` file can grows to several megabytes after few months. Consider to run `truncate -s 50M /var/log/orbit/orbit.log` from time to time.

## License

MIT
