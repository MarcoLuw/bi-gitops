# calls modules/* once (primary region)
# modules are wired together using module inputs/outputs and local values

# provider: defined in providers.tf
# backend: defined in backend.tf


# local values for naming and tagging
# locals are module-scoped values (not inputs)
# locals do not create resources or appear in the state file
locals {
  name_prefix = "dev-primary"
  tags = {
    Project     = "3-tier-iac"
    Owner       = "platform"
    ManagedBy   = "Terraform"
    Environment = "dev"
    RegionRole  = "primary"
  }
}

# This is to retrieve the secret values from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "app_userdata" {
  provider  = aws.primary
  secret_id = var.app_userdata_secret_keys
}

# Create map of secrets for userdata template
locals {
  app_userdata_secrets = jsondecode(data.aws_secretsmanager_secret_version.app_userdata.secret_string)
}

## Networking
module "networking" {
  source              = "../../../modules/networking"
  name                = local.name_prefix
  cidr_block          = var.vpc_cidr
  azs                 = var.azs
  public_subnets      = var.public_cidrs
  app_subnets         = var.app_cidrs
  db_subnets          = var.db_cidrs
  create_natgw_per_az = true
  tags                = local.tags

  providers = {
    aws = aws.primary
  }
}

## Security Groups
module "sg" {
  source                   = "../../../modules/security-groups"
  vpc_id                   = module.networking.vpc_id
  name_prefix              = local.name_prefix
  alb_web_sg_ingress_cidrs = ["0.0.0.0/0"] # cidrs allowed to access ALB web SG
  # alb_app_sg_ingress_cidrs = var.public_cidrs                   # sg (web tier) allowed to access ALB app SG
  alb_web_port = 80
  alb_app_port = 80
  web_port     = 3000
  app_port     = 8000
  redis_port   = 6379
  db_port      = 5432
  enable_ssh   = true
  providers = {
    aws = aws.primary
  }
}

## Domain (Route53 record to primary ALB)
module "route53_record" {
  source                 = "../../../modules/route53/route53-record"
  zone_id                = var.domain_zone_id
  record_name            = var.record_name             # e.g. "app.example.com"
  record_type            = var.record_type             # A, CNAME, etc.
  ttl                    = 300                         # in seconds
  alias_name             = module.alb_web.alb_dns_name # ALB DNS name
  alias_zone_id          = module.alb_web.alb_zone_id  # ALB hosted zone ID
  evaluate_target_health = true                        # whether to evaluate target health
  providers = {
    aws = aws.primary
  }
}

## Private Hosted Zone (for internal app DNS)
module "route53_private_zone" {
  source               = "../../../modules/route53/route53-hosted-zone"
  zone_name            = var.private_zone_name # e.g. "internal.example.com"
  comment              = "Private hosted zone for internal app"
  force_destroy        = false
  vpc_ids              = [module.networking.vpc_id]
  create_alias_record  = true
  record_name          = "app.${var.private_zone_name}" # e.g. "app.internal.example.com"
  alias_target_dns     = module.alb_app.alb_dns_name    # internal ALB DNS name
  alias_target_zone_id = module.alb_app.alb_zone_id     # internal ALB hosted zone ID
  tags                 = local.tags
  providers = {
    aws = aws.primary
  }
}

## Public ALB (Web Tier)
module "alb_web" {
  source             = "../../../modules/alb"
  name               = "${local.name_prefix}-web"
  vpc_id             = module.networking.vpc_id
  internal           = false
  subnet_ids         = module.networking.public_subnet_ids
  security_group_ids = [module.sg.alb_web_sg_id]
  target_group_port  = 3000
  # certificate_arn = var.certificate_arn     # optional ACM certificate ARN for HTTPS listener
  # listener_https = true               # optional HTTPS listener on port 443
  # target_type = "instance"          # ALB target type: instance, ip, or lambda
  health_check = {
    path                = "/" # health check path - default to dashboard
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 3
  }
  providers = {
    aws = aws.primary
  }
}

## Internal ALB (App Tier)
module "alb_app" {
  source             = "../../../modules/alb"
  name               = "${local.name_prefix}-app"
  vpc_id             = module.networking.vpc_id
  internal           = true
  subnet_ids         = module.networking.app_subnet_ids
  security_group_ids = [module.sg.alb_app_sg_id]
  target_group_port  = 8000
  health_check = {
    path                = "/health"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 3
  }
  providers = {
    aws = aws.primary
  }
}

## Web Tier ASG (public subnets)
module "asg_web" {
  source                     = "../../../modules/asg-ec2"
  name                       = "${local.name_prefix}-web"
  subnet_ids                 = module.networking.public_subnet_ids
  security_group_ids         = [module.sg.web_ec2_sg_id]
  ami_id                     = var.web_ami_id
  iam_instance_profile       = var.iam_instance_profile # pre-created IAM instance profile name
  target_group_arns          = [module.alb_web.alb_target_group_arn]
  desired_capacity           = 2
  min_size                   = 2
  max_size                   = 4
  instance_type              = "t3.medium"
  enable_detailed_monitoring = false

  # User data configuration
  user_data_template = "web-userdata.sh"
  user_data_vars = {
    # "NEXT_PUBLIC_API_URL" = "app.${var.private_zone_name}"
    "API_GITHUB_TOKEN"    = local.app_userdata_secrets["API_GITHUB_TOKEN"]
    "GIT_REPO_PATH"       = local.app_userdata_secrets["GIT_REPO_PATH"]
    "NEXT_PUBLIC_API_URL" = try(module.route53_private_zone.alias_record_name, "") != "" ? "http://${module.route53_private_zone.alias_record_name}" : "http://app.${var.private_zone_name}"
    "NEXT_PUBLIC_API_KEY" = local.app_userdata_secrets["INTERNAL_API_KEY"]
  }
  # user_data_base64           = "" # optional pre-encoded user data (takes precedence over template)

  providers = {
    aws = aws.primary
  }
}

## App Tier ASG (private subnets)
module "asg_app" {
  source                     = "../../../modules/asg-ec2"
  name                       = "${local.name_prefix}-app"
  subnet_ids                 = module.networking.app_subnet_ids
  security_group_ids         = [module.sg.app_ec2_sg_id]
  ami_id                     = var.app_ami_id
  iam_instance_profile       = var.iam_instance_profile # pre-created IAM instance profile name
  target_group_arns          = [module.alb_app.alb_target_group_arn]
  desired_capacity           = 2
  min_size                   = 2
  max_size                   = 4
  instance_type              = "t3.micro"
  enable_detailed_monitoring = false

  # User data configuration
  user_data_template = "app-userdata.sh"
  user_data_vars = {
    "API_GITHUB_TOKEN"          = local.app_userdata_secrets["API_GITHUB_TOKEN"]
    "GIT_REPO_PATH"             = local.app_userdata_secrets["GIT_REPO_PATH"]
    "RAILWAY_API_TOKEN_"        = local.app_userdata_secrets["RAILWAY_API_TOKEN_"]
    "GOOGLE_GEMINI_API_KEY"     = local.app_userdata_secrets["GOOGLE_GEMINI_API_KEY"]
    "DB_CONNECTION_STRING"      = local.app_userdata_secrets["DB_CONNECTION_STRING"]
    "SUPABASE_ENDPOINT_URL"     = local.app_userdata_secrets["SUPABASE_ENDPOINT_URL"]
    "SUPABASE_REGION"           = local.app_userdata_secrets["SUPABASE_REGION"]
    "BUCKET_ACCESS_KEY_ID"      = local.app_userdata_secrets["BUCKET_ACCESS_KEY_ID"]
    "BUCKET_ACCESS_KEY_SECRET"  = local.app_userdata_secrets["BUCKET_ACCESS_KEY_SECRET"]
    "INTERNAL_API_KEY"          = local.app_userdata_secrets["INTERNAL_API_KEY"]
    "DOPPLER_TOKEN"             = local.app_userdata_secrets["DOPPLER_TOKEN"]
    "NGINX_BASIC_AUTH_USERNAME" = local.app_userdata_secrets["NGINX_BASIC_AUTH_USERNAME"]
    "NGINX_BASIC_AUTH_PASSWORD" = local.app_userdata_secrets["NGINX_BASIC_AUTH_PASSWORD"]
    "REDIS_PASSWORD"            = local.app_userdata_secrets["REDIS_PASSWORD"]
  }
  # user_data_base64           = "" # optional pre-encoded user data (takes precedence over template)

  providers = {
    aws = aws.primary
  }
}

# Disabled for now to save costs
# ## Redis (private app subnets)
# module "redis" {
#   source                 = "../../../modules/elasticache-redis"
#   name                   = "${local.name_prefix}-redis"
#   subnet_ids             = module.networking.app_subnet_ids
#   vpc_security_group_ids = [module.sg.redis_sg_id]
#   node_type              = "cache.t3.micro"
#   automatic_failover     = true
#   multi_az               = true
#   cluster_mode           = false
#   num_cache_clusters     = 2
#   providers = {
#     aws = aws.primary
#   }
# }

# ## RDS PostgreSQL (private db subnets)
# module "db" {
#   source                 = "../../../modules/rds-postgres"
#   name                   = "${local.name_prefix}-db"
#   subnet_ids             = module.networking.db_subnet_ids
#   vpc_security_group_ids = [module.sg.db_sg_id]
#   engine_version         = "16.3"
#   instance_class         = "db.t3.micro"
#   multi_az               = true
#   allocated_storage      = 20
#   max_allocated_storage  = 100
#   username               = var.db_username
#   password               = var.db_password # Key from AWS Secrets Manager
#   kms_key_id             = var.kms_key_id

#   deletion_protection = false # for dev/test; set to true for prod

#   providers = {
#     aws = aws.primary
#   }
# }

# ## WAF (protect public ALB)
# module "waf" {
#     source = "../../../modules/waf"
#     name = "${local.name_prefix}-waf"
#     alb_arn = module.alb_web.alb_arn
#     providers = {
#       aws = aws.primary
#     }
# }

