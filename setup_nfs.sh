#!/bin/bash

# Default values
nfs_server="192.168.5.2"
nfs_mount_point="/Volume02/nfs"

# Function to display script usage
usage() {
  echo "Usage: $0 [-s NFS_SERVER] [-m NFS_MOUNT_POINT]" 1>&2
  exit 1
}

# Parse command line options
while getopts ":s:m:" opt; do
  case $opt in
    s)
      nfs_server="$OPTARG"
      ;;
    m)
      nfs_mount_point="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Install NFS client if not already installed
if ! command -v nfs-client; then
  sudo apt-get update
  sudo apt-get install -y nfs-client
fi

# Create mount point if it doesn't exist
if [ ! -d "$nfs_mount_point" ]; then
  sudo mkdir -p "$nfs_mount_point"
fi

# Mount the NFS share
sudo mount -o vers=3,nolock,proto=tcp "$nfs_server":/exported/path "$nfs_mount_point"

echo "NFS share mounted at: $nfs_mount_point"
