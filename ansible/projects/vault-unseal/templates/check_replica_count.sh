#!/bin/bash
## Check and set default replica count if helm replica count is not positive integer
# DO NOT USE THIS PLAYBOOK IN PRODUCTION!
# Extracted files (unseal keys, root token) are in plaintext, NOT ENCRYPTED!
# Created by simon
# Date: 25/11/2024

NAMESPACE=$1
DEFAULT_REPLICAS=$2

# Try to get the replica count from Helm
REPLICA_COUNT=$(helm get values vault -n $NAMESPACE -o json | jq '.server.ha.replicas')

# Check if the output is a positive integer
if [[ $REPLICA_COUNT =~ ^[1-9][0-9]*$ ]]; then
  echo $REPLICA_COUNT
else
  echo $DEFAULT_REPLICAS
fi
