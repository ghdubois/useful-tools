#!/bin/bash

# Wazuh Server UFW Configuration Script

# Default policies: deny incoming and allow outgoing
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (optional, adjust the port if you use a non-standard one)
ufw allow 22

# Allow Wazuh server ports
# Replace these with the ports you have configured for Wazuh
ufw allow 1514/tcp   # For Wazuh agent communication
ufw allow 1515/tcp   # For agent registration
ufw allow 514/udp    # For syslog
ufw allow 55000/tcp  # For Wazuh API

# Enable the firewall
ufw enable

# Optional: Enable logging
ufw logging on

echo "UFW configuration for Wazuh server is complete."
