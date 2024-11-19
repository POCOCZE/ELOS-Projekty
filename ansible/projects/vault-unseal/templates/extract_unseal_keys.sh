#!/bin/bash
## Extract unseal keys and root token from the initialization output
# DO NOT USE THIS PLAYBOOK IN PRODUCTION!
# Extracted files (unseal keys, root token) are in plaintext, NOT ENCRYPTED!
# Created by simon
# Date: 18/11/2024

grep 'Unseal Key' /tmp/vault_init_output.txt | awk '{print $4}' > /tmp/unseal_keys.txt
grep 'Root Token' /tmp/vault_init_output.txt | awk '{print $4}' > /tmp/root_token.txt
