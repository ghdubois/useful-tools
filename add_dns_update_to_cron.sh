#!/bin/bash

# Define the script path and the git repository directory
script_path="/root/useful-tools/get_custom_dns.sh"
repo_dir="/root/useful-tools/"

# Check if the script exists
if [ -f "$script_path" ]; then
    chmod +x "$script_path"
else
    echo "Script $script_path not found. Attempting to update repository."

    # Change to the repository directory and attempt to pull updates
    if cd "$repo_dir"; then
        git pull
        if [ -f "$script_path" ]; then
            chmod +x "$script_path"
        else
            echo "Error: Script still not found after updating repository."
            exit 1
        fi
    else
        echo "Error: Unable to access directory $repo_dir."
        exit 1
    fi
fi

# Check if the root user has a crontab; if not, create one
if ! crontab -l 2>/dev/null; then
    echo "No crontab for root. Creating one."
fi

# Backup existing crontab
crontab -l > mycron 2>/dev/null || echo -n "" > mycron

# Add the new cron job
echo "*/30 * * * * $script_path" >> mycron

# Install the new cron file
crontab mycron
if [ $? -eq 0 ]; then
    echo "Cron job set to run $script_path every 30 minutes."
else
    echo "Failed to set cron job."
    exit 1
fi

# Remove the temporary file
rm mycron
