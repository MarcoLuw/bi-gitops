# Terraform version constraints
# Not used for now
terraform {
  required_version = ">= 1.8.0, < 1.13.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.7"
    }
  }
}