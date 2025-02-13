#!/bin/bash
# --- Script Info ---
# Automatically find Vault raft leader and snapshot current state to .snap file
# By: simon
# Date: 13/2/2025
# Last tested: 7/2/2025


########################
# SCRIPT CONFIGURATION #
########################

# --- Security Configuration ---
# Path to the secure configuration file storing VAULT_ADDR and VAULT_TOKEN in JSON format.
# Values in this file are Base64 encoded for added security.
CONFIG_FILE=~/.secret/vault-backup.json

# --- Vault Configuration ---
# Note: VAULT_ADDR is loaded and decoded from the config file.
# VAULT_SKIP_VERIFY: If set to 'true', TLS certificate verification will be skipped.
#                    Set to 'false' for production environments to ensure secure connections.
VAULT_SKIP_VERIFY=false

# --- Snapshot Configuration ---
# Location where snapshots will be saved. Must be writable by the user running this script.
SNAPSHOT_LOCATION=/home/vault-backup/snapshots
# Maximum number of snapshot files to keep. Older snapshots will be deleted to maintain this limit.
MAX_SNAPSHOTS=5
# Generic name for snapshot files, date and time will be appended.
SNAPSHOT_NAME_PREFIX="vault-snapshot"


########################
# END OF CONFIGURATION #
########################


#############
# FUNCTIONS #
#############

# Function to log messages with a timestamp using journalctl.
log_message() {
    local message="$1"
    timestamp=$(date -I --utc --date='now') # Get current UTC date and time in ISO 8601 format
    logger -t vault-snapshot "[$timestamp] $message"
}

# Function to check the connectivity and status of the Vault instance.
check_vault_status() {
    if ! vault status > /dev/null 2>&1; then
        log_message "ERROR: Vault instance is not reachable or Vault CLI is not correctly configured. Check VAULT_ADDR and ensure Vault is running."
        return 1 # Indicate failure
    else
        log_message "Vault is reachable and Vault CLI is configured correctly."
        return 0 # Indicate success
    fi
}

# Function to gather the leader address from the Raft configuration.
gather_leader_from_raft() {
    local leader_data=$(vault operator raft list-peers -format json)

    if [ $? -ne 0 ]; then
        log_message "ERROR: Failed to retrieve Raft peers information. Ensure VAULT_TOKEN is valid and has sufficient permissions."
        return 1 # Indicate failure
    fi

    local leader_addr=$(echo "$leader_data" | jq -r '.data.config.servers[] | select(.leader == true) | .address')

    if [ -z "$leader_addr" ]; then
        log_message "ERROR: Could not determine the Raft leader address."
        return 1 # Indicate failure
    fi

    export LEADER_ADDR="$leader_addr"
    log_message "Successfully determined Raft leader address: $LEADER_ADDR"
    return 0 # Indicate success
}

# Function to create a Raft snapshot and save it to the snapshot location.
create_raft_snapshot() {
    cd "$SNAPSHOT_LOCATION" || {
        log_message "ERROR: Could not change directory to snapshot location: $SNAPSHOT_LOCATION. Check permissions and path."
        return 1 # Indicate failure
    }

    local snapshot_filename="${SNAPSHOT_NAME_PREFIX}-$(date +'%Y-%m-%d-%H-%M').snap"
    vault operator raft snapshot save "$snapshot_filename"

    if [ $? -ne 0 ]; then
        log_message "ERROR: Failed to create Raft snapshot. Review Vault logs and ensure leader address is correctly resolved."
        return 1 # Indicate failure
    else
        log_message "Successfully created Raft snapshot: $snapshot_filename"
        return 0 # Indicate success
    fi
}

# Function to manage snapshot file retention, ensuring only the MAX_SNAPSHOTS are kept.
manage_snapshots() {
    log_message "Checking snapshot file count and managing retention."
    local snapshot_files=($(ls -tr "$SNAPSHOT_LOCATION"/"$SNAPSHOT_NAME_PREFIX"*.snap 2>/dev/null)) # List snapshot files sorted by modification time (oldest first)

    local file_count="${#snapshot_files[@]}"
    log_message "Current snapshot file count: $file_count, maximum allowed: $MAX_SNAPSHOTS."

    if [ "$file_count" -gt "$MAX_SNAPSHOTS" ]; then
        local files_to_delete=$((file_count - MAX_SNAPSHOTS))
        log_message "Number of snapshot files to delete: $files_to_delete."
        for ((i=0; i<files_to_delete; i++)); do
            local oldest_file="${snapshot_files[i]}"
            log_message "Deleting oldest snapshot file: $oldest_file."
            rm -f "$oldest_file"
            if [ $? -ne 0 ]; then
                log_message "ERROR: Failed to delete snapshot file: $oldest_file. Check permissions."
            else
                log_message "Successfully deleted snapshot file: $oldest_file."
            fi
        done
    else
        log_message "Snapshot count is within the limit. No files to delete."
    fi
}


########
# MAIN #
########

# Ensure script will exit on any error
set -e

# Initialize log file and write script start message - not needed for journalctl
# touch "$LOGFILE" - not needed for journalctl
log_message "# -------------------------------------------------------------------"
log_message "# Vault Raft Snapshot Script Execution Started"
log_message "# Date: $(date -I --utc --date='now')"
log_message "# -------------------------------------------------------------------"

# Load Vault Address and Token from secure configuration file and decode Base64 values
if [ -f "$CONFIG_FILE" ]; then
    VAULT_ADDR_ENCODED=$(jq -r '.VAULT_ADDR' "$CONFIG_FILE")
    VAULT_TOKEN_ENCODED=$(jq -r '.VAULT_TOKEN' "$CONFIG_FILE")

    VAULT_ADDR=$(echo "$VAULT_ADDR_ENCODED" | base64 -d)
    VAULT_TOKEN=$(echo "$VAULT_TOKEN_ENCODED" | base64 -d)

    export VAULT_ADDR
    export VAULT_TOKEN
    export VAULT_SKIP_VERIFY # Exporting skip verify setting as configured
    log_message "Successfully loaded and decoded VAULT_ADDR and VAULT_TOKEN from configuration file: $CONFIG_FILE"
else
    log_message "ERROR: Configuration file not found: $CONFIG_FILE. Script cannot proceed without Vault credentials."
    exit 1
fi

# Perform Vault status check
log_message "--- Checking Vault Status ---"
check_vault_status
if [ $? -ne 0 ]; then
    log_message "Script execution aborted due to Vault status check failure."
    exit 1
fi

# Gather Leader Address from Raft configuration
log_message "--- Gathering Raft Leader Address ---"
gather_leader_from_raft
if [ $? -ne 0 ]; then
    log_message "Script execution aborted due to Raft leader address retrieval failure."
    exit 1
fi

# Create Raft Snapshot
log_message "--- Creating Raft Snapshot ---"
create_raft_snapshot
if [ $? -ne 0 ]; then
    log_message "Script execution aborted due to Raft snapshot creation failure."
    exit 1
fi

# Manage Snapshot Retention
log_message "--- Managing Snapshot Retention ---"
manage_snapshots

log_message "# -------------------------------------------------------------------"
log_message "# Vault Raft Snapshot Script Execution Completed Successfully"
log_message "# Date: $(date -I --utc --date='now')"
log_message "# -------------------------------------------------------------------"

exit 0