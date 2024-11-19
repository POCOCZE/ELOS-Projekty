#!/bin/bash
## Unseal the Vault pod using the provided unseal keys
# DO NOT USE THIS PLAYBOOK IN PRODUCTION!
# Extracted files (unseal keys, root token) are in plaintext, NOT ENCRYPTED!
# Created by simon
# Date: 18/11/2024

for key in $(head -n 3 /tmp/unseal_keys.txt); do
  vault operator unseal $key
done
