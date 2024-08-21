# This repo is used to temporarilly save and store ELOS projects i am currently working/worked on

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

### What i wanna do next?

Create a Helm chart for that container and run it on my kuberentes infrastructure!
