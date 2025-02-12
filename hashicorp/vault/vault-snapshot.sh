#!/bin/bash
## Automatically find Vault raft leader and snapshot current state to .snap file
# By: simon
# Date: 12/2/2025
# Last tested: 7/2/2025

#######################
# CHANGE THIS SECTION #
#######################

# Script assume that VAULT_TOKEN is already exported.

# Port 8200 used to access API
VAULT_INIT_ADDR=https://vault.example.com:8200
VAULT_SKIP_VEFIRY=false
SNAPSHOT_LOCATION=/home/vault/snapshots
LOGFILE=/var/log/vault-snapshot-log.txt


# -----

# Export important values as env. vars so vault can see and use them
export VAULT_INIT_ADDR
export VAULT_SKIP_VEFIRY


#############
# FUNCTIONS #
#############

# Log message into file
log_message() {
    local message="$1"
    echo "$message" >> $LOGFILE
}

check_vault_status() {
  if ! vault status; then
    log_message "Vault instance is not reachable. Check its address."
    exit 1
  else
    log_message "Vault is reachable."
  fi
}

gather_leader_from_raft() {
  LEADER_ADDR=$(vault operator raft list-peers -format json | jq -r '.data.config.servers[] | select(.leader == true) | .address')
  
  # $? check if the exit status of the previous command.
  # If the command failed then print error
  if [ $? -ne 0]; then
    log_message "Vault token is not correct. Check the token."
    exit 2
  else
    export LEADER_ADDR
    log_message "Token is correct"
    log_message "Successfully exported leader address."
  fi
}

create_raft_snapshot() {
  cd $SNAPSHOT_LOCATION
  DATE=$(date -I)
  vault operator raft snapshot save vault-snapshot-${DATE}.snap

  if [ $? -ne 0]; then
    log_message "Cannot snaphot Vault Raft. Probably due to wrong leader address."
    exit 3
  else
    log_message "Successfully created snapshot."
    log_message "Snapshot saved to: ${LOGFILE}"
  fi
}


########
# MAIN #
########

touch $LOGFILE
log_message "# ------------------------------------------------"
log_message "Date: $(date)"
log_message ""

check_vault_status
gather_leader_from_raft
create_raft_snapshot