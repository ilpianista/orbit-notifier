#!/bin/bash

# Turn off glob expansion for SELECT * queries
set -f

NOTIFICATION_TITLE="Fleet query"
NOTIFICATION_TIMEOUT="5000" # milliseconds

# /etc/default/orbit gets overwritten by updates
SYSTEMD_ORBIT_OVERRIDE=/etc/systemd/system/orbit.service.d/override.conf

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

if [[ ! -f $SYSTEMD_ORBIT_OVERRIDE ]]; then
    configure
fi
if ! grep -q ^Environment=ORBIT_DEBUG=true$ $SYSTEMD_ORBIT_OVERRIDE; then
    configure
fi
if ! grep -q ^Environment=ORBIT_LOG_FILE=/var/log/orbit/orbit.log$ $SYSTEMD_ORBIT_OVERRIDE; then
    configure
fi

if [[ ! -r $ORBIT_LOG_FILE ]]; then
    echo "$ORBIT_LOG_FILE isn't readable. I'm refusing to start!"
    exit 1
fi

tail -n0 -F $ORBIT_LOG_FILE | awk '/I.*/{d=0; if($0 ~ "Executing distributed query")d=1}d; fflush()' | \
    while read -r q; do \
        query="$q"
        while read -r -t 0.1 line; do
            query="$query"$'\n'"$line"
        done
        notify-send -t $NOTIFICATION_TIMEOUT "$NOTIFICATION_TITLE" "$(echo $query | sed 's/^.*fleet_distributed_query_[^:]*: //')"
    done
