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
git clone https://github.com/Vimal1802/devops-bootcamp-project.git && cd devops-bootcamp-project
```

## 2. Deploy Infrastructure with Terraform
```bash
cd terraform
```
```bash
terraform init
```
```bash
terraform plan
```
```bash
terraform apply
```
```bash
terraform init -migrate-state
```

## 3. Access the Ansible Controller
AWS Console → EC2 → Ansible Controller → Connect → SSM Session Manager

## 4. Configure Ansible
Change to the Ansible directory:
```bash
sudo su - ubuntu -c "cd ansible && bash"
```

If the Ansible folders are not present yet, the deployment may still be running.  
Check the deployment log in /home/ubuntu to confirm that it has completed (it can take about a minute):
```bash
cat deploy.log
```

### Update the Ansible Inventory
(Add Web Server and Monitoring Server instance IDs)
```bash
nano inventory.ini
```

### Test Connectivity
```bash
ansible all -m ping
```

## 5. Install Required Packages
```bash
ansible-playbook requirements.yml
```

## 6. Update the Web Server Playbook
(Update with your ECR repository URL)
```bash
nano web-server.yml
```

## 7. Run the CI/CD Pipeline in GitHub Actions
GitHub → Actions → Build and Deploy → Run Workflow

### Verify the Deployment
Actions → Latest Run → deploy → Trigger Deployment via SSM  
Confirm:
- web_server shows **ok**
- No failures appear

## 8. DNS and TLS Management (Cloudflare)
To make your application accessible via your domain, follow these steps:

**a. Configure DNS Records
**
1. Browse to your Cloudflare Homepage and select your domain.

2. Navigate to DNS > Records.

3. Click Add Record:

*Type: A

*Name: web (This results in web.vimalops.com)

*IPv4 address: Paste your Web Server Public IP Address.

*Proxy status: Proxied (Orange cloud).

4. Click Save.

**b. Configure SSL/TLS
**
1. Navigate to SSL/TLS > Overview.

2. Click Configure.

3. Select Flexible mode. (This ensures encryption between the browser and Cloudflare while your origin server handles traffic on port 80).
