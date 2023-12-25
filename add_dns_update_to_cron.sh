#!/bin/bash

# Backup existing crontab
crontab -l > mycron

# Echo new cron into cron file
echo "*/30 * * * * /root/useful-tools/get_custom_dns.sh" >> mycron

# Install new cron file
crontab mycron

# Remove the temporary file
rm mycron

echo "Cron job set to run /root/useful-tools/get_custom_dns.sh every 30 minutes."
