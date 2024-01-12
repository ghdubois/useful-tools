#!/bin/bash

# Variables
SERVER_IP="10.1.123.4"
MOUNT_POINT="/mnt/nfs"

# Install NFS client package
sudo apt-get update
sudo apt-get install -y nfs-common

# Create mount points
sudo mkdir -p ${MOUNT_POINT}/data01
sudo mkdir -p ${MOUNT_POINT}/data02

# Mount NFS shares
sudo mount ${SERVER_IP}:/mnt/data01 ${MOUNT_POINT}/data01
sudo mount ${SERVER_IP}:/mnt/data02 ${MOUNT_POINT}/data02

# To ensure the NFS mounts are persistent across reboots,
# add the following lines to /etc/fstab (requires root privileges)
echo "${SERVER_IP}:/mnt/data01 ${MOUNT_POINT}/data01 nfs defaults 0 0" | sudo tee -a /etc/fstab
echo "${SERVER_IP}:/mnt/data02 ${MOUNT_POINT}/data02 nfs defaults 0 0" | sudo tee -a /etc/fstab
