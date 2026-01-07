variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Name        = "infratify"
    Environment = "dev"
    ManagedBy   = "terraform"
    Project     = "bootcamp-infratify"
  }
}

variable "availability_zones" {
  description = "List of AZs"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}