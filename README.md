# DevOps Bootcamp Project  
Automated Infrastructure Deployment using Terraform, AWS, Ansible, and GitHub Actions

## 📌 Overview
This project provisions cloud infrastructure using Terraform, configures servers using Ansible, and deploys applications through a GitHub Actions CI/CD pipeline. Follow the steps below to deploy and manage the environment end‑to‑end.

## 🧰 Prerequisites
- Terraform installed locally
- AWS account with required IAM permissions
- GitHub repository forked or cloned
- SSM Session Manager access to connect to the Ansible controller
- Basic knowledge of Ansible and EC2

# 🚀 Deployment Steps

## 1. Clone the Repository
```bash
git clone https://github.com/Vimal1802/devops-bootcamp-project.git
cd devops-bootcamp-project

## 2. Deploy Infrastructure with Terraform
cd terraform
terraform init
terraform plan
terraform apply

## 3. Access the Ansible Controller
AWS Console → EC2 → Ansible Controller → Connect → SSM Session Manager

## 4. Configure Ansible
Change to the Ansible directory:
sudo su - ubuntu -c "cd ansible && bash"

If the Ansible folders are not present yet, the deployment may still be running.  
Check the deployment log in /home/ubuntu to confirm that it has completed (it can take about a minute):
cat deploy.log

### Update the Ansible Inventory
nano inventory.ini  
(Add Web Server and Monitoring Server instance IDs)

### Test Connectivity
ansible all -m ping

## 5. Install Required Packages
ansible-playbook requirements.yml

## 6. Update the Web Server Playbook
nano web-server.yml  
(Update with your ECR repository URL)

## 7. Run the CI/CD Pipeline in GitHub Actions
GitHub → Actions → Build and Deploy → Run Workflow

### Verify the Deployment
Actions → Latest Run → deploy → Trigger Deployment via SSM  
Confirm:
- web_server shows **ok**
- No failures appear
