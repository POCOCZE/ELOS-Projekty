# Ansible Playbook To Automatically Initialize, Unseal, Join HashiCorp Vault Pods in High Availability Deployment Type with TLS

## Linux

`This Ansible Playbook was tested in Linux based OS, other OSes are not guaranted to run smoothly or as intended, WSL2 was not tested at all!`

To run the Ansible Playbook correctly do this things first:

1. Ensure that HashiCorp Vault is installed with Helm - Tutorial is in the HashiCorp/Vault folder

    ```bash
    helm install vault hashicorp/vault -f values.yaml
    NAME: vault
    LAST DEPLOYED: Tue Nov 19 20:53:16 2024
    NAMESPACE: vault
    STATUS: deployed
    REVISION: 1
    NOTES:
    Thank you for installing HashiCorp Vault!

    Now that you have deployed Vault, you should look over the docs on using
    Vault with Kubernetes available here:

    https://developer.hashicorp.com/vault/docs


    Your release is named vault. To learn more about the release, try:

      $ helm status vault
      $ helm get manifest vault
    ```

2. All the Pods must be in `Running` state

    ```bash
    kgp
    NAME                                    READY   STATUS    RESTARTS   AGE
    vault-0                                 0/1     Running   0          7s
    vault-1                                 0/1     Running   0          7s
    vault-2                                 0/1     Running   0          7s
    vault-agent-injector-55dcc9fb4c-9rtdk   1/1     Running   0          8s
    ```

3. Before running the playbook, ensure that you have all the necessary files
4. Create the `hosts.ini` file that will contain the group name - this should match with the name in the Playbook you wanna execute
5. Change the variables file `vars.yml` if needed (optional)

## Run the Ansible Playbook in the root of the `Ansible` folder with command

```bash
ansible-playbook -i hosts.ini projects/vault-unseal/playbook/vault-unseal.yml --ask-become-pass
```

`Info: parameter --ask-become-pass is required because it installs python3-kubernetes apt package if not present`

This Ansible Playbook creates important files into `/tmp/` root folder:

- /tmp/vault_init_output.txt (Helm get values vault output)
- /tmp/root_token.txt
- /tmp/unseal_keys.txt

Output from any of the HashiCorp Vault Pods to check correct state:
(You must login into the vault inside the Pod so see the results with `vault login` - root token is in the file described above)

After execution the HashiCorp Vault Pods are connected together

```bash
k exec -it pod/vault-0 -- vault operator raft list-peers
Node       Address                        State       Voter
----       -------                        -----       -----
vault-0    vault-0.vault-internal:8201    leader      true
vault-1    vault-1.vault-internal:8201    follower    true
vault-2    vault-2.vault-internal:8201    follower    true
```

Here is the output of Ansible playbook execution:

```bash
ansible-playbook -i hosts.ini projects/vault-unseal/playbook/vault-unseal.yml --ask-become-pass
BECOME password:
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details
[WARNING]: Found variable using reserved name: namespace

PLAY [Initialize, Unseal, Join HashiCorp Vault Pods in High Availability Deployment Type] *****************************************************************************************************************************************************************

TASK [Install python3-kubernetes if not installed] ********************************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host kubernetes-kind.test-environment.example.com is using the discovered Python interpreter at /usr/bin/python3.12, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [kubernetes-kind.test-environment.example.com]

TASK [Check if HashiCorp Vault is installed with Helm] ****************************************************************************************************************************************************************************************************
changed: [kubernetes-kind.test-environment.example.com]

TASK [Get the number of replicas using helm] **************************************************************************************************************************************************************************************************************
changed: [kubernetes-kind.test-environment.example.com]

TASK [Extract the number of replicas] *********************************************************************************************************************************************************************************************************************
ok: [kubernetes-kind.test-environment.example.com]

TASK [Initialize the first Vault `vault-0` pod] ***********************************************************************************************************************************************************************************************************
[WARNING]: kubernetes<24.2.0 is not supported or tested. Some features may not work.
[DEPRECATION WARNING]: The 'return_code' return key is being renamed to 'rc'. Both keys are being returned for now to allow users to migrate their automation. This feature will be removed from kubernetes.core in version 4.0.0. Deprecation warnings
can be disabled by setting deprecation_warnings=False in ansible.cfg.
changed: [kubernetes-kind.test-environment.example.com]

TASK [Save Unseal Keys and Root Token] ********************************************************************************************************************************************************************************************************************
changed: [kubernetes-kind.test-environment.example.com]

TASK [Extract Unseal Keys and Root Token] *****************************************************************************************************************************************************************************************************************
changed: [kubernetes-kind.test-environment.example.com]

TASK [Unseal the first Vault pod] *************************************************************************************************************************************************************************************************************************
changed: [kubernetes-kind.test-environment.example.com]

TASK [Join and unseal remaining Vault pods] ***************************************************************************************************************************************************************************************************************
changed: [kubernetes-kind.test-environment.example.com]

PLAY RECAP ************************************************************************************************************************************************************************************************************************************************
kubernetes-kind.test-environment.example.com     : ok=9    changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## MacOS

For this system there exist specific Ansible Playbook that uses Homebrew to install dependencies.

The playbook is called `vault-unseal-oc-macos.yaml` in the playbook folder.

You can run the playbook the same way as for Linux:

```bash
ansible-playbook -i hosts.ini projects/vault-unseal/playbook/vault-unseal.yml --ask-become-pass
```
