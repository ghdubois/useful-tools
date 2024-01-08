#!/bin/bash

# Function to install NFS packages based on the system's package manager
install_nfs_packages() {
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y nfs-common
    elif command -v yum &> /dev/null; then
        sudo yum install -y nfs-utils
    else
        echo "Unsupported package manager. Please install the NFS client manually."
        exit 1
    fi
}

# Default NFS server and location
NFS_SERVER="192.168.5.2"
NFS_LOCATION="/volume2/nfs"

# make mntpoint

mkdir /mnt/nfs > /dev/null

# Default local mount point
MOUNT_POINT="/mnt/nfs"

# Allow overrides
if [ $# -ge 1 ]; then
    NFS_SERVER=$1
fi

if [ $# -ge 2 ]; then
    NFS_LOCATION=$2
fi

# Check if the mount point exists, create it if not
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

# Install NFS packages
install_nfs_packages

# Mount the NFS drive
sudo mount -t nfs -o vers=3,nolock,noatime "$NFS_SERVER:$NFS_LOCATION" "$MOUNT_POINT"

# Check if the mount was successful
if [ $? -eq 0 ]; then
    echo "NFS drive mounted successfully at $MOUNT_POINT"
else
    echo "Failed to mount NFS drive"
fi
