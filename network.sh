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

OVPN_FILE="$1"
DNS_IP="$2"

if [ ! -f "$OVPN_FILE" ]; then
    echo -e "[!] The provided OpenVPN configuration file does not exist: $OVPN_FILE"
    exit 1
fi

echo -e "[i] Starting the VPN interface using $OVPN_FILE.\n"
sudo nohup openvpn --config "$OVPN_FILE" > /dev/null 2>&1 &
VPN_PID=$!
sleep 5

echo -e "[i] Available Network Connections: \n"
nmcli connection show

read -p "[?] Enter the connection name you want to configure: " CONNECTION_NAME

if ! nmcli connection show "$CONNECTION_NAME" > /dev/null 2>&1; then
    echo -e "[!] The connection '$CONNECTION_NAME' does not exist."
    exit 1
fi

echo -e "[i] Configuring DNS for the connection '$CONNECTION_NAME' with IP $DNS_IP.\n"
sudo nmcli connection modify "$CONNECTION_NAME" ipv4.dns "$DNS_IP 1.1.1.1"
sudo nmcli connection modify "$CONNECTION_NAME" ipv4.ignore-auto-dns yes
sudo nmcli connection up "$CONNECTION_NAME"

echo -e "[i] Testing connection for DNS config: \n"
nmcli dev show "$CONNECTION_NAME" | grep DNS

echo -e "[!] Happy Hacking!"

