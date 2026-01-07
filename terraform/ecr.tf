resource "aws_ecr_repository" "basic_repo" {
  name         = "devops-bootcamp/final-project-vimaldeep"
  force_delete = true
}

output "repo_url" {
  value = aws_ecr_repository.basic_repo.repository_url
}