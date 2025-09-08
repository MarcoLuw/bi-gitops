# aliased "primary"
provider "aws" {
  alias  = "primary"
  region = "ap-southeast-2"
  default_tags {
    tags = {
      Project     = "3-tier-iac"
      Owner       = "platform"
      ManagedBy   = "Terraform"
      Environment = "dev"
      RegionRole  = "primary"
    }
  }
  profile = "primary-account" # AWS CLI profile name
}