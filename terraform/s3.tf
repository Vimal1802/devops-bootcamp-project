# The S3 Bucket for State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "devops-bootcamp-terraform-vimaldeep"
  lifecycle {
    prevent_destroy = true
  }
}

# Enable Versioning for state recovery
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ansible_cleanup" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "cleanup-ansible-temp"
    status = "Enabled"

    filter {
      prefix = "ansible-temp/"
    }

    # Delete the current version after 1 day
    expiration {
      days = 1
    }

    # Delete non-current versions (history) after 1 day to save costs on your versioned bucket
    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}