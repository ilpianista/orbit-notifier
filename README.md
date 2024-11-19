# orbit-notifier

Sends a desktop notification every time orbit [fleetdm](https://fleetdm.com/) performs a distributed query on your host.


## Requirements

1. `notify-send` (on Ubuntu, this is `libnotify-bin`)
1. `truncate` (Optional) (On Ubuntu, this is `coreutils`)

## Install

1. Copy `orbit-notifier.sh` to `/usr/local/bin/orbit-notifier`.
1. Copy `orbit-notifier.service` to `/etc/systemd/user/orbit-notifier.service`.
1. Run `systemctl --user enable --now orbit-notifier`.

## License

MIT
