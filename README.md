# Users API with CI/CD Automation

## Overview
This is a fork of [otomato-gh/usersapi](https://github.com/otomato-gh/usersapi) with added automation using **Ansible**, **Terraform**, and a **Jenkins pipeline**. The project is designed to build, deploy, and manage a containerized users API on an **Amazon EKS cluster**.


## Jenkins Pipeline Setup

### **Required Plugins**
Ensure the following Jenkins plugins are installed:

- **GitHub**
- **Pipeline: GitHub**
- **Docker**
- **Pyenv Pipeline**
- **Kubernetes**
- **GitHub Integration**
- **Amazon Web Services SDK :: All**

### **Global Environment Variables**
Go to **Manage Jenkins > System > Global properties** and configure:

| Variable            | Description                     |
|---------------------|--------------------------------|
| `DOCKER_REGISTRY`  | The Docker registry URL        |
| `EKS_CLUSTER_NAME` | The name of the EKS cluster    |
| `GLOBAL_AWS_REGION` | AWS region for EKS deployment |

### **Jenkins Credentials**

| ID             | Description                            |
|---------------|----------------------------------------|
| `docker-creds` | Docker login credentials (username/password) |
| `aws-creds`   | AWS credentials (access key/secret key) |

## Deployment Workflow

### **1. Infrastructure Setup with Terraform**
```sh
cd terraform/
terraform init
terraform apply -auto-approve
```
This sets up the EC2 instance, EBS storage, and EKS cluster.

### **2. Configuration with Ansible**
```sh
ansible-playbook -i ansible/inventory ansible/deploy.yml
```
For setting up the server.

### **3. Run the Jenkins Pipeline**
The pipeline will:
1. Lint and test the application
2. Build the Docker image
3. Push the image to `DOCKER_REGISTRY`
4. Deploy the Helm chart to EKS



