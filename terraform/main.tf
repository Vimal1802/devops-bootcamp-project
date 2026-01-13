terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }
}

# Standardizes authentication by leveraging the active AWS CLI session for secure access.
provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
}

# Queries the AWS ecosystem to retrieve verified identity metadata for the current session.
data "aws_caller_identity" "current" {}

# Provides visibility into the target AWS Account ID for auditing and validation purposes.
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

# Exports the specific Identity and Access Management (IAM) ARN for session traceability.
output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

# --- REMOTE STATE MANAGEMENT ---
# Uncomment this block once the initial resources are provisioned and run 'terraform init -migrate-state' to transition the local state file.
# terraform {
#   backend "s3" {
#     bucket = "devops-bootcamp-terraform-vimaldeep"
#     key    = "global/s3/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }
