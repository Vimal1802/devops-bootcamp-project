# #1. IDENTITY METADATA
# Provides visibility into the target AWS Account ID for auditing and validation purposes.
output "account_id" {
  description = "The AWS Account ID being utilized"
  value       = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  description = "The IAM ARN of the user/role running Terraform"
  value       = data.aws_caller_identity.current.arn
}

# #2. COMPUTE INSTANCE IDENTIFIERS
# These IDs are used as 'INSTANCE_ID' secrets in GitHub Actions for SSM targeting.
output "web_server_id" {
  description = "Instance ID of the Web Server"
  value       = aws_instance.web_server.id
}

output "monitoring_server_id" {
  description = "Instance ID of the Monitoring Server"
  value       = aws_instance.monitoring_server.id
}

output "ansible_controller_id" {
  description = "Instance ID of the Ansible Controller"
  value       = aws_instance.ansible_controller.id
}

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}

# #3. CONTAINER REGISTRY
# The endpoint where GitHub Actions will push the Docker images.
output "repo_url" {
  description = "The URL of the ECR Repository"
  value       = aws_ecr_repository.basic_repo.repository_url
}
