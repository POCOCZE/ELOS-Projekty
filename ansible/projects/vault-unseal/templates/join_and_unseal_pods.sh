#!/bin/bash
## Extract unseal keys and root token from the initialization output
# DO NOT USE THIS PLAYBOOK IN PRODUCTION!
# Extracted files (unseal keys, root token) are in plaintext, NOT ENCRYPTED!
# Created by simon
# Date: 18/11/2024

# Variables
NAMESPACE=$1
VAULT_POD_0=$2
REPLICA_COUNT=$3
LEADER_CA_CERT=$4

# Debug statements
echo "Namespace: $NAMESPACE"
echo "Vault Pod 0: $VAULT_POD_0"
echo "Replica Count: $REPLICA_COUNT"

# Function to Join and Unseal a Pod
join_and_unseal_pod() {
  local pod_name=$1
  local join_command="vault operator raft join -leader-ca-cert=@${LEADER_CA_CERT} https://${VAULT_POD_0}.vault-internal:8200"
  local unseal_keys=$(head -n 5 /tmp/unseal_keys.txt)

  # Debug statements
  echo "Joining pod: $pod_name"
  echo "Join command: $join_command"
  echo "Unseal keys: $unseal_keys"

  # Join the pod to the Raft
  kubectl exec -n ${NAMESPACE} pod/${pod_name} -- ${join_command}

  # Unseal the Pod
  for key in ${unseal_keys}; do
    kubectl exec -n ${NAMESPACE} pod/${pod_name} -- vault operator unseal ${key}
  done
}

# Loop through the remaining Pods and Join/Unseal them
for ((i=1; i<REPLICA_COUNT; i++)); do
  pod_name="vault-${i}"
  join_and_unseal_pod ${pod_name}
done
