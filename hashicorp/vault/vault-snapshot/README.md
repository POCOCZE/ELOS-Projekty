# Vault Raft Snapshot Automation Script

## Introduction

The bash script is designed to automate the process of taking snapshots of a HashiCorp Vault Raft backend. The script is intended to run periodically using `cron` on a Linux system and includes features for secure credential management, snapshot rotation, and systemd journal logging. The script enhances security by using a dedicated user, restrictive file permissions, and Base64 encoding of sensitive configuration values.

## Objectives

**Vault Raft snapshot Automation Script and Implementation Status**

* :white_check_mark: **Automated Vault Raft Snapshots**: Automatically create snapshots of Vault Raft.
* :white_check_mark: **Periodic Execution**: Run script periodically using `cron`.
* :white_check_mark: **Secure Credential Management**: Securely store Vault credentials.
* :white_check_mark: **Base64 Encoding for Config Values**: Obfuscate config values with Base64.
* :white_check_mark: **Snapshot Rotation**: Rotate snapshots, keeping recent ones.
* :white_check_mark: **Journalctl Logging**: Use systemd journal for logging using `journalctl`.
* :white_check_mark: **Dedicated User**: Run under low-privilege `vault-backup` user.
* :white_check_mark: **Restrictive File Permissions**: Set secure file permissions.
* :white_check_mark: **Security Considerations**: Implement and document security best practices.
* :heavy_minus_sign: **Production Environment Implementation**: Not yet in production.
* :heavy_minus_sign: **Due Date Implementation**: Production implementation by today not achieved.

**Optional S3 Snapshot Sync Script and Implementation Status**

* :white_check_mark: **Automated S3 Sync**: Automatically syncs local snapshot folder to S3 using `s3cmd`.
* :white_check_mark: **Auto Bucket Creation**: Automatically creates s3 buckets if not exist to backup snapshots folder.
* :white_check_mark: **Periodic Execution**: Script runs periodically using `cron`.
* :white_check_mark: **Ansible Configurable**: Configurable via Ansible variables for flexible deployment.
* :white_check_mark: **Explicit Credentials**:  Handles S3 credentials directly in script via Ansible variables.
* :white_check_mark: **Journalctl Logging**: Logs actions and errors to `journalctl`.
* :white_check_mark: **Optional File Deletion**: Supports optional deletion of remote files on S3 to mirror local folder.

## Usage Instructions

### 1. Create the `vault-backup` User

Execute the following commands as `root` or a user with `sudo` privileges to create the dedicated `vault-backup` user:

```bash
sudo useradd -r -m -d /home/vault-backup -s /bin/bash vault-backup
sudo passwd vault-backup # Set a strong password when prompted
# Optional: Lock the user's password to prevent direct login
# sudo passwd -l vault-backup
```

### 2. Create Configuration File

Switch to the vault-backup user:

```bash
sudo su - vault-backup
```

Create the .secret directory and the vault-backup.json configuration file with Base64 encoded values for VAULT_ADDR and VAULT_TOKEN:

```bash
mkdir ~/.secret
VAULT_ADDR_PLAIN="https://vault.example.com:8200" # Replace with your Vault address
VAULT_TOKEN_PLAIN="YOUR_VAULT_TOKEN_HERE" # Replace with your Vault token

VAULT_ADDR_ENCODED=$(echo -n "$VAULT_ADDR_PLAIN" | base64)
VAULT_TOKEN_ENCODED=$(echo -n "$VAULT_TOKEN_PLAIN" | base64)

cat <<EOF > ~/.secret/vault-backup.json
{
  "VAULT_ADDR": "$VAULT_ADDR_ENCODED",
  "VAULT_TOKEN": "$VAULT_TOKEN_ENCODED"
}
EOF
chmod 0600 ~/.secret/vault-backup.json
```

Important: Replace "<https://vault.example.com:8200>" and "YOUR_VAULT_TOKEN_HERE" with your actual Vault address and a valid Vault token.

### 3. Create Snapshot Directory, Set Permissions

As root or a user with sudo privileges, create the snapshot directory and set appropriate ownership and permissions:

```bash
sudo mkdir -p /home/vault-backup/snapshots
sudo chown vault-backup:vault-backup /home/vault-backup/snapshots
sudo chmod 0700 /home/vault-backup/snapshots
sudo chmod 0700 /home/vault-backup
```

### 4. Create and Configure the shapshot.sh Script

Create the shapshot.sh script file (e.g., /home/vault-backup/shapshot.sh) with the bash script code provided earlier (now using journalctl for logging### ). Ensure the script is owned by the vault-backup user and is executable:

```bash
sudo chown vault-backup:vault-backup /home/vault-backup/shapshot.sh
sudo chmod +x /home/vault-backup/shapshot.sh
```

### 5. Schedule Script Execution with Cron

Edit the crontab for the vault-backup user:

```bash
sudo crontab -u vault-backup -e
```

Add the following line to run the script hourly:

```bash
0 * * * * /home/vault-backup/shapshot.sh
```

### 6. Verify and Monitor

* Initial Run: Manually run the script as the vault-backup user to test it:

```bash
sudo su - vault-backup -c /home/vault-backup/shapshot.sh
```

* Check Logs using journalctl: Monitor logs using journalctl. To view logs specifically from the vault-snapshot script, use:

```bash
journalctl -t vault-snapshot
```

To follow logs in real-time:

```bash
journalctl -f -t vault-snapshot
```

### TODO

nothing here
