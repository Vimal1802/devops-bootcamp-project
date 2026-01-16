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

### 📤1.1 Push the Repository to Your Own GitHub Account

Because **GitHub Actions** workflows run exclusively on GitHub and not on local machines, you must push the cloned project to your own GitHub repository before the workflow can execute.

```bash
 git remote remove origin
 ```
 ```bash
 git remote add origin https://github.com/<your-username>/<your-repo>.git
 ```
 ```bash
 git push -u origin main
 ```

### 📤1.2 Add Required GitHub Secrets (Required for CI/CD)

After instrastructure deployment and before running the pipeline, configure these secrets in:

- Go to **GitHub.com**
 - Open Your Repository
 - Click **Settings**
 - Select **Secrets and Variables**
 - Click **Actions**
 - Add the required secrets:
   - **AWS_ACCOUNT_ID** : (Your 12‑digit AWS account number)
   - **AWS_REGION** : (Region used for deployments (e.g., ap-southeast-1))
   - **INSTANCE_ID** : (Ansible Controller Instance ID)

> **Reminder:** *This section is to be completed only upon the completion of Section 2.0.*

## 🏗️ 2. Deploy Infrastructure with Terraform

### 🏗️ 2.1 Configure AWS Credentials (Required Before Using Terraform)

Where to get the AWS credentials

 - Log in to the AWS Console
 - Go to **IAM**
 - Click **Users**
 - Select your **IAM user**
 - Open the **Security Credentials** tab
 - Scroll down to **Access Keys**
 - Create or copy your **Access Key ID** and **Secret Access Key**

Once you have your **Access Key ID** and **Secret Access Key**, proceed to the next section to configure AWS on your machine so you can run Terraform commands for the deployment.

 **Run this command in your local terminal:**
```bash
aws configure
```

You will be prompted to enter the following:

 - AWS Access Key ID : `This is the public part of your AWS access credentials.`
 - AWS Secret Access Key : `This is the private part — keep it secure and never share it.`
 - Default region name (Example): `ap-southeast-1`
 - Default output format : `You can simply press Enter to skip this (usually defaults to JSON).`

### 🏗️ 2.2 Deploy Infrastructure with Terraform

**Go into the Terraform folder**

You need to run all Terraform commands from inside the terraform directory:
```bash
cd terraform
```
**Set up Terraform for the first time**

This command downloads the required Terraform plugins:
```bash
terraform init
```
**Check what Terraform will create**

This provides a preview of the resources Terraform will create, without making any changes since it is only a dry run:
```bash
terraform plan
```
**Deploy your infrastructure**

This command actually builds everything in your AWS account:
```bash
terraform apply
```
**Enable Remote State (after deployment completes)**

Once the infrastructure has successfully deployed:

 - Open the `main.tf` file in the Terraform folder.
 - Find the section labeled `REMOTE STATE MANAGEMENT`
 - Uncomment only the backend block (remove the **#** symbols from the Terraform block, not the heading or description).

 - Save the file.

Then run the following command to update the state:
```bash
terraform init -migrate-state
```

**Reminder:** : *Revisit Section 1.2 and complete it before progressing to the next section.*

## 🖥️ 3. Access the Ansible Controller
 - Log in to the **AWS Management Console**
 - Go to the **EC2** service
 - In the instance list, locate and select **Ansible Controller**
 - Click **Connect** at the top right
 - Choose **Session Manager**
 - Click **Start session**

## ⚙️ 4. Configure Ansible Environment

### ⚙️4.1 Switch to Ubuntu and Open the Ansible Folder

To access the Ansible working directory, switch to the `ubuntu` user and navigate into the `ansible` folder:

```bash
sudo su - ubuntu -c "cd ansible && bash"
```

> **Note:** *If the directory is missing, the initial setup through `user data` is likely still in progress. It may take a few minutes to install dependencies and move the Ansible configuration. Monitor progress with: `cat /home/ubuntu/deploy.log`*


### ⚙️4.2 Update the Ansible Inventory

This step is done after switching to the `ubuntu` user and navigating into the ansible directory using `cd ansible`

```bash
nano inventory.ini
```

- **Instructions**: After opening the file , navigate using your arrow keys and replace the placeholders with your actual **Web Server** and **Monitoring Server** Instance IDs.
- **To Save**: Press `Ctrl + O` then `Enter`.
- **To Exit**: Press `Ctrl + X`.

### ⚙️4.3 Update the Ansible Playbook
```bash
nano web-server.yml
```
- **Instructions**: After opening the file , navigate using your arrow keys and replace the placeholders with your **ECR repository URL**
- **To Save**: Press `Ctrl + O` then `Enter`.
- **To Exit**: Press `Ctrl + X`.


### ⚙️4.4 Test Connectivity
```bash
ansible all -m ping
```

### ⚙️4.5 Install Dependencies
```bash
ansible-playbook requirements.yml
```

## 🚀 5. Run the CI/CD Pipeline in GitHub Actions to deploy the  Web Server

### Initiate the Deployment
Trigger the automated CI/CD pipeline to build your Docker image and deploy it to AWS EC2 via SSM ( `web-server.yml` ansible playbook):



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

> **Note**: *This pipeline has two main steps. First, the **Build** step creates a Docker image of your application and uploads it to Amazon ECR. Then, the **Deploy** step uses the Ansible Controller (through AWS SSM) to run the `web-server.yml` playbook which pulls the newest image, and redeploy the web server. You can watch both steps happen in real time on the GitHub Actions page, and the full workflow is located in `.github/workflows/deploy.yml.`*

## 🌐 6. DNS and TLS Management (Cloudflare)
To make your application accessible via your domain, follow these steps:

### 6.1. DNS Configuration
- Log in to your **Cloudflare Dashboard** and select your domain.
- Navigate to **DNS > Records** and click **Add Record**.
- Create an **A Record**:
   - **Name**: `web` (creates `web.yourdomain.com`)
   - **IPv4 address**: Your **Web Server Public IP**.
   - **Proxy status**: **Proxied** (Orange cloud enabled).

### 6.2. SSL/TLS Encryption
- Navigate to **SSL/TLS > Overview**.
- Click **Configure** and set the encryption mode to **Flexible**.
   *(This secures the connection between the user and Cloudflare while the origin server uses port 80).*

## 📡 7.0 Deploy the Monitoring Server With a Private Cloudflare Tunnel

This step sets up your full monitoring system **Prometheus**, **Grafana**, and supporting components and securely exposes the **Grafana** dashboard to the internet using a private **Cloudflare Tunnel**. This means you can access your monitoring dashboard through your own domain **without opening any ports** on your EC2 instance, keeping everything secure while still being easy to reach.

### 📡 7.1 Update the Grafana Domain in monitoring-server.yml

Before running the `monitoring-server.yml` playbook, you must update the **Grafana** domain settings with your own domain. This ensures **Grafana** works correctly with **Cloudflare Tunnel** and loads properly under your custom URL.

**Edit the Monitoring-Server.yml ansible playbook**

Before editing the `monitoring-server.yml` file, make sure you are inside the `ansible` directory on the **Ansible Controller**.

```bash
nano monitoring-server.yml
```

**Locate the `grafana_ini` Section**

```bash
vars:
  grafana_ini:
    security:
      admin_user: "admin"
      admin_password: "admin"
    server:
      domain: "monitoring.yourdomain.com"
      root_url: "https://monitoring.yourdomain.com"
      http_port: 3000
```

**Update Both Domain Fields**

Replace both values with your own monitoring domain.

```bash
domain: "monitoring.yourdomain.com"
root_url: "https://monitoring.yourdomain.com"
```

- **To Save**: Press `Ctrl + O` then `Enter`.
- **To Exit**: Press `Ctrl + X`.

### 📡 7.2 Deploy the Monitoring Server Using the Cloudflare Token

The monitoring playbook requires a **Cloudflare Tunnel token** so it can authenticate and start the secure tunnel container. This token must be supplied manually when you run the playbook.

**Get Your Cloudflare Tunnel Token**


You can obtain the token from your Cloudflare dashboard:

 - Log in to **Cloudflare**
 - Go to **Zero Trust**
 - Select **Access** → **Tunnels**
 - Choose your tunnel (or create a new one)
 - Copy the **Tunnel Token**

 You will paste this token when running the playbook.

**Deploy the Monitoring Server With the Token**

```bash
ansible-playbook monitoring-server.yml -e "cloudflare_token=abc123xyz987-long-token-value"
```

**Access the Grafana Dashboard**

After the deployment completes, open your browser and go to your monitoring domain  to access the Grafana dashboard.

```bash
https://monitoring.yourdomain.com
```


> **Note**: *You do not need to manually create a DNS or CNAME record in Cloudflare for your monitoring domain. Because this playbook uses a **Cloudflare Tunnel token**, Cloudflare **automatically creates and manages** the required CNAME record when the tunnel starts, so your monitoring domain (e.g., monitoring.yourdomain.com) will point to the correct tunnel endpoint **without any additional setup**.*

### 📡 7.3 Configure Grafana to monitor the Web Server

**Log In to Grafana**

Open your monitoring URL in your browser

```bash
https://monitoring.yourdomain.com
```

Log in with the default Grafana credentials

 - **Username:** admin
 - **Password:** admin

Grafana will ask you to change the password — update it for security.

**Add Prometheus as a Data Source**

Grafana needs to know where Prometheus is running so it can query your Node Exporter metrics.

 - In Grafana’s left sidebar, click **Settings** → **Data Sources**
 - Click **Add data source**
 - Select **Prometheus**
 - Under HTTP URL, enter:
   - `http://localhost:9090`
 - Scroll down and click **Save & Test**
 - You should see: `Data source is working`

**Confirm That Node Exporter Metrics Are Being Collected**

You can confirm Node Exporter is working by querying Prometheus through Grafana.

 - In the left sidebar, click **Explore**
 - Select your Prometheus data source
 - Enter a test query:-
   - **CPU Usage Metrics** : `node_cpu_seconds_total`
   - **Memory Usage Metrics** : `node_memory_MemAvailable_bytes`
   - **Disk Usage Metrics** : `node_filesystem_avail_bytes`
 - You should see time‑series results — this confirms Prometheus is scraping your server.

**Import the Node Exporter Dashboards**

 - In Grafana, click + (Create) → Import
 - In the “Import Via Grafana.com” field, enter dashboard ID: `1860`
 - Click **Load**
 - Select your Prometheus data source
 - Click **Import**

 **View CPU, Memory, and Disk Usage Metrics**

CPU Usage

 - Real‑time CPU usage (%)
 - CPU load averages
 - Per‑core breakdown
 - Idle, user, system time graphs

Memory Usage

 - Total memory
 - Used vs available memory
 - Cache / buffers
 - Memory utilization (%)

Disk Usage

 - Disk space usage per mount point
 - Available vs used bytes
 - Disk I/O read/write throughput
