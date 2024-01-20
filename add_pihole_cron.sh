#!/bin/bash

# Define the command to add to the cron tab
COMMAND1="pihole -g"
COMMAND2="pihole -up"
# Get the current user's crontab and save it to a temporary file
crontab -l > temp_crontab

# Check if the command is already present in the cron tab
if grep -qF "$COMMAND1" temp_crontab; then
    echo "The command '$COMMAND1' is already in the cron tab."
else
    # Append the new command to the temporary crontab file
    echo "@daily $COMMAND1" >> temp_crontab

    # Install the updated crontab from the temporary file
    crontab temp_crontab

    echo "The command '$COMMAND1' has been added to the cron tab."
fi


# Check if the command2 is already present in the cron tab
if grep -qF "$COMMAND2" temp_crontab; then
    echo "The command '$COMMAND2' is already in the cron tab."
else
    # Append the new command to the temporary crontab file
    echo "@daily $COMMAND2" >> temp_crontab

    # Install the updated crontab from the temporary file
    crontab temp_crontab

    echo "The command '$COMMAND2' has been added to the cron tab."
fi

# Remove the temporary crontab file
rm temp_crontab
