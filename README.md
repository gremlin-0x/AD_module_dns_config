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

The script will output your active connections, one of which is the VPN you downloaded. Enter the connection name of the VPN, for example:

```
[i] Available Network Connections: 

NAME                UUID                                  TYPE      DEVICE   
Wired connection 1  da0d3c10-0411-4b35-ac3a-8e1dddab43a6  ethernet  eth1     
breachad            e64ca63e-d042-40d7-b5a6-81d432db413f  tun       breachad 
[?] Enter the connection name you want to configure: breachad
```

And you should be up and running. To confirm it, run:

```
nslookup za.tryhackme.com <AD_network_IP>
```

If the address resolves, that's it!
