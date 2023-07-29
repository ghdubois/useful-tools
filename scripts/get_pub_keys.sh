#!/bin/bash

# GitHub username
github_user="example01"

# Check if ssh-import-id tool is available
if command -v ssh-import-id >/dev/null 2>&1; then
    echo "ssh-import-id tool found. Importing GitHub public keys..."
    ssh-import-id gh:$github_user
else
    echo "ssh-import-id tool not found. Manually adding GitHub public keys..."

    # Fetch the public keys using the GitHub API
    keys=$(curl -s "https://api.github.com/users/${github_user}/keys" | grep -oE "\"key\": \"[^\"]+" | sed 's/"key": "//')

    # Check if any keys were found
    if [[ -z "$keys" ]]; then
        echo "No public keys found for GitHub user ${github_user}."
    else
        # Create or append to the authorized_keys file
        mkdir -p ~/.ssh
        touch ~/.ssh/authorized_keys
        echo "$keys" >>~/.ssh/authorized_keys
        echo "Public keys added to ~/.ssh/authorized_keys"
    fi
fi
