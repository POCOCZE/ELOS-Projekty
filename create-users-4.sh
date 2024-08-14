#!/bin/bash
# Creates N number of users with same password for all of them
# Directory .ssh will be created for all of the users with public/private keys
# Created by simon
# Date 2024/8/8 - Y/M/D

# Lower cammel case is used for changing variables to store data for a limited time
# E.g.: username
# Capital case is used to Constants and env variables
# E.g.: USERNAME, PASSWD, ...

##-----------##
## Variables ##
##-----------##

LOGFILE=/var/log/log.txt
USERNAME=tom
PASSWD=student
PERMISSIONLEVEL=600

##-----------##
## Functions ##
##-----------##

# Log message into file
log_message() {
    local message="$1"
    echo "$message" >> $LOGFILE
}

# Create new user
create_user() {
    local username="$1"
    if useradd -m $username && echo "$username:$PASSWD" | chpasswd; then
        log_message "[INFO] Created new user $username"
    else
        log_message "[ERROR] Unable to create user and password"
        exit 1
    fi
}    

# Create .ssh dir and generate there keys
# dir /dev/null is a special file that discards any input
create_ssh_dir_and_keys() {
    local username="$1"
    if mkdir -p /home/$username/.ssh && ssh-keygen -t rsa -N "" -f /home/$username/.ssh/sshkey > /dev/null; then
        log_message "[INFO] Created directory .ssh and generated keys"
    else
        log_message "[ERROR] Unable to create .ssh directory or generate keys"
        exit 1
    fi
}

# Permissions for private key
set_permissions_priv_key() {
    local username="$1"
    if chmod $PERMISSIONLEVEL /home/$username/.ssh/sshkey; then
        log_message "[INFO] Set permissions for private key file"
    else
        log_message "[ERROR] Unable to set permissions for private key"
        exit 1
    fi
}

# Change the ownership of the .ssh folder to $USERNAME
change_ssh_dir_owner() {
    local username="$1"
    if sudo chown -R $username:$username /home/$username/.ssh; then
        log_message "[INFO] Changed ownership of the .ssh forder"
    else
        log_message "[ERROR] Unable to change ownership of the .ssh forder"
        exit 1
    fi
}

##------##
## Main ##
##------##

# Create a log file, write info and create basic structure
touch $LOGFILE
log_message "# ------------------------------------------------"
log_message "Date: $(date)"
log_message ""

# Write to user
echo "--- CREATE MULTIPLE USERS ---"
echo

while : ; do
	echo "Enter number of users to create:"
	read NUMUSERS

	# Check whether the input number is positive
	# Implemented regex - regular expression - checks whether input read number is positive integer
	# e.g.: Numbers like 1.5, 01, abc will make an error message to appear on screen
	if [[ ! "$NUMUSERS" =~ ^[1-9][0-9]*$ ]]; then
		echo "[ERROR] Input number is not a positive integer!"
        echo
        echo
        # Skip current iteration and move the next
		continue
	fi

	# Loop to iterate over the number of users set by user
    # Dolar sign can be ommited because of aritmetic context in the condition
	for ((i=1; i<=NUMUSERS; i++)); do
        username=$USERNAME$i
        log_message "[INFO] ${i} User: $username"

        create_user $username
        create_ssh_dir_and_keys $username
        set_permissions_priv_key $username
        change_ssh_dir_owner $username
	done
	# End the while loop and jump out
	break
done

echo "Successfully created $NUMUSERS users."
echo
echo "Script ended"
