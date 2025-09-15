# Terraform variables for dev primary region (ap-southeast-2)

# terraform.tfvars are only automatically loaded when run terraform in the root module directory
# child modules (e.g. modules/alb) are loaded/called explicitly by the root module, not terraform cli directly
# thus, there's no mechanism to auto-load .tfvars for child modules - all variables must be passed from root module

vpc_cidr = "172.16.0.0/16" # dev-primary VPC CIDR
azs      = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]

public_cidrs = ["172.16.0.0/20", "172.16.48.0/20", "172.16.96.0/20"]   # 3 cidrs (web)
app_cidrs    = ["172.16.16.0/20", "172.16.64.0/20", "172.16.112.0/20"] # 3 cidrs (app)
db_cidrs     = ["172.16.32.0/20", "172.16.80.0/20", "172.16.128.0/20"] # 3 cidrs (db)

iam_instance_profile = "EC2RoleFullAccess" # instance profile name for EC2 instances

domain_zone_id  = "Z03680853JSIHT33FQKHC" # Route53 hosted zone ID for the domain
record_name     = "web.dev.com"           # e.g. "app.example.com"
record_type     = "A"                     # A, CNAME, etc.
certificate_arn = ""

# Private Hosted Zone (for internal app DNS)
private_zone_name = "internal.dev.com"

web_ami_id = "ami-020e2d6e7640876e9"
app_ami_id = "ami-020e2d6e7640876e9"

db_username = "postgres"
db_password = "dev/primary/db_password" # Key from AWS Secrets Manager
kms_key_id  = ""                        # Optional

# Secrets Manager key names for EC2 instances to retrieve at startup
app_userdata_secret_keys = "dev/primary/app_userdata"
# web_userdata_secret_keys = "dev/primary/web_userdata"