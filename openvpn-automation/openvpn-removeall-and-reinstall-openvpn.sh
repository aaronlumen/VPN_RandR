#!/bin/bash
# openvpn-removeall-and-reinstall-openvpn.sh
# Description: This script removes conflicting VPN services, installs OpenVPN,
# creates a simple PKI using EasyRSA, configures an OpenVPN server to accept
# Windows clients, and routes all client traffic through $(hostname).
#
# WARNING: This script will remove any existing VPN packages and configurations.
# Make sure to backup any important configurations and test on a nonproduction system.
#
# Requirements:
# - Debian-based system
# - Run as root

# Check for root privileges.
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root. Exiting."
  exit 1
fi

echo "Removing conflicting VPN packages and configurations..."
apt-get purge -y strongswan strongswan-starter xl2tpd ipsec-tools
apt-get autoremove -y

# Optionally purge any existing OpenVPN configuration (adjust paths if needed)
rm -f /etc/openvpn/server.conf
rm -rf /etc/openvpn/easy-rsa
rm -rf /etc/openvpn/*

echo "Installing OpenVPN and EasyRSA..."
apt-get update
apt-get install -y openvpn easy-rsa

# Set up EasyRSA PKI environment
EASYRSA_DIR="/etc/openvpn/easy-rsa"
make-cadir "$EASYRSA_DIR"
cd "$EASYRSA_DIR" || { echo "Failed to enter $EASYRSA_DIR"; exit 1; }

# Initialize the PKI and build the Certificate Authority (CA) with no passphrase.
./easyrsa init-pki
./easyrsa build-ca nopass <<EOF
yes
EOF

# Generate the server certificate and key
./easyrsa gen-req server nopass
./easyrsa sign-req server server <<EOF
yes
EOF

# Generate Diffie-Hellman parameters and a TLS authentication key
./easyrsa gen-dh
openvpn --genkey --secret ta.key

# Copy keys and certificates to /etc/openvpn
cp pki/ca.crt /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp ta.key /etc/openvpn/
cp pki/dh.pem /etc/openvpn/

echo "Creating OpenVPN server configuration..."
cat > /etc/openvpn/server.conf <<'EOF'
port 1194
proto udp
dev tun

; Certificates and keys
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0

; VPN subnet for clients
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt

; Push routes and DNS to clients
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"

; Keepalive and performance
keepalive 10 120
cipher AES-256-CBC

; Run OpenVPN as an unprivileged user for security
user nobody
group nogroup

persist-key
persist-tun

status openvpn-status.log
verb 3
EOF

echo "Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf || echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Determine the external interface (assumes the default route interface)
EXTERNAL_IF=$(ip route | awk '/default/ {print $5; exit}')
if [ -z "$EXTERNAL_IF" ]; then
    echo "Could not determine the external interface. Please set it manually."
    exit 1
fi

echo "Setting up iptables NAT (masquerading) on interface $EXTERNAL_IF..."
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$EXTERNAL_IF" -j MASQUERADE
iptables-save > /etc/iptables.rules

# Create an iptables restore script to load rules on network start
cat > /etc/network/if-up.d/iptables <<'EOF'
#!/bin/sh
iptables-restore < /etc/iptables.rules
EOF
chmod +x /etc/network/if-up.d/iptables

echo "Starting and enabling OpenVPN service..."
systemctl start openvpn@server
systemctl enable openvpn@server

echo "OpenVPN installation and configuration complete."
echo "Clients can now connect to $(hostname) on UDP port 1194."

