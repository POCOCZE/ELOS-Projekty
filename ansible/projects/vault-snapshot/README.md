# Ansible Vault Snapshot and S3 Backup Automation

## Introduction

This project automates HashiCorp Vault Raft backend backups using Ansible for orchestration. It leverages Ansible playbooks to perform end-to-end automation, from creating a dedicated `vault-backup` user and setting up cron jobs to executing scripts for local Vault snapshots and optional synchronization of these snapshots to remote S3-compatible storage. The automation ensures consistent, scheduled backups with robust security measures and comprehensive logging.

## Objectives

### Ansible Playbook Objectives and Implementation Status

* :white_check_mark: **Automated End-to-End Orchestration**: Uses Ansible playbooks to automate the entire backup process, including script deployment, user and cron job setup.
* :white_check_mark: **Variable-Driven Configuration**: All essential configurations, such as Vault addresses, tokens, S3 settings, and feature toggles, are managed through a centralized Ansible variables file.
* :white_check_mark: **Optional S3 Backup**: Provides an optional feature, configurable via Ansible variables, to synchronize local snapshots to S3-compatible object storage for offsite redundancy.
* :white_check_mark: **Optional S3 Delete**: For S3 backups, offers a further optional setting to automatically delete remote files when they are removed locally, mirroring the snapshot lifecycle on S3.

### Vault Raft Snapshot Script Objectives and Implementation Status

* :white_check_mark: **Automated Vault Raft Snapshots**: Automatically create snapshots of Vault Raft.
* :white_check_mark: **Periodic Execution**: Run script periodically using `cron`.
* :white_check_mark: **Secure Credential Management**: Securely store Vault credentials.
* :white_check_mark: **Base64 Encoding for Config Values**: Obfuscate config values with Base64.
* :white_check_mark: **Snapshot Rotation**: Rotate snapshots, keeping recent ones.
* :white_check_mark: **Journalctl Logging**: Use systemd journal for logging using `journalctl`.
* :white_check_mark: **Dedicated User**: Run under low-privilege `vault-backup` user.
* :white_check_mark: **Restrictive File Permissions**: Set secure file permissions.
* :white_check_mark: **Security Considerations**: Implement and document security best practices.

### Optional S3 Snapshot Sync Script Objectives and Implementation Status

* :white_check_mark: **Automated S3 Sync**: Automatically syncs local snapshot folder to S3 using `s3cmd`.
* :white_check_mark: **Periodic Execution**: Run script periodically using `cron`.
* :white_check_mark: **Journalctl Logging**: Logs actions and errors to `journalctl`.
* :white_check_mark: **Optional File Deletion**: Supports optional deletion of remote files on S3 to mirror local folder.

## Usage Instructions

### Dependencies

- JQ
- Vault Instance Unsealed
- 

To utilize the Ansible Vault Snapshot and S3 Backup Automation, follow these steps:

### 1. Configure Ansible Inventory (`hosts.ini`)

Ensure your Ansible inventory file (`hosts.ini` or your configured inventory path) is correctly set up to target the Linux host where Vault Raft snapshots will be managed. Define the hostname or IP address of your target machine under a relevant group (e.g., `vault-snapshot`) by renaming the `vault.example.com`.

```ini
[vault-snapshot]
vault.example.com ansible_user=<ansible_user> ansible_become=true
```

Replace placeholder `<ansible_user>` with your actual environment details. Ensure the **Ansible user has `sudo` privileges on the target host**.

### 2. Customize Ansible Variables (`variables.yml`)

Modify the `variables.yml` file in your Ansible project directory to customize the automation to your environment. Key variables to configure include:

* **Vault Settings**: `vault_addr`, `vault_token` for snapshot creation script.
* **S3 Settings (for optional S3 backup)**: `s3.host`, `s3.bucket_name`, `s3.access_key`, `s3.secret_key`, `s3:bucket_name`.
* **Script Settings**: `snapshots` (snapshot destination), `s3.deletion_on_local_removal.enable` (boolean to enable/disable S3 remote file deletion).
* **User and Path Settings**: Adapt user names and directory paths if needed, although defaults are generally suitable.

### 3. Run the Ansible Playbook

Execute the Ansible playbook using the `ansible-playbook` command from your Ansible control machine. Navigate to your Ansible project directory in the terminal and run:

```bash
ansible-playbook -i hosts.ini playbook.yml -v
```

This command will execute the playbook, automating the Vault Raft snapshot process and optionally configuring S3 backups based on the variables defined in `variables.yml`.

### 4. S3cmd Prerequisite (for S3 Backup Feature)

If you intend to use the optional S3 snapshot synchronization feature, ensure that `s3cmd` is installed on the target Linux host where the Ansible playbook is executed. The playbook itself **does not install** `s3cmd`. If `s3cmd` is not installed and the S3 backup feature is enabled in `variables.yml`, the S3 sync part of the automation will fail!

If you do not wish to use the S3 backup feature, you can simply leave the S3 related variables in `variables.yml` unset (default), and the core Vault snapshot functionality will operate without `s3cmd`.

## Check Journalctl Logs

To check generated journalctl logs that have been generated throughout the script cron runs, switch to created system user `vault-backup`:

```bash
sudo su - vault-backup
```

Journalctl logs of the `Vault Raft Snapshot Script`:

```bash
journalctl -t vault-snapshot
```

Optional Journalctl logs of the `S3 Snapshot Sync Script`:

```bash
journalctl -t snapshot-sync
```

## Common Mistakes and Troubleshooting

* **Incorrect Vault Credentials**: Ensure `vault_addr` and `vault_token` in `variables.yml` are accurate and valid for your Vault instance. Incorrect credentials will prevent the snapshot script from authenticating with Vault.
* **Missing or Incorrect S3 Credentials**: If using S3 backup, double-check `s3.host`, `s3.bucket_name`, `s3.access_key`, and `s3.secret_key` in `variables.yml`. Incorrect S3 credentials will cause the S3 synchronization to fail.
* **`s3cmd` Not Installed (S3 Backup Enabled)**: If you have enabled the S3 backup feature but `s3cmd` is not installed on the target host, the playbook will proceed, but the S3 synchronization step will fail. Verify `s3cmd` is present if using S3 backup. Playbook automatically test the S3 connection first to ensure correct credintials.
* **Incorrect `hosts.ini` or Ansible User Setup**: Problems with Ansible connecting to the target host, such as incorrect host IP in `hosts.ini`, SSH key issues, or insufficient privileges for the Ansible user, will prevent the playbook from running successfully. Verify Ansible connectivity and user privileges before execution.
* **File Permission Issues**: While the playbook sets file permissions, manually altered permissions on script files or directories on the target host, especially within `/home/vault-backup/`, may cause script execution failures. Ensure permissions are as intended by the playbook.

## Expected Output

### Ansible Playbook Run

```bash
ansible-playbook -i hosts.ini projects/vault-snapshot/playbook/playbook.yml -Kk -v
```


```bash
Using /root/ELOS-Projekty/ansible/ansible.cfg as config file
SSH password: 
BECOME password[defaults to SSH password]: 
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [Vault Raft Snapshot Automation Script] ********************************************************************

TASK [Set basic facts for user] *********************************************************************************
ok: [localhost] => {"ansible_facts": {"homedir": "/home/vault-backup"}, "changed": false}

TASK [Create locked user] ***************************************************************************************
[WARNING]: The input password appears not to have been hashed. The 'password' argument must be encrypted for
this module to work properly.
ok: [localhost] => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"}, "append": false, "changed": false, "comment": "", "group": 989, "home": "/home/********", "move_home": false, "name": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER", "password": "NOT_LOGGING_PASSWORD", "shell": "/bin/bash", "state": "present", "uid": 996}

TASK [Set correct permissions to home directory] ****************************************************************
changed: [localhost] => {"changed": true, "gid": 989, "group": "vault-backup", "mode": "0700", "owner": "vault-backup", "path": "/home/vault-backup/.secret", "size": 4096, "state": "directory", "uid": 996}

TASK [Create snapshot directory with appropriate permissions and ownership] *************************************
ok: [localhost] => {"changed": false, "gid": 989, "group": "vault-backup", "mode": "0700", "owner": "vault-backup", "path": "/home/vault-backup/snapshots", "size": 4096, "state": "directory", "uid": 996}

TASK [Copy secret file] *****************************************************************************************
changed: [localhost] => {"changed": true, "checksum": "41be627e4f5e613ae7dce2b6cc4426b207c9b729", "dest": "/home/vault-backup/.secret/vault-backup.json", "gid": 989, "group": "vault-backup", "mode": "0600", "owner": "vault-backup", "path": "/home/vault-backup/.secret/vault-backup.json", "size": 119, "state": "file", "uid": 996}

TASK [Copy Vault Snapshot script] *******************************************************************************
changed: [localhost] => {"changed": true, "checksum": "13c66687ec186dbf8167aae43c2d29f7029cf70f", "dest": "/home/vault-backup/vault-snapshot.sh", "gid": 989, "group": "vault-backup", "md5sum": "27c7490adb5e35149bfd7383d7b785f7", "mode": "0700", "owner": "vault-backup", "size": 7222, "src": "/root/.ansible/tmp/ansible-tmp-1740081877.5192058-10741-83896720901228/source", "state": "file", "uid": 996}

TASK [Add Vault Snaphot script to Crontab] **********************************************************************
[WARNING]: Module remote_tmp /home/vault-backup/.ansible/tmp did not exist and was created with a mode of 0700,
this may cause issues when running as another user. To avoid this, create the remote_tmp dir with the correct
permissions manually
changed: [localhost] => {"changed": true, "envs": [], "jobs": ["Run Vault Snaphot script Hourly"]}

TASK [Ensuring s3cmd tool is installed] *************************************************************************
skipping: [localhost] => {"changed": false, "false_condition": "s3.enabled == true", "skip_reason": "Conditional result was False"}

TASK [Test s3 connection on the fly] ****************************************************************************
skipping: [localhost] => {"changed": false, "false_condition": "s3.enabled == true", "skip_reason": "Conditional result was False"}

TASK [Copy s3 backup bash script] *******************************************************************************
skipping: [localhost] => {"changed": false, "false_condition": "s3.enabled == true", "skip_reason": "Conditional result was False"}

TASK [Add the s3 backup script to cron] *************************************************************************
skipping: [localhost] => {"changed": false, "false_condition": "s3.enabled == true", "skip_reason": "Conditional result was False"}

TASK [S3 Configured successfully] *******************************************************************************
skipping: [localhost] => {"false_condition": "s3.enabled == true"}

PLAY RECAP ******************************************************************************************************
localhost                  : ok=7    changed=4    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0
```

### Journalctl Output

Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11536]: [2025-02-20] # -------------------------------------------------------------------
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11538]: [2025-02-20] # Vault Raft Snapshot Script Execution Started
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11541]: [2025-02-20] # Date: 2025-02-20
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11543]: [2025-02-20] # -------------------------------------------------------------------
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11553]: [2025-02-20] Successfully loaded and decoded VAULT_ADDR and VAULT_TOKEN from configuration file: /home/vault-backup/.secret/vault-backup.json
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11555]: [2025-02-20] --- Checking Vault Status ---
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11560]: [2025-02-20] Vault is reachable and Vault CLI is configured correctly.
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11562]: [2025-02-20] --- Gathering Raft Leader Address ---
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11570]: [2025-02-20] Successfully determined Raft leader address: vault-0.vault-internal:8201
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11572]: [2025-02-20] --- Creating Raft Snapshot ---
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11579]: [2025-02-20] Successfully created Raft snapshot: vault-snapshot-2025-02-20-20-28.snap
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11581]: [2025-02-20] --- Managing Snapshot Retention ---
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11583]: [2025-02-20] Checking snapshot file count and managing retention.
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11587]: [2025-02-20] Current snapshot file count: 1, maximum allowed: 10.
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11589]: [2025-02-20] Snapshot count is within the limit. No files to delete.
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11591]: [2025-02-20] # -------------------------------------------------------------------
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11593]: [2025-02-20] # Vault Raft Snapshot Script Execution Completed Successfully
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11596]: [2025-02-20] # Date: 2025-02-20
Feb 20 20:28:01 ubuntu-ansible vault-snapshot[11598]: [2025-02-20] # -------------------------------------------------------------------