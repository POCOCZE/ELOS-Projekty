# This repo is used to temporarilly save and store ELOS projects I am currently working/worked on

`(from the most recent at the top)`

## HashiCorp Vault Automatic Cronjob Snapshot Bash Script

This project is focused on creating Vault raft snapshots with easy Bash script.
The script will be ran using cronjob.

---
---

## Stateless Simple Microservice Implementation (optionally)

### Brief Information

Create from scratch and implement stateless microservice (by using 12 factor app principle) that uses environment variable of API calls. Should be available through REST API (just HTTP `GET` and `POST` are sufficient). Implement health-checks or metrics is bonus.

Project uses Python framework called FastAPI that by default uses REST API:

- FastAPI
- Uses Prometheus python library to generate outputs that Prometheus understands (PromQL)
- Supports environment variables by using `.env` file (not in repo)
- Asynchonously process each request

---
---

## HashiCorp Vault and Terraform

### Brief Info

Implement a way to manage secrets by using tool called HashiCorp Vault. Use programming language HCL (hashiCorp Configuration Language) that is declarative type. Outputs will be saved in Github repo. The goal is to add into HshiCorp Vault some secrets that was previously in plaintext `.txt` file locally.

- HashiCorp BVault is a tool to manage secrets
- It safely saves them by using cryptographic techniques
- HCL is a declarative type of programming language that HashiCorp uses
- Git is a version control system that does not save the actual files but rather their changes that have been made

---
---

## Ansible

Its free and open-source configuration management automation tool that uses SSH to log into hosts.

This means that this tool is usefull for variout workload types including kubernetes cluster where cluster admins had configured SSH access to their API.

---
---

## Python project Welcome-ELOS-WebApp

Contains hello-world app that uses archetype or skeleton of the app

1. The app will then be compiled, unit tested, locally tested first
2. Next we will use containers to pack the app up, create executable image
3. After that run it on some container orchestrator - K8s/OpenShift

### Accessible through this link: [Welcome-ELOS-WebApp](https://elos.podarix.fun)

### How to create a Helm Chart

#### for MacOs

```bash
brew install helm
mkdir helm-charts/
cd helm-charts/
helm create welcome-elos-webapp
```

---
---

## Bash Project

Contains bash script to create N number of users. You can set there user names and passwords that will be created
Creates ssh directory and generates public/private key pair
Changes ownership of .ssh dir so keys will own the user.

---
---

### What i wanna do next?

#### I dont know :D

#### I will try to find something quickly
