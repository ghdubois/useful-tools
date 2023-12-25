#!/bin/bash

# This URL will depend on your chosen method
FILE_URL="https://192.168.5.2/dns/custom.list"
LOCAL_FILE="/etc/pihole/custom.list"

# Fetch the file
curl -k $FILE_URL -o $LOCAL_FILE

# Restart dnsmasq or pihole-FTL to apply changes
sudo service pihole-FTL restart
