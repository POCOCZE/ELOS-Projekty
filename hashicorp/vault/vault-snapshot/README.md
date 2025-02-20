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

To utilize the Ansible Vault Snapshot and S3 Backup Automation, follow these steps:

### 1. Configure Ansible Inventory (`hosts.ini`)

Ensure your Ansible inventory file (`hosts.ini` or your configured inventory path) is correctly set up to target the Linux host where Vault Raft snapshots will be managed. Define the hostname or IP address of your target machine under a relevant group (e.g., `vault-snapshot`).

```ini
[vault-snapshot]
vault.example.com ansible_host=<vault_server_ip_or_hostname> ansible_user=<ansible_user> ansible_become=true
```

Replace placeholders like `<vault_server_ip_or_hostname>` and `<ansible_user>` with your actual environment details. Ensure the Ansible user has `sudo` privileges on the target host.

### 2. Customize Ansible Variables (`variables.yml`)

Modify the `variables.yml` file in your Ansible project directory to customize the automation to your environment. Key variables to configure include:

* **Vault Settings**: `vault_addr`, `vault_token` (for snapshot creation script).
* **S3 Settings (for optional S3 backup)**: `s3_host`, `s3_host_bucket`, `aws_access_key_id`, `aws_secret_access_key`, `bucket_name`.
* **Script Settings**: `local_folder` (snapshot destination), `delete_files_on_s3` (boolean to enable/disable S3 remote file deletion).
* **User and Path Settings**: Adapt user names and directory paths if needed, although defaults are generally suitable.

Ensure sensitive values like `vault_token` and `aws_secret_access_key` are securely managed, ideally using Ansible Vault or a similar secrets management solution in a production setup.

### 3. Run the Ansible Playbook

Execute the Ansible playbook using the `ansible-playbook` command from your Ansible control machine. Navigate to your Ansible project directory in the terminal and run:

```bash
ansible-playbook -i hosts.ini playbook.yml -v
```

This command will execute the playbook, automating the Vault Raft snapshot process and optionally configuring S3 backups based on the variables defined in `variables.yml`.

### 4. S3cmd Prerequisite (for S3 Backup Feature)

If you intend to use the optional S3 snapshot synchronization feature, ensure that `s3cmd` is installed on the target Linux host where the Ansible playbook is executed. The playbook itself does not install `s3cmd`. If `s3cmd` is not installed and the S3 backup feature is enabled in `variables.yml`, the S3 sync part of the automation will likely fail.

If you do not wish to use the S3 backup feature, you can simply leave the S3 related variables in `variables.yml` unset or ensure the S3 backup feature is disabled, and the core Vault snapshot functionality will operate without `s3cmd`.

## Common Mistakes and Troubleshooting

* **Incorrect Vault Credentials**: Ensure `vault_addr` and `vault_token` in `variables.yml` are accurate and valid for your Vault instance. Incorrect credentials will prevent the snapshot script from authenticating with Vault.
* **Missing or Incorrect S3 Credentials**: If using S3 backup, double-check `s3.host`, `s3.bucket_name`, `s3.access_key`, and `s3.secret_key` in `variables.yml`. Incorrect S3 credentials will cause the S3 synchronization to fail.
* **`s3cmd` Not Installed (S3 Backup Enabled)**: If you have enabled the S3 backup feature but `s3cmd` is not installed on the target host, the playbook will proceed, but the S3 synchronization step will fail. Verify `s3cmd` is present if using S3 backup. Playbook automatically test the S3 connection first to ensure correct credintials.
* **Incorrect `hosts.ini` or Ansible User Setup**: Problems with Ansible connecting to the target host, such as incorrect host IP in `hosts.ini`, SSH key issues, or insufficient privileges for the Ansible user, will prevent the playbook from running successfully. Verify Ansible connectivity and user privileges before execution.
* **File Permission Issues**: While the playbook sets file permissions, manually altered permissions on script files or directories on the target host, especially within `/home/vault-backup/`, may cause script execution failures. Ensure permissions are as intended by the playbook.
