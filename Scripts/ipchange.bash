#!/bin/bash
# Script to adjust network settings

# Prompt the user for information
read -p "Enter the desired static IP address: " ip_address
read -p "Enter the netmask (e.g., 255.255.255.0): " netmask
read -p "Enter the gateway IP address: " gateway
read -p "Enter the DNS server IP address: " dns

# Get the current network interface name (assuming it's eth0, change if needed)
interface=$(ip route | grep default | awk '{print $5}')

# Backup the current network configuration file
sudo cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.bak

# Create a new Netplan configuration file with the provided settings
echo "network:" | sudo tee /etc/netplan/01-netcfg.yaml
echo "  version: 2" | sudo tee -a /etc/netplan/01-netcfg.yaml
echo "  renderer: networkd" | sudo tee -a /etc/netplan/01-netcfg.yaml
echo "  ethernets:" | sudo tee -a /etc/netplan/01-netcfg.yaml
echo "    $interface:" | sudo tee -a /etc/netplan/01-netcfg.yaml
echo "      addresses: [$ip_address/24]" | sudo tee -a /etc/netplan/01-netcfg.yaml
echo "      gateway4: $gateway" | sudo tee -a /etc/netplan/01-netcfg.yaml
echo "      nameservers:" | sudo tee -a /etc/netplan/01-netcfg.yaml
echo "        addresses: [$dns]" | sudo tee -a /etc/netplan/01-netcfg.yaml

# Apply the new configuration
sudo netplan apply

echo "Static IP configuration applied successfully."
