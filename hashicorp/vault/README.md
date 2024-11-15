# Install and setup Vault with TLS for end-to-end encryption, including installation of Jetstack Cert-Manager

Here are the commands to install and configure Vault with end-to-end encryption using cert-manager and Helm:

## Step 1: Install dependencies

Step 1.1: Install Cert-manager CRDs:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.crds.yaml
```

Step 1.1: Install Cert-Manager with Helm:

```bash
## Add the Jetstack Helm repository
$ helm repo add jetstack https://charts.jetstack.io --force-update

## Install the Cert-Manager Helm chart
$ helm install cert-manager jetstack/cert-manager --namespace cert-manager
```

## Step 2: Create a namespace for Vault

```bash
kubectl create namespace vault
```

## Step 3: Create an Issuer for cert-manager

```yml
# vault-issuer.yaml 
apiVersion: cert-manager.io/v1
kind: Issuer 
metadata:
  name: vault-issuer
  namespace: vault
spec:
  selfSigned: {}
```

```bash
# Apply the configuration
kubectl apply -f vault-issuer.yaml
```

## Step 4: Create a Certificate resource

```yml
# vault-certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: vault-tls
  namespace: vault
spec:
  secretName: vault-ha-tls
  duration: 8760h # 1 year
  renewBefore: 720h # 30 days
  subject:
    organizations:
      - system:nodes
  commonName: system:node:*.vault.svc.cluster.local
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - server auth
    - client auth
  dnsNames:
    - "*.vault-internal"
    - "*.vault-internal.vault.svc.cluster.local"
    - "*.vault"
  ipAddresses:
    - 127.0.0.1
  issuerRef:
    name: vault-issuer
    kind: Issuer
```

```bash
kubectl apply -f vault-certificate.yaml
```

## Step 5: Install Vault using Helm

```bash
## Add the HashiCorp Helm repository
helm repo add hashicorp https://helm.releases.hashicorp.com

## Install the HashiCorp Vault Helm chart
helm install vault hashicorp/vault -f values.yaml
```

## Step 6: Configure values.yaml file

```yml
# values.yaml
global:
  enabled: true
  tlsDisable: false

injector:
  enabled: true

server:
  extraEnvironmentVars:
    VAULT_CACERT: /vault/userconfig/vault-ha-tls/tls.crt
    VAULT_TLSCERT: /vault/userconfig/vault-ha-tls/tls.crt
    VAULT_TLSKEY: /vault/userconfig/vault-ha-tls/tls.key
  volumes:
    - name: userconfig-vault-ha-tls
      secret:
        defaultMode: 420
        secretName: vault-ha-tls
  volumeMounts:
    - mountPath: /vault/userconfig/vault-ha-tls
      name: userconfig-vault-ha-tls
      readOnly: true
  standalone:
    enabled: false
  affinity: ""
  ha:
    enabled: true
    replicas: 3
    raft:
      enabled: true
      setNodeId: true
      config: |
        cluster_name = "vault-integrated-storage"
        ui = true
        listener "tcp" {
          tls_disable = 0
          address = "[::]:8200"
          cluster_address = "[::]:8201"
          tls_cert_file = "/vault/userconfig/vault-ha-tls/tls.crt"
          tls_key_file  = "/vault/userconfig/vault-ha-tls/tls.key"
          tls_client_ca_file = "/vault/userconfig/vault-ha-tls/ca.crt"
        }
        storage "raft" {
          path = "/vault/data"
        }
        disable_mlock = true
        service_registration "kubernetes" {}
```

## Step 7: Initialize and unseal Vault

```bash
kubectl exec -it vault-0 -n vault -- vault operator init
kubectl exec -it vault-0 -n vault -- vault operator unseal <unseal_key>
```

Note: Replace `<unseal_key>` with the actual unseal key generated during the initialization process.

## Ansible Script for automating the Unsealing process of HashiCorp Vault for Kubernetes Kind

Here is the playbook:

```yaml
---
## Unseal HashiCorp Vault
# DO NOT USE THIS PLAYBOOK IN PRODUCTION!
# Extracted files (unseal keys, root token) are in plaintext, NOT ENCRYPTED!
# Created by simon
# Date: 14/11/2024

- name: Initialize Vault and retrieve keys
  hosts: vault-cluster
  gather_facts: false
  vars_files:
    - ../variables/env.yml

  # Prepare the Unseal keys and Root token by unsealing the HashiCorp Vault in the Pod
  pre_tasks:
    - name: Switch into Kubernetes Kind cluster
      command: >
        kubectl cluster-info --context {{ kind_cluster_select }}

    - name: Execute Vault init command
      command: >
        kubectl exec -it --namespace {{ vault_namespace }} pod/{{ vault_pod_name }} -- vault operator init
      # Saves the output into the variable
      register: vault_init_output

  # Extract important resources
  tasks:
    - name: Extract unseal keys
      # Set new variables during playbook execution
      set_fact:
        # Name of the variable here is the `unseal_keys`
        unseal_keys: "{{ vault_init_output.stdout | regex_findall('Unseal Key \\d+: (.+)') }}"

    - name: Extract root token
      set_fact:
        root_token: "{{ vault_init_output.stdout | regex_search('Initial Root Token: (.+)') | regex_replace('Initial Root Token: ', '') }}"

  # Save the resources into files on the machine
  # This is unsafe!
  # Just for testing purposes!
  post_tasks:
    - name: Print the unseal key and root token to the user
      debug:
        msg: "Unseal keys:\n{{ unseal_keys }}\n\nRoot token:\n{{ root_token }}"

    - name: Save unseal keys to file
      copy:
        # Copy the contents of the variable into the file - in YAML format
        content: "{{ unseal_keys | to_yaml }}"
        dest: "./unseal_keys.yml"
      
    - name: Save root token to file
      copy:
        content: "{{ root_token }}"
        dest: "./root_token.txt"
```

Don't forget to include the variables file:

```yaml
vault_namespace: default
vault_pod_name: vault-0
kind_cluster_select: kind-vault-testing
```
