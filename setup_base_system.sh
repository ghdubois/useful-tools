#!/bin/bash

# Script to set up unattended upgrades for Ubuntu 22.04

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Update and upgrade existing packages
apt update && apt upgrade -y

# Install unattended-upgrades
apt install unattended-upgrades

# Enable unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades

# Restart the unattended-upgrades service
systemctl restart unattended-upgrades

echo "Unattended upgrades setup complete."
