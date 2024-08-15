#!/bin/bash
# Creates N number of users with the same password for all of them
# Directory .ssh will be created for all of the users with public/private keys
# Created by simon
# Date 2024/8/14 - Y/M/D

# Variables to change:
LOGFILE=/var/log/log.txt
USERNAME=tom
PASSWD=student
PERMISSIONLEVEL=600

echo "--- CREATE MULTIPLE USERS ---"
echo

# Function to log messages
log_message() {
    local message="$1"
    echo "$message" >> $LOGFILE
}

# Function to create a new user
create_user() {
    local username="$1"
    if useradd -m $username && echo "$username:$PASSWD" | chpasswd; then
        log_message "[INFO] Created new user $username"
    else
        log_message "[ERROR] Unable to create user and password"
        exit 1
    fi
}

# Function to create .ssh directory and generate keys
create_ssh_keys() {
    local username="$1"
    if mkdir -p /home/$username/.ssh && ssh-keygen -t rsa -N "" -f /home/$username/.ssh/sshkey > /dev/null; then
        log_message "[INFO] Created directory .ssh and generated keys"
    else
        log_message "[ERROR] Unable to create .ssh directory or generate keys"
        exit 1
    fi
}

# Function to set permissions for private key
set_permissions() {
    local username="$1"
    if chmod $PERMISSIONLEVEL /home/$username/.ssh/sshkey; then
        log_message "[INFO] Set permissions for private key file"
    else
        log_message "[ERROR] Unable to set permissions for private key"
        exit 1
    fi
}

# Function to change ownership of the .ssh folder
change_ownership() {
    local username="$1"
    if sudo chown -R $username:$username /home/$username/.ssh; then
        log_message "[INFO] Changed ownership of the .ssh folder"
    else
        log_message "[ERROR] Unable to change ownership of the .ssh folder"
        exit 1
    fi
}

# Infinite loop
while : ; do

    echo "Enter number of users to create:"
    read NUMUSERS

    # Create a log file, write info and create basic structure
    touch $LOGFILE
    log_message "# ------------------------------------------------"
    log_message "Date: $(date)"
    log_message ""

    # Check whether the input number is positive
    if [[ ! "$NUMUSERS" =~ ^[1-9][0-9]*$ ]]; then
        echo "[ERROR] Input number is not a positive integer!"
        continue
    fi

    # Loop to iterate over the number of users set by user
    for ((i=1; i<=NUMUSERS; i++)); do

        username="$USERNAME$i"
        log_message "[INFO] ${i} User: $username"

        create_user $username
        create_ssh_keys $username
        set_permissions $username
        change_ownership $username

    done

    # End the while loop and jump out
    break
done

echo "Successfully created $NUMUSERS users."
echo
echo "Script ended"
