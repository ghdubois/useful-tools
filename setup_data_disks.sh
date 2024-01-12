#!/bin/bash

# Variables for device and mount points
DEVICE1="/dev/sda1"
MOUNT_POINT1="/mnt/shared-data/disk01"

DEVICE2="/dev/sdb1"
MOUNT_POINT2="/mnt/shared-data/disk02"

# Create mount directories
mkdir -p $MOUNT_POINT1
mkdir -p $MOUNT_POINT2

# Add entries to /etc/fstab
echo "$DEVICE1 $MOUNT_POINT1 ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "$DEVICE2 $MOUNT_POINT2 ext4 defaults 0 0" | sudo tee -a /etc/fstab

# Mount the devices
sudo mount $DEVICE1 $MOUNT_POINT1
sudo mount $DEVICE2 $MOUNT_POINT2

# Display mounted filesystems
df -h | grep $MOUNT_POINT1
df -h | grep $MOUNT_POINT2
