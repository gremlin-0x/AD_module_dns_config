#!/bin/bash

print_usage() {
    echo -e "Usage: $0 <path_to_ovpn_file> <dns_ip>"
    echo -e "  <path_to_ovpn_file> : Path to the OpenVPN configuration file (.ovpn)"
    echo -e "  <dns_ip>            : DNS IP address to configure"
    exit 1
}

if [ $# -ne 2 ]; then
    print_usage
fi

echo -e "[i] Checking sudo privileges...\n"
sudo -v || { echo "[!] Sudo privileges required. Exiting."; exit 1; }

OVPN_FILE="$1"
DNS_IP="$2"

if [ ! -f "$OVPN_FILE" ]; then
    echo -e "[!] OpenVPN configuration file does not exist: $OVPN_FILE"
    exit 1
fi

# Get active connections BEFORE VPN starts
ACTIVE_BEFORE=$(nmcli connection show --active | awk 'NR>1 {print $1}')

echo -e "[i] Starting the VPN interface using $OVPN_FILE.\n"
sudo nohup openvpn --config "$OVPN_FILE" > /dev/null 2>&1 &
VPN_PID=$!

# Wait for a new VPN interface to appear
echo -e "[i] Waiting for VPN interface to be assigned...\n"
MAX_WAIT=15
WAIT_TIME=0

while true; do
    ACTIVE_AFTER=$(nmcli connection show --active | awk 'NR>1 {print $1}')
    NEW_CONNECTION=$(comm -13 <(echo "$ACTIVE_BEFORE" | sort) <(echo "$ACTIVE_AFTER" | sort))

    if [[ -n "$NEW_CONNECTION" ]]; then
        CONNECTION_NAME="$NEW_CONNECTION"
        break
    fi

    sleep 1
    ((WAIT_TIME++))

    if [ $WAIT_TIME -ge $MAX_WAIT ]; then
        echo -e "[!] VPN did not establish in time. Exiting."
        exit 1
    fi
done

echo -e "[i] Detected VPN Connection Name: $CONNECTION_NAME"

VPN_IP=$(ip -4 addr show dev "$CONNECTION_NAME" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [ -z "$VPN_IP" ]; then
    echo -e "[!] Failed to retrieve VPN IP. Exiting."
    exit 1
fi

echo -e "[i] VPN assigned IP: $VPN_IP"

echo -e "[i] Configuring DNS for the connection '$CONNECTION_NAME' with IP $DNS_IP.\n"
sudo nmcli connection modify "$CONNECTION_NAME" ipv4.dns "$DNS_IP 1.1.1.1"
sudo nmcli connection modify "$CONNECTION_NAME" ipv4.ignore-auto-dns yes
sudo nmcli connection up "$CONNECTION_NAME"

echo -e "[i] Adding route via DNS IP ($DNS_IP) on interface $CONNECTION_NAME."
sudo ip route add $DNS_IP dev $CONNECTION_NAME

echo -e "[i] Testing connection for DNS config: \n"
nmcli dev show "$CONNECTION_NAME" | grep DNS

echo -e "[!] Happy Hacking!"
