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
  alb_web_sg_ingress_cidrs = ["0.0.0.0/0"]                       # cidrs allowed to access ALB web SG
  alb_app_sg_ingress_cidrs = var.public_cidrs                   # cidrs (web tier) allowed to access ALB app SG
  alb_web_port             = 80
  alb_app_port             = 3000
  web_port                 = 80
  app_port                 = 3000
  redis_port               = 6379
  db_port                  = 5432
  enable_ssh               = true
  providers = {
    aws = aws.primary
  }
}

# ## Public ALB (Web Tier)
# module "alb_web" {
#     source = "../../../modules/alb"
#     name = "${local.name_prefix}-web"
#     internal = false
#     subnet_ids = module.networking.public_subnet_ids
#     security_group_ids = [module.sg.alb_web_sg_id]
#     certificate_arn = var.certificate_arn
#     health_check = {
#         path                = "/healthz"
#         matcher             = "200-399"
#         interval            = 30
#         healthy_threshold   = 3
#         unhealthy_threshold = 3
#         timeout             = 3
#     }
#     providers = {
#       aws = aws.primary
#     }
# }

# ## Internal ALB (App Tier)
# module "alb_app" {
#     source = "../../../modules/alb"
#     name = "${local.name_prefix}-app"
#     internal = true
#     subnet_ids = module.networking.app_subnet_ids
#     security_group_ids = [module.sg.alb_app_sg_id]
#     health_check = {
#         path                = "/healthz"
#         matcher             = "200-399"
#         interval            = 30
#         healthy_threshold   = 3
#         unhealthy_threshold = 3
#         timeout             = 3
#     }
#     providers = {
#       aws = aws.primary
#     }
# }

# ## Web Tier ASG (public subnets)
# module "asg_web" {
#     source = "../../../modules/asg-ec2"
#     name = "${local.name_prefix}-web"
#     subnet_ids = module.networking.public_subnet_ids
#     security_group_ids = [module.sg.web_ec2_sg_id]
#     ami_id = var.web_ami_id
#     iam_instance_profile = ""   # pre-created IAM instance profile name
#     target_group_arns = [module.alb_web.target_group_arn]
#     desired_capacity = 2
#     min_size = 2
#     max_size = 4
#     instance_type = "t3.micro"
#     enable_detailed_monitoring = false
#     user_data = ""
#     providers = {
#       aws = aws.primary
#     }
# }

# ## App Tier ASG (private subnets)
# module "asg_app" {
#     source = "../../../modules/asg-ec2"
#     name = "${local.name_prefix}-app"
#     subnet_ids = module.networking.app_subnet_ids
#     security_group_ids = [module.sg.app_ec2_sg_id]
#     ami_id = var.app_ami_id
#     iam_instance_profile = ""   # pre-created IAM instance profile name
#     target_group_arns = [module.alb_app.target_group_arn]
#     desired_capacity = 2
#     min_size = 2
#     max_size = 4
#     instance_type = "t3.micro"
#     enable_detailed_monitoring = false
#     user_data = ""
#     providers = {
#         aws = aws.primary
#     }
# }

# ## Redis (private app subnets)
# module "redis" {
#     source = "../../../modules/elasticache-redis"
#     name = "${local.name_prefix}-redis"
#     subnet_ids = module.networking.app_subnet_ids
#     vpc_security_group_ids = [module.sg.reids_sg_id]
#     node_type = "cache.t3.micro"
#     replicas_per_shard = 1
#     automatic_failover = true
#     multi_az = true
#     num_cache_clusters = 2
#     providers = {
#         aws = aws.primary
#     }
# }

# ## RDS PostgreSQL (private db subnets)
# module "db" {
#     source = "../../../modules/rds-postgres"
#     name = "${local.name_prefix}-db"
#     subnet_ids = module.networking.db_subnet_ids
#     vpc_security_group_ids = [module.sg.db_sg_id]
#     instance_class = "db.t3.micro"
#     multi_az = true
#     allocated_storage = 20
#     max_allocated_storage = 100
#     username = var.db_username
#     password = var.db_password
#     kms_key_id = var.kms_key_id

#     providers = {
#         aws = aws.primary
#     }
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

