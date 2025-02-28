# Ansible Vault Snapshot and S3 Backup Automation

## Introduction

This project automates HashiCorp Vault Raft backend backups using Ansible for orchestration. It leverages Ansible playbooks to perform end-to-end automation, from creating a dedicated `vault-backup` user and setting up cron jobs to executing scripts for local Vault snapshots and optional synchronization of these snapshots to remote S3-compatible storage. The automation ensures consistent, scheduled backups with robust security measures and comprehensive logging.

### Table of Contents

- [Ansible Vault Snapshot and S3 Backup Automation](#ansible-vault-snapshot-and-s3-backup-automation)
  - [Introduction](#introduction)
    - [Table of Contents](#table-of-contents)
  - [Objectives](#objectives)
    - [Ansible Playbook Objectives and Implementation Status](#ansible-playbook-objectives-and-implementation-status)
    - [Vault Raft Snapshot Script Objectives and Implementation Status](#vault-raft-snapshot-script-objectives-and-implementation-status)
    - [Optional S3 Snapshot Sync Script Objectives and Implementation Status](#optional-s3-snapshot-sync-script-objectives-and-implementation-status)
      - [⚠️ Note](#️-note)
  - [Usage Instructions](#usage-instructions)
    - [Dependencies](#dependencies)
    - [1. Configure Ansible Inventory (`hosts.ini`)](#1-configure-ansible-inventory-hostsini)
    - [2. Customize Ansible Variables (`variables.yml`)](#2-customize-ansible-variables-variablesyml)
    - [3. Run the Ansible Playbook](#3-run-the-ansible-playbook)
    - [4. S3 Backup Feature Prerequisite](#4-s3-backup-feature-prerequisite)
      - [s3cmd](#s3cmd)
      - [AWS CLI](#aws-cli)
  - [Check Journalctl Logs](#check-journalctl-logs)
  - [Common Mistakes and Troubleshooting](#common-mistakes-and-troubleshooting)
  - [Expected Output](#expected-output)
    - [Ansible Playbook Run](#ansible-playbook-run)
    - [Journalctl Output](#journalctl-output)
  - [TODO](#todo)

## Objectives

### Ansible Playbook Objectives and Implementation Status

- :white_check_mark: **Automated End-to-End Orchestration**: Uses Ansible playbooks to automate the entire backup process, including script deployment, user and cron job setup.
- :white_check_mark: **Variable-Driven Configuration**: All essential configurations, such as Vault addresses, tokens, S3 settings, and feature toggles, are managed through a centralized Ansible variables file.
- :white_check_mark: **Optional S3 Backup**: Provides an optional feature, configurable via Ansible variables, to synchronize local snapshots to S3-compatible object storage for offsite redundancy.
- :white_check_mark: **Optional S3 Delete**: For S3 backups, offers a further optional setting to automatically delete remote files when they are removed locally, mirroring the snapshot lifecycle on S3.

### Vault Raft Snapshot Script Objectives and Implementation Status

- :white_check_mark: **Automated Vault Raft Snapshots**: Automatically create snapshots of Vault Raft.
- :white_check_mark: **Periodic Execution**: Run script periodically using `cron`.
- :white_check_mark: **Secure Credential Management**: Securely store Vault credentials.
- :white_check_mark: **Base64 Encoding for Config Values**: Obfuscate config values with Base64.
- :white_check_mark: **Snapshot Rotation**: Rotate snapshots, keeping recent ones.
- :white_check_mark: **Journalctl Logging**: Use systemd journal for logging using `journalctl`.
- :white_check_mark: **Dedicated User**: Run under low-privilege `vault-backup` user.
- :white_check_mark: **Restrictive File Permissions**: Set secure file permissions.
- :white_check_mark: **Security Considerations**: Implement and document security best practices.
- :white_check_mark: **Timeout Handling for Raft Snapshot**: Implements retries to manage transient network issues.

### Optional S3 Snapshot Sync Script Objectives and Implementation Status

- :white_check_mark: **Automated S3 Sync**: Automatically syncs local snapshot folder to S3 using `s3cmd` or `awscli`.
- :white_check_mark: **Periodic Execution**: Run script periodically using `cron`.
- :white_check_mark: **Journalctl Logging**: Logs actions and errors to `journalctl`.
- :white_check_mark: **Optional File Deletion**: Supports optional deletion of remote files on S3 to mirror local folder.

#### ⚠️ Note

It's important to understand that only one snapshot tool `s3cmd` or `awscli` and thus script can exist at an ansible playbook run. This means that only one s3 backup script version can exists. If user switch from `s3cmd` to `awscli` because of XML errors for example, the old `s3cmd` backup script will be replaced with the `awscli` one. Also when user switch from whatever reason from `awscli` to `s3cmd` the `awscli` command is removed from the system automatically to save space, this functionallity works in reverse too. Auto delete and install packages are only on APT and DNF package manager systems.

## Usage Instructions

### Dependencies

- Vault Instance Unsealed

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

- **Vault Settings**: `vault_addr`, `vault_token` for snapshot creation script.
- **S3 Settings (for optional S3 backup)**: `s3.host`, `s3.bucket_name`, `s3.access_key`, `s3.secret_key`, `s3:bucket_name`.
- **Script Settings**: `snapshots` (snapshot destination), `s3.deletion_on_local_removal.enable` (boolean to enable/disable S3 remote file deletion).
- **User and Path Settings**: Adapt user names and directory paths if needed, although defaults are generally suitable.

### 3. Run the Ansible Playbook

Execute the Ansible playbook using the `ansible-playbook` command from your Ansible control machine. Navigate to your Ansible project directory in the terminal and run:

```bash
ansible-playbook -i hosts.ini playbook.yml -v
```

This command will execute the playbook, automating the Vault Raft snapshot process and optionally configuring S3 backups based on the variables defined in `variables.yml`.

### 4. S3 Backup Feature Prerequisite

#### s3cmd

ONLY FOR NON APT OR DNF BASED SYSTEMS:
If you intend to use the optional S3 snapshot synchronization feature, ensure that `s3cmd` is installed on the target Linux host where the Ansible playbook is executed. The playbook itself **does not install** `s3cmd`. If `s3cmd` is not installed and the S3 backup feature is enabled in `variables.yml`, the S3 sync part of the automation will fail!

If you do not wish to use the S3 backup feature, you can simply leave the S3 related variables in `variables.yml` unset (default), and the core Vault snapshot functionality will operate without `s3cmd`.

#### AWS CLI

Added new functionallity by adding `awscli` as an `s3cmd` alternative in cases where it simply does not work. AWS CLI is more robust, flexible with more features. The tool is mainly focused on the AWS as a whole to control things from CLI, S3 is a benefit which this playbook uses for better user experience. (We hope without errors.)

## Check Journalctl Logs

To check generated journalctl logs that have been generated throughout the script cron runs, use user that have necessary privileges.
Journalctl logs of the `Vault Raft Snapshot Script`:

```bash
journalctl -t vault-snapshot
```

Optional Journalctl logs of the `S3 Snapshot Sync Script`:

```bash
journalctl -t snapshot-sync
```

## Common Mistakes and Troubleshooting

- **Incorrect Vault Credentials**: Ensure `vault_addr` and `vault_token` in `variables.yml` are accurate and valid for your Vault instance. Incorrect credentials will prevent the snapshot script from authenticating with Vault.
- **Missing or Incorrect S3 Credentials**: If using S3 backup, double-check `s3.host`, `s3.bucket_name`, `s3.access_key`, and `s3.secret_key` in `variables.yml`. Incorrect S3 credentials will cause the S3 synchronization to fail.
- **`s3cmd` Not Installed (S3 Backup Enabled)**: ONLY FOR NON APT OR DNF BASED SYSTEMS: If you have enabled the S3 backup feature but `s3cmd` is not installed on the target host, the playbook will proceed, but the S3 synchronization step will fail. Verify `s3cmd` is present if using S3 backup. Playbook automatically test the S3 connection first to ensure correct credintials.
- **Incorrect `hosts.ini` or Ansible User Setup**: Problems with Ansible connecting to the target host, such as incorrect host IP in `hosts.ini`, SSH key issues, or insufficient privileges for the Ansible user, will prevent the playbook from running successfully. Verify Ansible connectivity and user privileges before execution.
- **File Permission Issues**: While the playbook sets file permissions, manually altered permissions on script files or directories on the target host, especially within `/home/vault-backup/`, may cause script execution failures. Ensure permissions are as intended by the playbook.

## Expected Output

### Ansible Playbook Run

```bash
root@ubuntu-ansible:~/ELOS-Projekty/ansible# ansible-playbook -i hosts.ini projects/vault-snapshot/playbook/playbook.yml -Kk -v
```

```log
Using /root/ELOS-Projekty/ansible/ansible.cfg as config file
SSH password: 
BECOME password[defaults to SSH password]: 
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [Vault Raft Snapshot Automation Script] **********************************

TASK [Gathering Facts] ********************************************************
ok: [localhost]

TASK [APT - Install required packages] ****************************************
ok: [localhost] => {"cache_update_time": 1740071608, "cache_updated": false, "changed": false}

TASK [DNF - Install required packages] ****************************************
skipping: [localhost] => {"changed": false, "false_condition": "ansible_pkg_mgr == \"dnf\"", "skip_reason": "Conditional result was False"}

TASK [Set basic facts for user] ***********************************************
ok: [localhost] => {"ansible_facts": {"homedir": "/home/vault-backup"}, "changed": false}

TASK [Create locked user] *****************************************************
[WARNING]: The input password appears not to have been hashed. The 'password' argument must be encrypted for this module to work properly.
ok: [localhost] => {"append": false, "changed": false, "comment": "", "group": 989, "home": "/home/********", "move_home": false, "name": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER", "password": "NOT_LOGGING_PASSWORD", "shell": "/bin/bash", "state": "present", "uid": 996}

TASK [Set correct permissions to home directory] ******************************
changed: [localhost] => {"changed": true, "gid": 989, "group": "vault-backup", "mode": "0700", "owner": "vault-backup", "path": "/home/vault-backup/.secret", "size": 4096, "state": "directory", "uid": 996}

TASK [Create snapshot directory with appropriate permissions and ownership] ***
changed: [localhost] => {"changed": true, "gid": 989, "group": "vault-backup", "mode": "0700", "owner": "vault-backup", "path": "/home/vault-backup/snapshots", "size": 4096, "state": "directory", "uid": 996}

TASK [Copy secret file] *******************************************************
changed: [localhost] => {"changed": true, "checksum": "843cef47e8e3595308e409ba4d35765225dd857a", "dest": "/home/vault-backup/.secret/vault-backup.json", "gid": 989, "group": "vault-backup", "mode": "0600", "owner": "vault-backup", "path": "/home/vault-backup/.secret/vault-backup.json", "size": 119, "state": "file", "uid": 996}

TASK [Copy Vault Snapshot script] *********************************************
ok: [localhost] => {"changed": false, "checksum": "ada97ca9458ec050f581200f69e87eda6e483809", "dest": "/home/vault-backup/vault-snapshot.sh", "gid": 989, "group": "vault-backup", "mode": "0700", "owner": "vault-backup", "path": "/home/vault-backup/vault-snapshot.sh", "size": 8025, "state": "file", "uid": 996}

TASK [Add Vault Snaphot script to Crontab] ************************************
ok: [localhost] => {"changed": false, "envs": [], "jobs": ["Run Vault Snaphot script Hourly", "Run Vault Snaphot script"]}

TASK [APT - Install S3 related packages] **************************************
skipping: [localhost] => {"changed": false, "false_condition": "s3.enabled and not s3.use_alternative_aws_cli", "skip_reason": "Conditional result was False"}

TASK [DNF - Install S3 related packages] **************************************
skipping: [localhost] => {"changed": false, "false_condition": "s3.enabled and not s3.use_alternative_aws_cli", "skip_reason": "Conditional result was False"}

TASK [Ensuring s3cmd tool is installed] ***************************************
skipping: [localhost] => {"changed": false, "false_condition": "s3.enabled and not s3.use_alternative_aws_cli", "skip_reason": "Conditional result was False"}

TASK [Test s3 connection on the fly] ******************************************
skipping: [localhost] => {"changed": false, "false_condition": "s3.enabled and not s3.use_alternative_aws_cli", "skip_reason": "Conditional result was False"}

TASK [Copy s3 backup bash script] *********************************************
skipping: [localhost] => {"changed": false, "false_condition": "s3.enabled and not s3.use_alternative_aws_cli", "skip_reason": "Conditional result was False"}

TASK [Add the s3 backup script to cron] ***************************************
skipping: [localhost] => {"changed": false, "false_condition": "s3.enabled and not s3.use_alternative_aws_cli", "skip_reason": "Conditional result was False"}

TASK [S3 Configured successfully using s3cmd tool] ****************************
skipping: [localhost] => {"false_condition": "s3.enabled and not s3.use_alternative_aws_cli"}

TASK [APT - Install S3 related packages] **************************************
ok: [localhost] => {"cache_update_time": 1740071608, "cache_updated": false, "changed": false}

TASK [DNF - Install S3 related packages] **************************************
skipping: [localhost] => {"changed": false, "false_condition": "ansible_pkg_mgr == \"dnf\"", "skip_reason": "Conditional result was False"}

TASK [Create .aws directory with appropriate permissions and ownership] *******
ok: [localhost] => {"changed": false, "gid": 989, "group": "vault-backup", "mode": "0700", "owner": "vault-backup", "path": "/home/vault-backup/.aws", "size": 4096, "state": "directory", "uid": 996}

TASK [Copy credentials file with into .aws directory] *************************
ok: [localhost] => {"changed": false, "checksum": "aee5cda82646c11c0711fa543c1b152f61157bf7", "dest": "/home/vault-backup/.aws/credentials", "gid": 989, "group": "vault-backup", "mode": "0700", "owner": "vault-backup", "path": "/home/vault-backup/.aws/credentials", "size": 173, "state": "file", "uid": 996}

TASK [Ensuring AWS CLI tool is installed] *************************************
changed: [localhost] => {"changed": true, "cmd": ["aws", "--version"], "delta": "0:00:03.445623", "end": "2025-02-26 20:42:14.088781", "failed_when_result": false, "msg": "", "rc": 0, "start": "2025-02-26 20:42:10.643158", "stderr": "", "stderr_lines": [], "stdout": "aws-cli/2.17.3 Python/3.12.7 Linux/6.8.12-8-pve source/x86_64.ubuntu.24", "stdout_lines": ["aws-cli/2.17.3 Python/3.12.7 Linux/6.8.12-8-pve source/x86_64.ubuntu.24"]}

TASK [Test aws connection to the S3 object storage] ***************************
changed: [localhost] => {"changed": true, "cmd": ["aws", "s3", "ls", "--profile", "vault-backup"], "delta": "0:00:04.778022", "end": "2025-02-26 20:42:19.145180", "failed_when_result": false, "msg": "", "rc": 0, "start": "2025-02-26 20:42:14.367158", "stderr": "", "stderr_lines": [], "stdout": "2025-02-24 20:55:46 test", "stdout_lines": ["2025-02-24 20:55:46 test"]}

TASK [Copy AWS CLI Sync Script] ***********************************************
changed: [localhost] => {"changed": true, "checksum": "f6b052de31ada7cd93d2d366364f77a3144025b3", "dest": "/home/vault-backup/backup-to-s3.sh", "gid": 989, "group": "vault-backup", "md5sum": "aa083b9fa30ada79e0cf845a6db5a9d0", "mode": "0700", "owner": "vault-backup", "size": 4822, "src": "/root/.ansible/tmp/ansible-tmp-1740602539.1958115-20696-81367119220028/source", "state": "file", "uid": 996}

TASK [Add the AWS CLI Sync Script To Cron] ************************************
changed: [localhost] => {"changed": true, "envs": [], "jobs": ["Run Vault Snaphot script Hourly", "Run Vault Snaphot script", "Sync Local Folder Into S3 Object Storage"]}

TASK [S3 Configured successfully using AWS CLI Tool] **************************
ok: [localhost] => {
    "msg": "[Info] S3 Configured Successfully"
}

TASK [APT - Remove unnecassary packages] **************************************
changed: [localhost] => {"changed": true, "stderr": "", "stderr_lines": [], "stdout": "Reading package lists...\nBuilding dependency tree...\nReading state information...\nThe following package was automatically installed and is no longer required:\n  python3-magic\nUse 'sudo apt autoremove' to remove it.\nThe following packages will be REMOVED:\n  s3cmd\n0 upgraded, 0 newly installed, 1 to remove and 2 not upgraded.\nAfter this operation, 570 kB disk space will be freed.\n(Reading database ... \r(Reading database ... 5%\r(Reading database ... 10%\r(Reading database ... 15%\r(Reading database ... 20%\r(Reading database ... 25%\r(Reading database ... 30%\r(Reading database ... 35%\r(Reading database ... 40%\r(Reading database ... 45%\r(Reading database ... 50%\r(Reading database ... 55%\r(Reading database ... 60%\r(Reading database ... 65%\r(Reading database ... 70%\r(Reading database ... 75%\r(Reading database ... 80%\r(Reading database ... 85%\r(Reading database ... 90%\r(Reading database ... 95%\r(Reading database ... 100%\r(Reading database ... 58588 files and directories currently installed.)\r\nRemoving s3cmd (2.4.0-2) ...\r\nProcessing triggers for man-db (2.12.1-3) ...\r\n", "stdout_lines": ["Reading package lists...", "Building dependency tree...", "Reading state information...", "The following package was automatically installed and is no longer required:", "  python3-magic", "Use 'sudo apt autoremove' to remove it.", "The following packages will be REMOVED:", "  s3cmd", "0 upgraded, 0 newly installed, 1 to remove and 2 not upgraded.", "After this operation, 570 kB disk space will be freed.", "(Reading database ... ", "(Reading database ... 5%", "(Reading database ... 10%", "(Reading database ... 15%", "(Reading database ... 20%", "(Reading database ... 25%", "(Reading database ... 30%", "(Reading database ... 35%", "(Reading database ... 40%", "(Reading database ... 45%", "(Reading database ... 50%", "(Reading database ... 55%", "(Reading database ... 60%", "(Reading database ... 65%", "(Reading database ... 70%", "(Reading database ... 75%", "(Reading database ... 80%", "(Reading database ... 85%", "(Reading database ... 90%", "(Reading database ... 95%", "(Reading database ... 100%", "(Reading database ... 58588 files and directories currently installed.)", "Removing s3cmd (2.4.0-2) ...", "Processing triggers for man-db (2.12.1-3) ..."]}

TASK [DNF - Remove unnecassary packages] **************************************
skipping: [localhost] => {"changed": false, "false_condition": "ansible_pkg_mgr == \"dnf\" and s3.enabled and s3.use_alternative_aws_cli", "skip_reason": "Conditional result was False"}

TASK [APT - Remove unnecassary packages] **************************************
skipping: [localhost] => {"changed": false, "false_condition": "ansible_pkg_mgr == \"apt\" and s3.enabled and not s3.use_alternative_aws_cli", "skip_reason": "Conditional result was False"}

TASK [DNF - Remove unnecassary packages] **************************************
skipping: [localhost] => {"changed": false, "false_condition": "ansible_pkg_mgr == \"dnf\" and s3.enabled and not s3.use_alternative_aws_cli", "skip_reason": "Conditional result was False"}

TASK [APT - Remove unnecassary packages] **************************************
skipping: [localhost] => {"changed": false, "false_condition": "ansible_pkg_mgr == \"apt\" and not s3.enabled", "skip_reason": "Conditional result was False"}

TASK [DNF - Remove unnecassary packages] **************************************
skipping: [localhost] => {"changed": false, "false_condition": "ansible_pkg_mgr == \"dnf\" and not s3.enabled", "skip_reason": "Conditional result was False"}

PLAY RECAP ********************************************************************
localhost                  : ok=18   changed=8    unreachable=0    failed=0    skipped=14   rescued=0    ignored=0
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

## TODO

check if aws and s3cmd works:

- remove all crons from the user and then add new ones
- s3cmd does not support my setup due to XML formatting error

```bash
s3cmd put myfile.md s3://test
WARNING: Module python-magic is not available. Guessing MIME types based on file extensions.
upload: 'myfile.md' -> 's3://test/myfile.md'  [1 of 1]
 80 of 80   100% in    0s  2021.43 B/s  done
ERROR: S3 error: 400 (MalformedXML): The XML you provided was not well-formed or did not validate against our published schema.
```
