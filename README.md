***VPN_RandR***

**VPN Remove and Reinstall* 
================================================

## Here's a Python script that automates the process of removing existing
VPN configurations and installing a full IPsec VPN using the setup script from the GitHub repository.##

### Features:###
1. *Prompts the user for confirmation before removing existing VPN configurations.*
2. *Stops and removes VPN-related services (ipsec, xl2tpd, strongswan, etc.).*
3. *Removes old VPN configurations and directories.*
4. *Installs the full VPN setup from the provided GitHub repository.*

### Script: vpn_reinstall.py ###
```
#!/usr/bin/python3
import os
import subprocess

def confirm_action(prompt):
    # """Prompt user for confirmation before proceeding."""
    while True:
        response = input(f"{prompt} (yes/no): ").strip().lower()
        if response in ["yes", "y"]:
            return True
        elif response in ["no", "n"]:
            return False
        else:
            print("Invalid input. Please type 'yes' or 'no'.")

def stop_and_remove_vpn():
    # """Stop and remove existing VPN services and configurations."""
    services = ["ipsec", "xl2tpd", "strongswan", "libreswan", "openswan"]
    ```
    print("\nStopping VPN services...")
    for service in services:
        subprocess.run(["sudo", "systemctl", "stop", service], stderr=subprocess.DEVNULL)
        subprocess.run(["sudo", "systemctl", "disable", service], stderr=subprocess.DEVNULL)
        subprocess.run(["sudo", "systemctl", "reset-failed"], stderr=subprocess.DEVNULL)
``
    print("Removing VPN packages...")
    subprocess.run(["sudo", "apt-get", "remove", "-y"] + services, check=False)
    subprocess.run(["sudo", "apt-get", "autoremove", "-y"], check=False)
`
    print("Deleting VPN configuration files...")
    vpn_files = ["/etc/ipsec.conf", "/etc/ipsec.secrets", "/etc/xl2tpd", "/etc/ppp"]
    for file in vpn_files:
        subprocess.run(["sudo", "rm", "-rf", file])  

`
    print("Flushing IP tables and restarting networking...")
    subprocess.run(["sudo", "iptables", "-F"])
    subprocess.run(["sudo", "iptables", "-X"])
    subprocess.run(["sudo", "systemctl", "restart", "networking"])

def install_vpn():
    # Download and install VPN from GitHub repository.
    print("\nDownloading and installing VPN setup script...")
    subprocess.run(["wget", "-q", "https://raw.githubusercontent.com/hwdsl2/setup-ipsec-vpn/master/vpnsetup_ubuntu.sh", "-O", "vpnsetup.sh"])
    subprocess.run(["sudo", "chmod", "+x", "vpnsetup.sh"])
    subprocess.run(["sudo", "bash", "vpnsetup.sh"])

def main():
    print("\nVPN Configuration Reset & Installation Tool")
`
    if confirm_action("Do you want to remove all existing VPN configurations?"):
        stop_and_remove_vpn()
        print("VPN configuration removed successfully.")
``
    if confirm_action("Do you want to install the full VPN setup from hwdsl2?"):
        install_vpn()
        print("VPN installation completed.")

```    print("\nProcess finished.")

if __name__ == "__main__":
    main()
```
   
### How to Use the Script ###
**Save the script as vpn_reinstall.py on your Ubuntu server.**
**Give it execute permissions**:
```
chmod +x vpn_reinstall.py
```
** Run the script:**
```
sudo python3 vpn_reinstall.py
```
## **What This Script Does:** ##
**Checks with the user before proceeding with any action.
Stops and removes any existing VPN services and configurations.
Deletes VPN-related files and clears iptables.
Downloads and installs the full IPsec VPN setup from hwdsl2 GitHub repo.
**
*This ensures a clean removal of previous VPN configurations and reinstallation of a fresh VPN setup.*

#### Thank you for participating ####

Would you like any modifications or additional features? 🚀
