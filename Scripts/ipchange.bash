#!/bin/bash

# Prompt the user for information
read -p "Enter the desired static IP address: " ip_address
read -p "Enter the netmask (e.g., 255.255.255.0): " netmask
read -p "Enter the gateway IP address: " gateway
read -p "Enter the DNS server IP address: " dns

# Get the current network interface name (assuming it's eth0, change if needed)
interface=$(ip route | grep default | awk '{print $5}')

# Get the current secondary dynamic IP address (if any)
secondary_ip=$(ip -4 addr show dev $interface | awk '/secondary/ {print $2}' | cut -d'/' -f1)

# Backup the current network configuration file
sudo cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.bak

# Create a new Netplan configuration file with the provided settings
cat <<EOL | sudo tee /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: no
      addresses: [$ip_address/24]
      gateway4: $gateway
      nameservers:
        addresses: [$dns]
EOL

# Set secure permissions on the Netplan directory and configuration file
sudo chmod 750 /etc/netplan
sudo chmod 640 /etc/netplan/01-netcfg.yaml

# Remove any secondary dynamic IP address
if [ -n "$secondary_ip" ]; then
  echo "Removing secondary IP address: $secondary_ip"
  sudo ip addr del $secondary_ip/24 dev $interface
fi

# Apply the new configuration
sudo netplan apply

echo "Static IP configuration applied successfully."
