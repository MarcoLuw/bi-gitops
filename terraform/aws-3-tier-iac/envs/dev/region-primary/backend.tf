# Backend configuration for dev primary region

# What is backend.tf briefly?
# This file configures the backend for Terraform state management.
# It specifies where and how the Terraform state is stored, ensuring
# that the state is maintained consistently across different environments
# and team members. In this case, it uses an S3 bucket for remote state storage
# and DynamoDB for state locking to prevent concurrent modifications.

terraform {
  backend "s3" {
    bucket = "tfstate-3-tier-prod"
    key    = "dev/primary-region/primary.tfstate"
    region = "ap-southeast-2" # AWS region of the S3 bucket
    # dynamodb_table = "tfstate-3-tier-prod-locks"  # DynamoDB table name for state locking - deprecated
    # use_lockfile   = "tfstate-3-tier-prod-locks"
    # encrypt        = true
    profile = "primary-account"
  }
}