#!/bin/bash

set -e

echo "=== Tailscale SSH + Exit Node Setup ==="

# IPv4 and IPv6 forwarding
echo "Enabling IP forwarding..."
grep -qxF 'net.ipv4.ip_forward=1' /etc/sysctl.conf || echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
grep -qxF 'net.ipv6.conf.all.forwarding=1' /etc/sysctl.conf || echo 'net.ipv6.conf.all.forwarding=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Detect primary network interface
IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
echo "Detected interface: $IFACE"

# UDP GRO forwarding now
sudo ethtool -K "$IFACE" rx-udp-gro-forwarding on

# UDP GRO persistence via NetworkManager dispatcher
DISPATCHER=/etc/NetworkManager/dispatcher.d/99-udp-gro
echo "Creating NetworkManager dispatcher script..."
cat <<EOF | sudo tee "$DISPATCHER" > /dev/null
#!/bin/bash
if [ "\$1" = "$IFACE" ] && [ "\$2" = "up" ]; then
    ethtool -K $IFACE rx-udp-gro-forwarding on
fi
EOF
sudo chmod +x "$DISPATCHER"

# Advertise exit node and enable SSH
echo "Configuring Tailscale..."
sudo tailscale up --advertise-exit-node --ssh

echo ""
echo "=== Done ==="
echo "Now go to admin.tailscale.com and approve the exit node under Edit route settings."