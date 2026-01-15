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

## 📥 1. Clone the Repository
```bash
git clone https://github.com/Vimal1802/devops-bootcamp-project.git && cd devops-bootcamp-project
```

## 🏗️ 2. Deploy Infrastructure with Terraform
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

## 🖥️ 3. Access the Ansible Controller
AWS Console → EC2 → Ansible Controller → Connect → SSM Session Manager

## ⚙️ 4. Configure Ansible Environment
Switch to the `ubuntu` user and navigate to the Ansible working directory. 

```bash
sudo su - ubuntu -c "cd ansible && bash"
```

> **Note:** If the directory is missing, the initial setup through `user data` is likely still in progress. It may take a few minutes to install dependencies and move the Ansible configuration. Monitor progress with: `cat /home/ubuntu/deploy.log`


### Update the Ansible Inventory
```bash
nano inventory.ini
```

- **Instructions**: After opening the file , navigate using your arrow keys and replace the placeholders with your actual **Web Server** and **Monitoring Server** Instance IDs.
- **To Save**: Press `Ctrl + O` then `Enter`.
- **To Exit**: Press `Ctrl + X`.

### Update the Ansible Playbook
```bash
nano web-server.yml
```
- **Instructions**: After opening the file , navigate using your arrow keys and replace the placeholders with your **ECR repository URL**
- **To Save**: Press `Ctrl + O` then `Enter`.
- **To Exit**: Press `Ctrl + X`.


### Test Connectivity
```bash
ansible all -m ping
```

## Install Dependencies
```bash
ansible-playbook requirements.yml
```

## 🚀 5. Run the CI/CD Pipeline in GitHub Actions to deploy the  Web Server

### Initiate the Deployment
Trigger the automated CI/CD pipeline to build your Docker image and deploy it to AWS EC2 via SSM ( `web-server.yml` playbook):

- Navigate to your **GitHub Repository** and click on the **Actions** tab.

- In the left sidebar, select the **Build and Deploy** workflow.

- Click the **Run workflow** dropdown menu on the right.

- Ensure the **Main** branch is selected and click the green **Run workflow** button.

### Verify the Deployment
Once the workflow finishes, verify the results in the logs:

- Navigate to **Actions** → Click on the **Latest Run.**

- Select the **deploy** job from the sidebar.

- Expand the **Trigger Deployment via SSM** step to view the Ansible output.

- Confirm the following:

  - Status: The `web_server` should show **ok** or **changed.**

  - Failures: Ensure the `failed` count is `0`.

> **Note**: The CI/CD pipeline consists of two distinct stages: **Build** (packaging the application into a Docker image and pushing it to ECR) and **Deploy** (triggering Ansible via SSM). You can monitor the real-time progress and logs for both stages directly on the **Actions** page.

## 🌐 6. DNS and TLS Management (Cloudflare)
To make your application accessible via your domain, follow these steps:

### a. DNS Configuration
- Log in to your **Cloudflare Dashboard** and select your domain.
- Navigate to **DNS > Records** and click **Add Record**.
- Create an **A Record**:
   - **Name**: `web` (creates `web.yourdomain.com`)
   - **IPv4 address**: Your **Web Server Public IP**.
   - **Proxy status**: **Proxied** (Orange cloud enabled).

### b. SSL/TLS Encryption
- Navigate to **SSL/TLS > Overview**.
- Click **Configure** and set the encryption mode to **Flexible**.
   *(This secures the connection between the user and Cloudflare while the origin server uses port 80).*
