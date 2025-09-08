# Provider configurations - Global settings - Not used for now
provider "aws" {
  region = "ap-southeast-2"  # Placeholder region; override in environment-specific configs
  default_tags {
    tags = {
        Project = "3-tier-iac"
        Owner = "platform"
        ManagedBy = "Terraform"
        Environment = "unknown" # Override in environment-specific configs
    }
  }
}