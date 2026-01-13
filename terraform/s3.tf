# Establishes a durable S3 repository to serve as the centralized "Source of Truth" for infrastructure state management.
resource "aws_s3_bucket" "terraform_state" {
  bucket = "devops-bootcamp-terraform-vimaldeep"
  
  # Business Guardrail: Prevents accidental deletion of critical state history during automated cleanups.
  lifecycle {
    prevent_destroy = true
  }
}

# Activates state-level versioning to provide a robust audit trail and point-in-time recovery for infrastructure changes.
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
