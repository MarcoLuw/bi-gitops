# Terraform variables for dev primary region (ap-southeast-2)

# terraform.tfvars are only automatically loaded when run terraform in the root module directory
# child modules (e.g. modules/alb) are loaded/called explicitly by the root module, not terraform cli directly
# thus, there's no mechanism to auto-load .tfvars for child modules - all variables must be passed from root module

vpc_cidr = "172.16.0.0/16" # dev-primary VPC CIDR
azs      = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]

public_cidrs = ["172.16.0.0/20", "172.16.48.0/20", "172.16.96.0/20"]   # 3 cidrs (web)
app_cidrs    = ["172.16.16.0/20", "172.16.64.0/20", "172.16.112.0/20"] # 3 cidrs (app)
db_cidrs     = ["172.16.32.0/20", "172.16.80.0/20", "172.16.128.0/20"] # 3 cidrs (db)

domain_zone_id  = "value"
record_name     = "value"
certificate_arn = "value"

web_ami_id = "value"
app_ami_id = "value"

db_username = "admin"
db_password = "REDACTED" # ideally from a secret manager
kms_key_id  = "value"