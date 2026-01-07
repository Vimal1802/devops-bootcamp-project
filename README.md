# DevOps Bootcamp Project

This repository contains the infrastructure and configuration code for the DevOps bootcamp project.

## 📂 Project Structure
```text
devops-bootcamp-project/
├── terraform/     # Infrastructure as Code for AWS (EC2, VPC, etc.)
├── ansible/       # Configuration Management (Playbooks & Inventory)
└── README.md      # This documentation
```

## 🚀 Getting Started

### Prerequisites
* Terraform >= 1.0
* Ansible >= 2.10
* AWS CLI configured with appropriate credentials

### How to use
1. **Infrastructure:** Navigate to `terraform/`, run `terraform init` and `terraform apply`.
2. **Configuration:** Update your `inventory.ini` in `ansible/` with the new EC2 IP, then run your playbooks.
