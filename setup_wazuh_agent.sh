#!/bin/bash

# Accept user input for WAZUH_MANAGER variable or use the default value
read -p "Enter WAZUH_MANAGER (default is 192.168.5.31): " WAZUH_MANAGER
WAZUH_MANAGER=${WAZUH_MANAGER:-192.168.5.31}

# Check if the Wazuh repository is not already added before adding it
if ! grep -q "https://packages.wazuh.com/4.x/apt/ stable main" /etc/apt/sources.list.d/wazuh.list; then
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg &&
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list &&
    apt-get update
fi

# Install Wazuh agent
WAZUH_MANAGER="$WAZUH_MANAGER" apt-get install wazuh-agent &&

# Configure and start the Wazuh agent
systemctl daemon-reload &&
systemctl enable wazuh-agent &&
systemctl start wazuh-agent &&

# Set Wazuh-agent on hold
echo "wazuh-agent hold" | dpkg --set-selections
