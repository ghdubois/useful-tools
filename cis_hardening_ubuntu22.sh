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

# Function to configure rsyslog default file permissions
configure_rsyslog_permissions() {
    echo "\$FileCreateMode 0640" >> /etc/rsyslog.conf
    systemctl restart rsyslog
    echo "Configured rsyslog default file permissions."
}

# Function to set permissions on cron files
set_cron_permissions() {
    chown root:root /etc/crontab
    chmod og-rwx /etc/crontab
    chown root:root /etc/cron.hourly
    chmod og-rwx /etc/cron.hourly
    chown root:root /etc/cron.daily
    chmod og-rwx /etc/cron.daily
    chown root:root /etc/cron.weekly
    chmod og-rwx /etc/cron.weekly
    chown root:root /etc/cron.monthly
    chmod og-rwx /etc/cron.monthly
    chown root:root /etc/cron.d
    chmod og-rwx /etc/cron.d
    echo "Set permissions on cron files."
}

# Function to restrict access to the su command
restrict_su_command() {
    groupadd sugroup
    echo "auth required pam_wheel.so use_uid group=sugroup" >> /etc/pam.d/su
    echo "Restricted access to the su command."
}

# Function to configure SSH settings
configure_ssh_settings() {
    sed -i '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i '/^X11Forwarding/s/^.*$/X11Forwarding no/' /etc/ssh/sshd_config
    sed -i '/^MaxAuthTries/s/^.*$/MaxAuthTries 4/' /etc/ssh/sshd_config
    sed -i '/^MaxStartups/s/^.*$/MaxStartups 10:30:60/' /etc/ssh/sshd_config
    sed -i '/^LoginGraceTime/s/^.*$/LoginGraceTime 60/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "Configured SSH settings."
}

# Function to set permissions on sshd_config
set_sshd_config_permissions() {
    chown root:root /etc/ssh/sshd_config
    chmod og-rwx /etc/ssh/sshd_config
    echo "Set permissions on sshd_config."
}

# Function to configure sudo log file
configure_sudo_log_file() {
    echo "Defaults logfile='/var/log/sudo.log'" >> /etc/sudoers
    echo "Configured sudo log file."
}

# Function to configure password policies
configure_password_policies() {
    apt install libpam-pwquality
    echo "minlen = 14" >> /etc/security/pwquality.conf
    echo "minclass = 4" >> /etc/security/pwquality.conf
    echo "PASS_MIN_DAYS 1" >> /etc/login.defs
    echo "PASS_MAX_DAYS 365" >> /etc/login.defs
    useradd -D -f 30
    echo "Configured password policies."
}

# Function to configure file permissions
configure_file_permissions() {
    chown root:root /etc/shadow
    chmod u-x,g-wx,o-rwx /etc/shadow
    chown root:root /etc/shadow-
    chmod u-x,g-wx,o-rwx /etc/shadow-
    echo "Configured file permissions."
}



# Main function
main() {
    # # SSH root login
    # if ! check_ssh_root_login; then
    #     implement_ssh_root_login
    # fi

    # # Unnecessary accounts
    # if check_unnecessary_accounts; then
    #     remove_unnecessary_accounts
    # fi

    # # Password expiration policy
    # if ! check_password_expiration_policy; then
    #     implement_password_expiration_policy
    # fi

    # # Ungrouped files
    # if check_ungrouped_files; then
    #     fix_ungrouped_files
    # fi

    # # Unowned files
    # if check_unowned_files; then
    #     fix_unowned_files
    # fi

    # # World writable files
    # if check_world_writable_files; then
    #     fix_world_writable_files
    # fi

    # # Audit events
    # if ! check_audit_events; then
    #     enable_audit_events
    # fi

    # # Unnecessary services
    # if check_unnecessary_services; then
    #     disable_unnecessary_services
    # fi

    # # /etc/shadow permissions
    # if ! check_shadow_file_permissions; then
    #     set_shadow_file_permissions
    # fi

    # # System patches
    # if ! check_system_patches; then
    #     update_system_patches
    # fi

    # # Noexec on /tmp
    # if ! check_noexec_on_tmp; then
    #     set_noexec_on_tmp
    # fi

    # # Firewall configuration
    # if ! check_firewall_configuration; then
    #     configure_firewall
    # fi

    # # SELinux status
    # if ! check_selinux_status; then
    #     set_selinux_enforcing
    # fi

    # # Plex permissions and ownership
    # if ! check_plex_permissions_ownership; then
    #     secure_plex_permissions_ownership
    # fi

    # # Automatic updates
    # if ! check_automatic_updates; then
    #     enable_automatic_updates
    # fi

    # # SSH protocol version
    # if ! check_ssh_protocol_version; then
    #     set_ssh_protocol_version
    # fi

    # # Sysctl configurations
    # if ! check_sysctl_configurations; then
    #     apply_sysctl_configurations
    # fi

    # # Antivirus software
    # if ! check_antivirus_software; then
    #     install_antivirus_software
    # fi

    # # System integrity monitoring
    # if ! check_system_integrity_monitoring; then
    #     install_system_integrity_monitoring
    # fi

    # # # Separate partitions
    # # if ! check_tmp_partition; then
    # #     configure_tmp_partition
    # # fi
    # # if ! check_var_partition; then
    # #     configure_var_partition
    # # fi
    # # if ! check_var_tmp_partition; then
    # #     configure_var_tmp_partition
    # # fi
    # # if ! check_var_tmp_partition_options; then
    # #     configure_var_tmp_partition_options
    # # fi
    # # if ! check_var_log_partition_options; then
    # #     configure_var_log_partition_options
    # # fi
    # # if ! check_var_log_audit_partition_options; then
    # #     configure_var_log_audit_partition_options
    # # fi

    # # Rsyslog permissions
    # if ! check_rsyslog_permissions; then
    #     configure_rsyslog_permissions
    # fi

    # # Cron permissions
    # if ! check_cron_permissions; then
    #     set_cron_permissions
    # fi

    # # Restrict su command
    # if ! check_su_command_restriction; then
    #     restrict_su_command
    # fi

    # # SSH settings
    # if ! check_ssh_settings; then
    #     configure_ssh_settings
    # fi

    # # SSHd config permissions
    # if ! check_sshd_config_permissions; then
    #     set_sshd_config_permissions
    # fi

    # # Sudo log file
    # if ! check_sudo_log_file; then
    #     configure_sudo_log_file
    # fi

    # # Password policies
    # if ! check_password_policies; then
    #     configure_password_policies
    # fi

    # # # File permissions
    # # if ! check_file_permissions; then
    # #     configure_file_permissions
    # # fi
    # configure_file_permissions
    

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
    # check_tmp_partition
    # configure_tmp_partition
    # check_var_partition
    # configure_var_partition
    # check_var_tmp_partition
    # configure_var_tmp_partition
    # check_var_tmp_partition_options
    # configure_var_tmp_partition_options
    # check_var_log_partition_options
    # configure_var_log_partition_options
    # check_var_log_audit_partition_options
    # configure_var_log_audit_partition_options
    configure_rsyslog_permissions
    set_cron_permissions
    restrict_su_command
    configure_ssh_settings
    set_sshd_config_permissions
    configure_sudo_log_file
    configure_password_policies
    configure_file_permissions

}

# Execute main function
main
