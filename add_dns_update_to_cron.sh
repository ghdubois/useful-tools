#!/bin/bash

# Define the git repository directory
repo_dir="/root/useful-tools/"

# Command-line arguments
action=$1  # 'add' or 'remove'
custom_script=$2
custom_interval=$3

# Default values if not provided
default_script="/root/useful-tools/get_custom_dns.sh"
default_interval="*/5 * * * *"  # Every 5 minutes

# Determine script path and interval based on user input or default
script_path=${custom_script:-$default_script}
interval=${custom_interval:-$default_interval}

# Function to add a cron job
add_cron_job() {
    chmod +x "$script_path"

    # Check if the cron job already exists
    if crontab -l | grep -q "$script_path"; then
        echo "Cron job for $script_path already exists."
        return 0
    fi

    # Add the new cron job
    (crontab -l 2>/dev/null; echo "$interval $script_path") | crontab -
    echo "Cron job set to run $script_path at interval: $interval."
}

# Function to remove a cron job
remove_cron_job() {
    # Remove the cron job if it exists
    (crontab -l 2>/dev/null | grep -v "$script_path") | crontab -
    echo "Cron job for $script_path removed."
}

# Main script logic
case $action in
    add)
        # Check if the script exists
        if [ ! -f "$script_path" ]; then
            echo "Script $script_path not found. Attempting to update repository."

            # Change to the repository directory and attempt to pull updates
            if cd "$repo_dir"; then
                git pull
                if [ ! -f "$script_path" ]; then
                    echo "Error: Script still not found after updating repository."
                    exit 1
                fi
            else
                echo "Error: Unable to access directory $repo_dir."
                exit 1
            fi
        fi

        add_cron_job
        ;;

    remove)
        remove_cron_job
        ;;

    *)
        echo "Invalid action. Please specify 'add' or 'remove'."
        exit 1
        ;;
esac













# #!/bin/bash

# # Define the script path and the git repository directory
# repo_dir="/root/useful-tools/"

# # Custom script and interval
# custom_script=$1
# custom_interval=$2

# # Default values if not provided
# default_script="/root/useful-tools/get_custom_dns.sh"
# default_interval="*/5 * * * *"  # Every 5 minutes

# # Use default values if custom values are not provided
# script_path=${custom_script:-$default_script}
# interval=${custom_interval:-$default_interval}

# # Check if the script exists
# if [ ! -f "$script_path" ]; then
#     echo "Script $script_path not found. Attempting to update repository."

#     # Change to the repository directory and attempt to pull updates
#     if cd "$repo_dir"; then
#         git pull
#         if [ ! -f "$script_path" ]; then
#             echo "Error: Script still not found after updating repository."
#             exit 1
#         fi
#     else
#         echo "Error: Unable to access directory $repo_dir."
#         exit 1
#     fi
# fi

# chmod +x "$script_path"

# # Check if the cron job already exists
# if crontab -l | grep -q "$script_path"; then
#     echo "Cron job for $script_path already exists."
#     exit 0
# fi

# # Add the new cron job
# (crontab -l 2>/dev/null; echo "$interval $script_path") | crontab -

# echo "Cron job set to run $script_path at interval: $interval."




# # #!/bin/bash

# # # Define the script path and the git repository directory
# # script_path="/root/useful-tools/get_custom_dns.sh"
# # repo_dir="/root/useful-tools/"

# # # Check if the script exists
# # if [ ! -f "$script_path" ]; then
# #     echo "Script $script_path not found. Attempting to update repository."

# #     # Change to the repository directory and attempt to pull updates
# #     if cd "$repo_dir"; then
# #         git pull
# #         if [ ! -f "$script_path" ]; then
# #             echo "Error: Script still not found after updating repository."
# #             exit 1
# #         fi
# #     else
# #         echo "Error: Unable to access directory $repo_dir."
# #         exit 1
# #     fi
# # fi

# # chmod +x "$script_path"

# # # Check if the cron job already exists
# # if crontab -l | grep -q "$script_path"; then
# #     echo "Cron job already exists."
# #     exit 0
# # fi

# # # Add the new cron job
# # (crontab -l 2>/dev/null; echo "*/30 * * * * $script_path") | crontab -

# # echo "Cron job set to run $script_path every 30 minutes."

# # # # Remove the temporary file
# # # rm mycron
