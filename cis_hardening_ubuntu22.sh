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
}

# Execute main function
main
