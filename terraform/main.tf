terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }
}
#Terraform will automatically pull the credentials you just entered in the CLI.
provider "aws" {
  region  = var.region
  profile = "default"
}

# Data source to get the current AWS account details
data "aws_caller_identity" "current" {}

# Outputs to display account id after running 'terraform apply'
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

# Outputs to display current profile id after running 'terraform apply'
output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

# #UNCOMMENT THE BLOCK BELOW ONLY AFTER RUNNING 'terraform apply'
# terraform {
#   backend "s3" {
#     bucket = "devops-bootcamp-terraform-vimaldeep"
#     key    = "global/s3/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }