#!/bin/bash

# Check if SSH root login is disabled
check_ssh_root_login() {
    grep "^PermitRootLogin" /etc/ssh/sshd_config | grep -q "no"
    [ $? -eq 0 ] && echo "SSH root login is disabled." || echo "SSH root login is not disabled."
}

# Disable SSH root login
implement_ssh_root_login() {
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "SSH root login disabled."
}

# Check for presence of unnecessary accounts
check_unnecessary_accounts() {
    if [ -z "$(awk -F: '$3 == 0 { print $1 }' /etc/passwd | grep -v 'root')" ]; then
        echo "No unnecessary accounts with UID 0 found."
    else
        echo "There are unnecessary accounts with UID 0."
    fi
}

# Remove unnecessary accounts
remove_unnecessary_accounts() {
    awk -F: '$3 == 0 { print $1 }' /etc/passwd | grep -v 'root' | xargs -I {} userdel {}
    echo "Unnecessary accounts removed."
}

# Check password expiration policy
check_password_expiration_policy() {
    grep PASS_MAX_DAYS /etc/login.defs | grep -q "90"
    [ $? -eq 0 ] && echo "Password expiration policy is set correctly." || echo "Password expiration policy is not set correctly."
}

# Implement password expiration policy
implement_password_expiration_policy() {
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
    echo "Password expiration policy set to 90 days."
}

# Check for ungrouped files
check_ungrouped_files() {
    if [ -z "$(find / -nogroup)" ]; then
        echo "No ungrouped files found."
    else
        echo "There are ungrouped files."
    fi
}

# Fix ungrouped files
fix_ungrouped_files() {
    find / -nogroup -exec chgrp root {} \;
    echo "Ungrouped files assigned to group root."
}

# Check for unowned files
check_unowned_files() {
    if [ -z "$(find / -nouser)" ]; then
        echo "No unowned files found."
    else
        echo "There are unowned files."
    fi
}

# Fix unowned files
fix_unowned_files() {
    find / -nouser -exec chown root {} \;
    echo "Unowned files assigned to user root."
}

# Function to check for world writable files
check_world_writable_files() {
    if [ -z "$(find / -xdev -type f -perm -0002)" ]; then
        echo "No world writable files found."
    else
        echo "There are world writable files."
    fi
}

# Function to fix world writable files
fix_world_writable_files() {
    find / -xdev -type f -perm -0002 -exec chmod o-w {} \;
    echo "World writable permissions removed."
}

# Function to check if auditing for certain events is enabled
check_audit_events() {
    if [ -n "$(auditctl -l | grep 'w /etc/passwd')" ]; then
        echo "Auditing for /etc/passwd changes is enabled."
    else
        echo "Auditing for /etc/passwd changes is not enabled."
    fi
}

# Function to enable auditing for certain events
enable_audit_events() {
    auditctl -w /etc/passwd -p wa
    echo "Auditing for /etc/passwd changes enabled."
}

# Function to check if unnecessary services are disabled
check_unnecessary_services() {
    if systemctl is-enabled autofs; then
        echo "Autofs is enabled."
    else
        echo "Autofs is disabled."
    fi
}

# Function to disable unnecessary services
disable_unnecessary_services() {
    systemctl disable autofs
    echo "Autofs service disabled."
}


# Check for secure file permissions on /etc/shadow
check_shadow_file_permissions() {
    if [ "$(stat -c %a /etc/shadow)" == "000" ]; then
        echo "/etc/shadow permissions are secure."
    else
        echo "/etc/shadow permissions are not secure."
    fi
}

# Set secure file permissions on /etc/shadow
set_shadow_file_permissions() {
    chmod 000 /etc/shadow
    echo "Set secure permissions on /etc/shadow."
}

# Check if system is using the latest patches
check_system_patches() {
    if apt-get -s upgrade | grep -q '0 upgraded, 0 newly installed, 0 to remove'; then
        echo "System is up to date."
    else
        echo "System is not up to date."
    fi
}

# Update system patches
update_system_patches() {
    apt-get update && apt-get upgrade -y
    echo "System updated with latest patches."
}

# Check for noexec option on temporary directories
check_noexec_on_tmp() {
    if mount | grep -q '/tmp.*noexec'; then
        echo "/tmp is mounted with noexec."
    else
        echo "/tmp is not mounted with noexec."
    fi
}

# Set noexec option on temporary directories
set_noexec_on_tmp() {
    mount -o remount,noexec /tmp
    echo "Mounted /tmp with noexec."
}


# Check if firewall is configured and active
check_firewall_configuration() {
    if ufw status | grep -q 'Status: active'; then
        echo "Firewall is active."
    else
        echo "Firewall is not active."
    fi
}

# Configure and enable the firewall
configure_firewall() {
    ufw allow 32400/tcp
    ufw enable
    echo "Firewall configured and enabled for Plex (port 32400)."
}

# Check if SELinux is enforcing
check_selinux_status() {
    if getenforce | grep -q 'Enforcing'; then
        echo "SELinux is in enforcing mode."
    else
        echo "SELinux is not in enforcing mode."
    fi
}

# Set SELinux to enforcing mode
set_selinux_enforcing() {
    setenforce 1
    sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
    echo "SELinux set to enforcing mode."
}

# Check for Plex-related secure permissions and ownership
check_plex_permissions_ownership() {
    if [ -d "/var/lib/plexmediaserver" ]; then
        plex_permissions=$(stat -c %a /var/lib/plexmediaserver)
        plex_owner=$(stat -c %U /var/lib/plexmediaserver)
        if [ "$plex_permissions" == "700" ] && [ "$plex_owner" == "plex" ]; then
            echo "Plex directory permissions and ownership are secure."
        else
            echo "Plex directory permissions and ownership are not secure."
        fi
    else
        echo "Plex directory not found."
    fi
}

# Set secure permissions and ownership for Plex
secure_plex_permissions_ownership() {
    mkdir -p /var/lib/plexmediaserver
    chown plex:plex /var/lib/plexmediaserver
    chmod 700 /var/lib/plexmediaserver
    echo "Set secure permissions and ownership for Plex directory."
}

# Check if automatic updates are enabled
check_automatic_updates() {
    if [ -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
        echo "Automatic updates are enabled."
    else
        echo "Automatic updates are not enabled."
    fi
}

# Enable automatic updates
enable_automatic_updates() {
    apt-get install unattended-upgrades
    dpkg-reconfigure -plow unattended-upgrades
    echo "Automatic updates enabled."
}


# Check for SSH protocol version
check_ssh_protocol_version() {
    if grep -q "^Protocol 2" /etc/ssh/sshd_config; then
        echo "SSH Protocol version 2 is in use."
    else
        echo "SSH Protocol version is not set to 2."
    fi
}

# Set SSH to use Protocol version 2
set_ssh_protocol_version() {
    sed -i 's/^#Protocol.*/Protocol 2/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "SSH set to use Protocol version 2."
}

# Check for sysctl configurations
check_sysctl_configurations() {
    if sysctl net.ipv4.conf.all.rp_filter | grep -q "1"; then
        echo "Reverse path filtering is enabled."
    else
        echo "Reverse path filtering is not enabled."
    fi
}

# Apply sysctl configurations
apply_sysctl_configurations() {
    echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.conf
    sysctl -p
    echo "Applied reverse path filtering configuration."
}

# Check for presence of antivirus software
check_antivirus_software() {
    if command -v clamav > /dev/null; then
        echo "ClamAV antivirus software is installed."
    else
        echo "ClamAV antivirus software is not installed."
    fi
}

# Install antivirus software (ClamAV)
install_antivirus_software() {
    apt-get install clamav clamav-daemon -y
    systemctl start clamav-freshclam
    systemctl enable clamav-freshclam
    echo "ClamAV antivirus software installed and enabled."
}

# Check for system integrity monitoring tool
check_system_integrity_monitoring() {
    if command -v aide > /dev/null; then
        echo "AIDE system integrity monitoring tool is installed."
    else
        echo "AIDE system integrity monitoring tool is not installed."
    fi
}

# Install system integrity monitoring tool (AIDE)
install_system_integrity_monitoring() {
    apt-get install aide aide-common -y
    aideinit
    echo "AIDE system integrity monitoring tool installed."
}


# Function to ensure /tmp is a separate partition
check_tmp_partition() {
    if findmnt --kernel /tmp | grep -q '/tmp'; then
        echo "/tmp is mounted as a separate partition."
    else
        echo "/tmp is not a separate partition."
    fi
}

# Function to set correct mount options for /tmp
configure_tmp_partition() {
    echo "tmpfs /tmp tmpfs defaults,rw,nosuid,nodev,noexec,relatime,size=2G 0 0" >> /etc/fstab
    mount -o remount /tmp
    echo "Configured mount options for /tmp."
}

# Function to ensure /var is a separate partition
check_var_partition() {
    if findmnt --kernel /var | grep -q '/var'; then
        echo "/var is mounted as a separate partition."
    else
        echo "/var is not a separate partition."
    fi
}

# Function to set correct mount options for /var
configure_var_partition() {
    echo "<device> /var <fstype> defaults,rw,nosuid,nodev,relatime 0 0" >> /etc/fstab
    mount -o remount /var
    echo "Configured mount options for /var."
}

# Function to ensure /var/tmp is a separate partition
check_var_tmp_partition() {
    if findmnt --kernel /var/tmp | grep -q '/var/tmp'; then
        echo "/var/tmp is mounted as a separate partition."
    else
        echo "/var/tmp is not a separate partition."
    fi
}

# Function to set correct mount options for /var/tmp
configure_var_tmp_partition() {
    echo "<device> /var/tmp <fstype> defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
    mount -o remount /var/tmp
    echo "Configured mount options for /var/tmp."
}



# Functions for /var/tmp partition
check_var_tmp_partition_options() {
    if findmnt --kernel /var/tmp | grep -q 'nosuid' && findmnt --kernel /var/tmp | grep -q 'nodev' && findmnt --kernel /var/tmp | grep -q 'noexec'; then
        echo "/var/tmp partition options are correctly set."
    else
        echo "/var/tmp partition options are not correctly set."
    fi
}

configure_var_tmp_partition_options() {
    echo "<device> /var/tmp <fstype> defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
    mount -o remount /var/tmp
    echo "Configured mount options for /var/tmp."
}

# Functions for /var/log partition
check_var_log_partition_options() {
    if findmnt --kernel /var/log | grep -q 'nosuid' && findmnt --kernel /var/log | grep -q 'nodev' && findmnt --kernel /var/log | grep -q 'noexec'; then
        echo "/var/log partition options are correctly set."
    else
        echo "/var/log partition options are not correctly set."
    fi
}

configure_var_log_partition_options() {
    echo "<device> /var/log <fstype> defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
    mount -o remount /var/log
    echo "Configured mount options for /var/log."
}

# Functions for /var/log/audit partition
check_var_log_audit_partition_options() {
    if findmnt --kernel /var/log/audit | grep -q 'nosuid' && findmnt --kernel /var/log/audit | grep -q 'nodev' && findmnt --kernel /var/log/audit | grep -q 'noexec'; then
        echo "/var/log/audit partition options are correctly set."
    else
        echo "/var/log/audit partition options are not correctly set."
    fi
}

configure_var_log_audit_partition_options() {
    echo "<device> /var/log/audit <fstype> defaults,rw,nosuid,nodev,noexec,relatime 0 0" >> /etc/fstab
    mount -o remount /var/log/audit
    echo "Configured mount options for /var/log/audit."
}

# Main function
main() {
    check_ssh_root_login
    implement_ssh_root_login
    check_unnecessary_accounts
    remove_unnecessary_accounts
    check_password_expiration_policy
    implement_password_expiration_policy
    check_ungrouped_files
    fix_ungrouped_files
    check_unowned_files
    fix_unowned_files
    check_world_writable_files
    fix_world_writable_files
    check_audit_events
    enable_audit_events
    check_unnecessary_services
    disable_unnecessary_services
    check_shadow_file_permissions
    set_shadow_file_permissions
    check_system_patches
    update_system_patches
    check_noexec_on_tmp
    set_noexec_on_tmp
    check_firewall_configuration
    configure_firewall
    check_selinux_status
    set_selinux_enforcing
    check_plex_permissions_ownership
    secure_plex_permissions_ownership
    check_automatic_updates
    enable_automatic_updates
    check_ssh_protocol_version
    set_ssh_protocol_version
    check_sysctl_configurations
    apply_sysctl_configurations
    check_antivirus_software
    install_antivirus_software
    check_system_integrity_monitoring
    install_system_integrity_monitoring
    check_tmp_partition
    configure_tmp_partition
    check_var_partition
    configure_var_partition
    check_var_tmp_partition
    configure_var_tmp_partition
    check_var_tmp_partition_options
    configure_var_tmp_partition_options
    check_var_log_partition_options
    configure_var_log_partition_options
    check_var_log_audit_partition_options
    configure_var_log_audit_partition_options
}

# Execute main function
main
