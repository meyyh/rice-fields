#!/bin/bash

if [ -z "${waybar_network}" ]; then
    export waybar_network=1
fi

rx_bytes() {
    # in MB
    rx_bytes=$(echo "$(cat /sys/class/net/wlp1s0/statistics/rx_bytes) / 1024 / 1024" | bc)
    unit="MB"
    if (( $(echo "$rx_bytes > 1024" | bc -l) )); then
        # in GB x.xx
        rx_bytes=$(echo "scale=2; $rx_bytes / 1024" | bc)
        unit="GB"
    fi

    echo "$rx_bytes $unit"
}

tx_bytes() {
    # in MB
    tx_bytes=$(echo "$(cat /sys/class/net/wlp1s0/statistics/tx_bytes) / 1024 / 1024" | bc)
    unit="MB"
    if (( $(echo "$tx_bytes > 1024" | bc -l) )); then
        # in GB x.xx
        tx_bytes=$(echo "scale=2; $tx_bytes / 1024" | bc)
        unit="GB"
    fi

    echo "$tx_bytes $unit"
}

get_ip() {
    ip address show wlp1s0 | grep -oP '(?<=inet\s)[0-9./]+'
}

current_wifi=$(nmcli | grep -oP '(?<=wlp1s0: connected to ).{1,32}')

printf '{"text": "%s", "alt": "%s", "tooltip": "%s"}' "$current_wifi" "$(get_ip)" " $(rx_bytes) | $(tx_bytes) "
