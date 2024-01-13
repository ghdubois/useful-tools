#!/bin/bash

# Define the ports used by Radarr and Overseer
RADARR_PORT="7878" # Default Radarr port
OVERSEER_PORT="5055" # Default Overseer port

# Function to install UFW if it's not already installed
install_ufw() {
    if ! command -v ufw > /dev/null; then
        echo "UFW not found. Installing UFW..."
        sudo apt-get update
        sudo apt-get install -y ufw
        sudo ufw enable
    else
        echo "UFW is already installed."
    fi
}

# Function to set up UFW rules
set_fw_rules() {
    local service_name=$1
    local service_port=$2

    echo "Setting up UFW rules for $service_name on port $service_port..."
    sudo ufw allow $service_port comment "$service_name access"
    echo "UFW rules set for $service_name."
}

# Check for UFW and install if necessary
install_ufw

# Process command-line options
while getopts 'ro' flag; do
  case "${flag}" in
    r) set_fw_rules "Radarr" $RADARR_PORT ;;
    o) set_fw_rules "Overseer" $OVERSEER_PORT ;;
    *) echo "Unexpected option ${flag}"
       exit 1 ;;
  esac
done

# Check if no options were provided
if [ $OPTIND -eq 1 ]; then
    echo "Usage: $0 [-r] for Radarr or [-o] for Overseer"
fi
