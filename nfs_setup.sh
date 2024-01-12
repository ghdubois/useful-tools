#!/bin/bash

# Install NFS server package
sudo apt-get update
sudo apt-get install -y nfs-kernel-server

# Configure NFS export for /mnt/data01 and /mnt/data02
echo "/mnt/data01 *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
echo "/mnt/data02 *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports

# Apply the configuration
sudo exportfs -ra

# Restart NFS service to apply changes
sudo systemctl restart nfs-kernel-server

# Ensure the firewall allows NFS traffic (optional, depending on your setup)
sudo ufw allow from any to any port nfs
