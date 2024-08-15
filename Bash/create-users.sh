#!/bin/bash
# Creates N number of users with same password for all of them
# Directory .ssh will be created for all of the users with public/private keys
# Created by simon
# Date 2024/8/13 - Y/M/D

#Variables to change:
LOGFILE=/var/log/log.txt
USERNAME=tom
PASSWD=student
PERMISSIONLEVEL=600


echo "--- CREATE MULTIPLE USERS ---"
echo

#infinite loop
while : ; do

	echo "Enter number of users to create:"
	read NUMUSERS

	#Create a log file, write info a create basic structure
	touch $LOGFILE
	echo "# ------------------------------------------------" >> $LOGFILE
	# echo "# Date: " >> $LOGFILE
	echo "Date: $(date)" >> $LOGFILE
	echo >> $LOGFILE
	echo >> $LOGFILE

	# Check whether the input number is positive
	# Implemented regex - regular expression - checks whether input read number is positive integer
	# e.g.: Numbers like 1.5, 01, abc will make an error message to appear on screen
	if [[ "$NUMUSERS" =~ ^[1-9][0-9]*$ ]]; then
		echo "[ERROR] Input number is not a positive!"
		continue
	fi

	# lLoop to iterate over the number of users set by user
	for ((i=1; i<=NUMUSERS; i++)); do # The dollar sign can be ommited there
		
		echo "[INFO] ${i} User: $USERNAME${i}" >> $LOGFILE

		# Create new user
		if useradd -m $USERNAME${i} && echo "$USERNAME${i}:$PASSWD" | chpasswd; then
			echo "[INFO] Created new user $USERNAME${i}\n" >> $LOGFILE
		else
			echo "[ERROR] Unable to create user and password" >> $LOGFILE
			exit 1
		fi
		
		# Create .ssh dir and generate there keys
		if mkdir -p /home/$USERNAME${i}/.ssh && ssh-keygen -t rsa -N "" -f /home/$USERNAME${i}/.ssh/sshkey > /dev/null; then # special file that discards any input
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
		if sudo chown -R $USERNAME${i}:$USERNAME${i} /home/$USERNAME${i}/.ssh; then
			echo "[INFO] Changed ownership of the .ssh forder" >> $LOGFILE
		else
			echo "[ERROR] Unable to change ownership of the .ssh forder" >> $LOGFILE
			exit 1
		fi

	done

	# End the while loop and jump out
	break
done

echo "Successfully created $NUMUSERSs users."
echo
echo "Script ended"
