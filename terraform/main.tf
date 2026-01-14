# #1. TERRAFORM & PROVIDER CONFIGURATION
# Defines the required provider plugins and versions to ensure environment consistency.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }
}

# #2. AWS PROVIDER AUTHENTICATION
# Standardizes authentication by leveraging the active AWS CLI session for secure access.
provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
}

# #3. CALLER IDENTITY DATA SOURCE
# Queries the AWS ecosystem to retrieve verified identity metadata for the current session.
data "aws_caller_identity" "current" {}

# #4. REMOTE STATE MANAGEMENT
# Uncomment this block once the initial resources are provisioned and run 'terraform init -migrate-state' to transition the local state file.
# terraform {
#   backend "s3" {
#     bucket = "devops-bootcamp-terraform-vimaldeep"
#     key    = "global/s3/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }
