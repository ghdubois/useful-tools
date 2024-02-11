#!/bin/bash

# Define mount points and filesystem types
MOUNT_POINT_SDB="/mnt/disk01"
MOUNT_POINT_SDC="/mnt/disk02"
FILESYSTEM_TYPE="ext4"

# Create mount points
sudo mkdir -p $MOUNT_POINT_SDB
sudo mkdir -p $MOUNT_POINT_SDC

# Check if /dev/sdb is already in fstab
if ! grep -qs '/dev/sdb ' /etc/fstab; then
    # Add /dev/sdb to fstab
    echo "/dev/sdb $MOUNT_POINT_SDB $FILESYSTEM_TYPE defaults 0 2" | sudo tee -a /etc/fstab
else
    echo "/dev/sdb is already in fstab"
fi

# Check if /dev/sdc is already in fstab
if ! grep -qs '/dev/sdc ' /etc/fstab; then
    # Add /dev/sdc to fstab
    echo "/dev/sdc $MOUNT_POINT_SDC $FILESYSTEM_TYPE defaults 0 2" | sudo tee -a /etc/fstab
else
    echo "/dev/sdc is already in fstab"
fi

# Mount all filesystems
sudo mount -a
