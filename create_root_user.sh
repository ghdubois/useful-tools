#!/bin/bash

# Default username
DEFAULT_USER="osiris"

# Read username from the first script argument, default to DEFAULT_USER if not provided
USERNAME=${1:-$DEFAULT_USER}

# Function to check if user exists
user_exists() {
    id "$1" &>/dev/null
}

# Function to check if user is in the sudo group
user_in_sudo_group() {
    groups "$1" | grep -q "\bsudo\b"
}

# Create a new user with a home directory, if the user doesn't already exist
if user_exists "$USERNAME"; then
    echo "User $USERNAME already exists. Skipping user creation."
else
    sudo useradd -m "$USERNAME" && echo "User $USERNAME created successfully." || { echo "Failed to create user $USERNAME."; exit 1; }
fi

# Add the user to the 'sudo' group, if not already in it
if user_in_sudo_group "$USERNAME"; then
    echo "User $USERNAME is already in the sudo group. Skipping group addition."
else
    sudo usermod -aG sudo "$USERNAME" && echo "User $USERNAME added to sudo group." || { echo "Failed to add $USERNAME to sudo group."; exit 1; }
fi

# Set the default shell for the user to Bash, if it's not already Bash
if [ "$(getent passwd "$USERNAME" | cut -d: -f7)" != "/bin/bash" ]; then
    sudo chsh -s /bin/bash "$USERNAME" && echo "Default shell for $USERNAME set to Bash." || { echo "Failed to set default shell to Bash for $USERNAME."; exit 1; }
else
    echo "Default shell for $USERNAME is already set to Bash. No changes made."
fi
