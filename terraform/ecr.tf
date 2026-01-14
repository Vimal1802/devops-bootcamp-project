# 1. PRIMARY CONTAINER REPOSITORY
# Establishes a secure, private ECR repository for hosting the final project's container images.
resource "aws_ecr_repository" "basic_repo" {
  name         = "devops-bootcamp/final-project-vimaldeep"
  
  # Lifecycle Management: Enables seamless environment teardown by allowing 
  # Terraform to delete the repository even if it contains stored images.
  force_delete = true
}

# 2. REPOSITORY ENDPOINT EXPORT
# Provides the unique URI required by the GitHub Actions pipeline to authenticate and push Docker images.
output "repo_url" {
  value = aws_ecr_repository.basic_repo.repository_url
}
