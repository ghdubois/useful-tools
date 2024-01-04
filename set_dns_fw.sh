#!/bin/bash

# Reset UFW to default settings
ufw --force reset

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH traffic from specific IP address
ufw allow from 10.1.1.2 to any port 22

# Allow DNS traffic from local IP range 10.1.123.0/28
ufw allow from 10.1.123.0/28 to any port 53

# Allow HTTP and HTTPS traffic for Pi-hole web interface
ufw allow from 10.1.1.2 to any port 80
ufw allow from 10.1.1.2 to any port 443

# Enable UFW
ufw --force enable

# Display UFW status
ufw status verbose
