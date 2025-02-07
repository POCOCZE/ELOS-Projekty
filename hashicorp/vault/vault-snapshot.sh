#!/bin/bash
## Automatically find Vault raft leader and snapshot current state to .snap file
# By: simon
# Date: 7/2/2025
# Last tested: 7/2/2025

#######################
# CHANGE THIS SECTION #
#######################

# Port 8200 used to access API
VAULT_INIT_ADDR=https://vault.example.com:8200
VAULT_SKIP_VEFIRY=false
SNAPSHOT_LOCATION=/home/vault/snapshots

# -----

# Export important values as env. vars so vault can see and use them
export VAULT_INIT_ADDR
export VAULT_SKIP_VEFIRY


#############
# FUNCTIONS #
#############

check_vault_status() {
  if ! vault status; then
    echo "Vault instance is not reachable. Check its address."
    exit 1
  fi
}

gather_leader_from_raft() {
  LEADER_ADDR=$(vault operator raft list-peers -format json | jq -r '.data.config.servers[] | select(.leader == true) | .address')
  
  # $? check if the exit status of the previous command.
  # If the command failed then print error
  if [ $? -ne 0]; then
    echo "Vault token is not correct. Check the token."
    exit 2
  else
    export LEADER_ADDR
  fi
}

create_raft_snapshot() {
  cd $SNAPSHOT_LOCATION
  DATE=$(date -I)
  vault operator raft snapshot save vault-snapshot-${DATE}.snap
}


########
# MAIN #
########

check_vault_status
gather_leader_from_raft
create_raft_snapshot
