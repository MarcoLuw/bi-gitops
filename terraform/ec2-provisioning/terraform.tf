# Define the required providers and their versions
# This block specifies the providers that Terraform will use to manage resources.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.7"
    }
  }

  required_version = ">= 1.2" # Terraform version
}