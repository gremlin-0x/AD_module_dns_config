# DNS Configuration Script for Active Directory Module in TryHackMe!

## Usage:

After you download the relevant VPN configuration file from TryHackMe [Access Page](https://tryhackme.com/access) under the Networks tab, you will need the following credentials:

- IP of the AD Network in a given room (e.g: `10.200.x.x`)
- Local path to the `.ovpn` configuration file you downloaded

Having those creds, execute the script:

```
chmod +x network.sh
./network.sh <path_to_ovpn_file> <AD_network_IP>
```

The script will automatically find the active connection and add this DNS to its route:

```
└─$ ./network.sh breachingad.ovpn 10.200.9.101
[i] Checking sudo privileges...

[i] Starting the VPN interface using breachingad.ovpn.

[i] Waiting for VPN interface to be assigned...

[i] Detected VPN Connection Name: breachad
[i] VPN assigned IP: 10.50.8.21
[i] Configuring DNS for the connection 'breachad' with IP 10.200.9.101.

Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/14)
[i] Adding route via DNS IP (10.200.9.101) on interface breachad.
[i] Testing connection for DNS config: 

IP4.DNS[1]:                             10.200.9.101
IP4.DNS[2]:                             1.1.1.1
[!] Happy Hacking!
```

And you should be up and running. To confirm it, run:

```
nslookup za.tryhackme.com <AD_network_IP>
```

If the address resolves, that's it!
