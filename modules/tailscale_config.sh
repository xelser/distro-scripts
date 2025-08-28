#!/bin/bash

# IP Forwarding (https://tailscale.com/kb/1019/subnets#enable-ip-forwarding)
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

# Subnet Optimizations
sudo apt install --yes networkd-dispatcher ethtool

# Tailscale version 1.54 or later used with a Linux 6.2 or later kernel enables UDP 
# throughput improvements using transport layer offloads. If a Linux device is acting 
# as an exit node or subnet router, ensure the following network device configuration 
# is in place for the best results:

NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
sudo ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off

# By default, changes made using the ethtool don't persistent after a reboot. 
# On Linux distributions using networkd-dispatcher (which you can verify with 
# systemctl is-enabled networkd-dispatcher), you can run the following commands 
# to create a script that configures these settings on each boot.

printf '#!/bin/sh\n\n/usr/sbin/ethtool -K %s rx-udp-gro-forwarding on rx-gro-list off \n' "$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")" | sudo tee /etc/networkd-dispatcher/routable.d/50-tailscale
sudo chmod 755 /etc/networkd-dispatcher/routable.d/50-tailscale

