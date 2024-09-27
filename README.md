# This repo is used to temporarilly save and store ELOS projects i am currently working/worked on

## Successfully

- Coded app in Python by using Flask framework for development
- Created modern visuals by using combination of HTML, CSS, JavaScript and TailWindCSS libraries by using CDN
- For production use cases switched to Gunicorn
- Unit tested the app if basic root and paths works - if yes print OK
- Created Dockerfile with requirements.txt file
- Built Docker image by using `docker build`
- Checked for vulnerabilities with Docker Scout
- Spinned up the container with `Docker run` to test if everything works
- Created how to create and work with Helm Charts - create Helm Chart
- Fixed a lot of issues related to Helm Charts
- Created CI/CD pipeline to automatically create release of helm charts!
- Ran the WebApp by using my own Helm Chart on my kubernetes cluster!

# Accessible through this link: [Welcome-ELOS-WebApp](https://elos.exprt.fun)

## Bash

Contains bash script to create N number of users. You can set there user names and passwords that will be created
Creates ssh directory and generates public/private key pair
Changes ownership of .ssh dir so keys will own the user.

## Welcome-ELOS-WebApp

Contains hello-world app that uses archetype or skeleton of the app

1. The app will then be compiled, unit tested, locally tested first
2. Next we will use containers to pack the app up, create executable image
3. After that run it on some container orchestrator - K8s/OpenShift

---

### How to create a Helm Chart

#### MacOs

```bash
brew install helm
mkdir helm-charts/
cd helm-charts/
helm create welcome-elos-webapp
```

## Ansible

Its free and open-source configuration management automation tool that uses SSH to log into hosts.

### Ansible-Project Outputs

```bash
ansible-playbook ./playbooks/create-users.yml -i hosts.ini --ask-become-pass
BECOME password: supersecret!
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [Create X number of users with SSL keys] *****************************************************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host 192.168.0.40 is using the discovered Python interpreter at /usr/bin/python3.12, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [192.168.0.40]

TASK [Create the desired directory if not exists] *************************************************************************************************************************************************************************
ok: [192.168.0.40]

TASK [Download script from github] ****************************************************************************************************************************************************************************************
changed: [192.168.0.40]

TASK [Change username in the script] **************************************************************************************************************************************************************************************
changed: [192.168.0.40]

TASK [Change password in the script if needed] ****************************************************************************************************************************************************************************
changed: [192.168.0.40]

TASK [Run the script] *****************************************************************************************************************************************************************************************************
changed: [192.168.0.40]

TASK [Delete the script] **************************************************************************************************************************************************************************************************
changed: [192.168.0.40]

TASK [List files in working directory] ************************************************************************************************************************************************************************************
ok: [192.168.0.40]

TASK [Check if dir is empty] **********************************************************************************************************************************************************************************************
ok: [192.168.0.40]

TASK [Delete whole working directory if is_empty=True] ********************************************************************************************************************************************************************
skipping: [192.168.0.40]

PLAY RECAP ****************************************************************************************************************************************************************************************************************
192.168.0.40               : ok=9    changed=5    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

### What i wanna do next?

#### I dont know :D

#### I will try to find something quickly
