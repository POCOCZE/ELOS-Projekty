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

# Accessible through this link: [Welcome-ELOS-WebApp](elos.exprt.fun)

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

#### I dont know :D

#### I will try to find something quickly...