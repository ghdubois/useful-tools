#!/bin/bash

# Define filesystem type
FILESYSTEM_TYPE="ext4"

# Partition and format /dev/sdb
echo "Partitioning /dev/sdb..."
sudo parted /dev/sdb --script mklabel gpt mkpart primary $FILESYSTEM_TYPE 1MiB 100%
sudo mkfs.$FILESYSTEM_TYPE /dev/sdb1

# Partition and format /dev/sdc
echo "Partitioning /dev/sdc..."
sudo parted /dev/sdc --script mklabel gpt mkpart primary $FILESYSTEM_TYPE 1MiB 100%
sudo mkfs.$FILESYSTEM_TYPE /dev/sdc1

# Define mount points
MOUNT_POINT_SDB="/mnt/disk01"
MOUNT_POINT_SDC="/mnt/disk02"

# Create mount points
echo "Creating mount points..."
sudo mkdir -p $MOUNT_POINT_SDB
sudo mkdir -p $MOUNT_POINT_SDC

# Add to fstab
echo "Adding entries to /etc/fstab..."
if ! grep -qs $MOUNT_POINT_SDB /etc/fstab; then
    echo "/dev/sdb1 $MOUNT_POINT_SDB $FILESYSTEM_TYPE defaults 0 2" | sudo tee -a /etc/fstab
else
    echo "$MOUNT_POINT_SDB is already in fstab."
fi

if ! grep -qs $MOUNT_POINT_SDC /etc/fstab; then
    echo "/dev/sdc1 $MOUNT_POINT_SDC $FILESYSTEM_TYPE defaults 0 2" | sudo tee -a /etc/fstab
else
    echo "$MOUNT_POINT_SDC is already in fstab."
fi

# Mount all filesystems
echo "Mounting all filesystems..."
sudo mount -a
