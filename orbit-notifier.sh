#!/usr/bin/env bash

# Turn off glob expansion for SELECT * queries
set -f

# /etc/default/orbit gets overwritten by updates
SYSTEMD_ORBIT_OVERRIDE=/etc/systemd/system/orbit.service.d/override.conf

ORBIT_LOG_FILE=/var/log/orbit/orbit.log

NOTIFICATION_TITLE="Fleet query"

TRUNCATE_SIZE=50M

help() {
    echo "Usage: $0 [--truncate] [--notification-timeout N]"
    echo ""
    echo "Options:"
    echo "  --skip-check               Skip the orbit service inspection."
    echo "  --truncate                 Truncates the log file to $TRUNCATE_SIZE. Requires sudo."
    echo "  --notification-timeout N   Timeout, in ms, for the notification before it expires."
    exit
}

function configure() {
    echo "It looks like orbit isn't configured to logs queries."
    echo "Execute the following commands and restart this script:"
    echo
    echo "sudo mkdir -p /etc/systemd/system/orbit.service.d"
    echo "sudo bash -c 'cat <<EOF >$SYSTEMD_ORBIT_OVERRIDE
[Service]
Environment=ORBIT_DEBUG=true
Environment=ORBIT_LOG_FILE=/var/log/orbit/orbit.log
EOF'"
    echo "sudo systemctl daemon-reload"
    echo "sudo systemctl restart orbit"
    exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-check)
            SKIP_CHECK=1
            shift 1
            ;;
        --truncate)
            TRUNCATE=1
            shift 1
            ;;
        --notification-timeout)
            timeout="$2"
            shift 2
            ;;
        --help)
            help
            ;;
    esac
done

if [[ -n $timeout ]]; then
    NOTIFICATION_TIMEOUT="$timeout"
else
    NOTIFICATION_TIMEOUT=15000
fi

if [[ $SKIP_CHECK -ne 1 ]]; then
    if [[ ! -f $SYSTEMD_ORBIT_OVERRIDE ]]; then
        configure
    fi
    if ! grep -q ^Environment=ORBIT_DEBUG=true$ $SYSTEMD_ORBIT_OVERRIDE; then
        configure
    fi
    if ! grep -q ^Environment=ORBIT_LOG_FILE=/var/log/orbit/orbit.log$ $SYSTEMD_ORBIT_OVERRIDE; then
        configure
    fi
fi

if [[ ! -r $ORBIT_LOG_FILE ]]; then
    echo "$ORBIT_LOG_FILE isn't readable. I'm refusing to start!"
    exit 1
fi

if [[ $TRUNCATE -eq 1 ]]; then
    sudo truncate -s $TRUNCATE_SIZE "$ORBIT_LOG_FILE"
fi

tail -n0 -F "$ORBIT_LOG_FILE" | awk '/I.*/{d=0; if($0 ~ "Executing distributed query")d=1}d; fflush()' | \
    while read -r q; do \
        query="$q"
        while read -r -t 0.1 line; do
            query="$query"$'\n'"$line"
        done
        notify-send -t "$NOTIFICATION_TIMEOUT" "$NOTIFICATION_TITLE" "$(echo $query | sed 's/^.*fleet_distributed_query_[^:]*: //')"
    done
