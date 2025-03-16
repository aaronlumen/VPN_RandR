> [!IMPORTANT]
> ## How This Script Works]
>   - Removal of Existing VPN Software:
>   - The script purges VPN packages (StrongSwan, xl2tpd, ipsec-tools) and removes any existing OpenVPN configurations that might conflict.

> [!TIP]
> ## Installation of OpenVPN and EasyRSA:
> It installs OpenVPN and EasyRSA and creates a fresh PKI directory for generating keys and certificates.

> [!TIP]
> ## PKI & Certificates Setup:
> The script initializes a new PKI, builds a CA (without a password), generates a server certificate/key, Diffie-Hellman parameters, and a TLS-auth key for an extra layer of security.

> [!NOTE]
> ## Server Configuration:
> A simple server.conf file is created in /etc/openvpn/ that sets up the VPN to listen on UDP port 1194. It uses the generated keys and certificates, defines a client subnet (10.8.0.0/24), and pushes a default gateway and DNS settings to connected clients.

> [!WARNING]
> ## IP Forwarding & NAT:
> IP forwarding is enabled, and iptables rules are applied to masquerade traffic from the VPN subnet through the server’s external interface. A script is added so that these rules are restored on network interface startup.

> [!CAUTION]
> ## Service Management:
> Finally, the OpenVPN service is started and enabled to run at boot.
 ### Next Steps

> [!IMPORTANT]
> ## Client Setup:
> *You’ll need to generate client certificates (using EasyRSA in a similar fashion) and create a corresponding client configuration file (.ovpn) for Windows OpenVPN clients.*

> [!CAUTION]
> ## Testing:
> _Verify that clients can connect to a vpn headend and that their traffic is routed correctly._
