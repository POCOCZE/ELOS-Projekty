#!/bin/bash
# Creates N number of users with same password for all of them
# Directory .ssh will be created for all of the users with public/private keys
# Created by simon
# Date 2024/8/9 - Y/M/D

#Variables:
LOGFILE=/var/log/log.txt
USERNAME=test0
PASSWD=student
PERMISSIONLEVEL=600
# ---------------------------------------

echo "--- CREATE MULTIPLE USERS ---"
echo

echo "Enter number of users to create:"
read NUMUSERS

#Create a log file, write info a create basic structure
touch $LOGFILE
echo "# Date: " >> $LOGFILE
echo "$(date)" >> $LOGFILE
echo >> $LOGFILE
echo "# --------------------------------" >> $LOGFILE
echo >> $LOGFILE

# lLoop to iterate over the number of users set by user
for ((i=1; i<=$NUMUSERS; i++)); do
	
	echo "[INFO] ${i} User: $USERNAME${i}" >> $LOGFILE

	# Create new user
	if useradd -m $USERNAME${i} && echo "$USERNAME${i}:$PASSWD" | chpasswd; then
		echo "[INFO] Created new user $USERNAME${i}\n" >> $LOGFILE
	else
		echo "[ERROR] Unable to create user and password" >> $LOGFILE
		exit 1
	fi
	
	# Create .ssh dir and generate there keys
	# mkdir -p /home/$USERNAME${i}/.ssh
	# ssh-keygen -t rsa -N "" -f /home/$USERNAME${i}/.ssh/sshkey
	# echo "[INFO] Crated directory .ssh" >> $LOGFILE
	# echo "[INFO] Created public/private keys" >> $LOGFILE

	if mkdir -p /home/$USERNAME${i}/.ssh && ssh-keygen -t rsa -N "" -f /home/$USERNAME${i}/.ssh/sshkey; then
		echo "[INFO] Created directory .ssh and generated keys" >> $LOGFILE
	else
		echo "[ERROR] Unable to create .ssh directory or generate keys" >> $LOGFILE
		exit 1
	fi

	# Permissions for private key
	if chmod $PERMISSIONLEVEL /home/$USERNAME${i}/.ssh/sshkey; then
		echo "[INFO] Set permissions for private key file" >> $LOGFILE
	else
		echo "[ERROR] Unable to set permissions for private key" >> $LOGFILE
		exit 1
	fi

	# Change the ownership of the .ssh folder to $USERNAME
	chown -R $USERNAME${i}:$USERNAME${i} /home/$USERNAME${i}/.ssh
done

echo "Successfully created $NUMUSERS users."
echo
echo "Script ended"
