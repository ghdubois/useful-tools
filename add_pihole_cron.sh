#!/bin/bash

# Define the commands
COMMAND1="pihole -g"
COMMAND2="pihole -up"

# Function to add a command to the crontab
add_to_crontab() {
    local command=$1
    crontab -l > temp_crontab
    if ! grep -qF "$command" temp_crontab; then
        echo "@daily $command" >> temp_crontab
        crontab temp_crontab
        echo "The command '$command' has been added to the cron tab."
    else
        echo "The command '$command' is already in the cron tab."
    fi
    rm temp_crontab
}

# Function to remove a command from the crontab
remove_from_crontab() {
    local command=$1
    crontab -l > temp_crontab
    if grep -qF "$command" temp_crontab; then
        sed -i "/$command/d" temp_crontab
        crontab temp_crontab
        echo "The command '$command' has been removed from the cron tab."
    else
        echo "The command '$command' was not found in the cron tab."
    fi
    rm temp_crontab
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a1)
            add_to_crontab "$COMMAND1"
            shift
            ;;
        -a2)
            add_to_crontab "$COMMAND2"
            shift
            ;;
        -r1)
            remove_from_crontab "$COMMAND1"
            shift
            ;;
        -r2)
            remove_from_crontab "$COMMAND2"
            shift
            ;;
        *)
            echo "Invalid argument: $1"
            exit 1
    esac
done
