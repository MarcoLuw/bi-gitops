# Multi-AZ, subnet group, param group, security, backups

# Get db password
data "aws_secretsmanager_secret_version" "db_password" {
    secret_id = var.password   # expects the full ARN or name of the secret
}

# Subnet Group
resource "aws_db_subnet_group" "this" {
    name       = var.name
    description = "Subnet group for RDS PostgreSQL instance ${var.name}"
    subnet_ids = var.subnet_ids
    tags = {
        Name = "${var.name}-db-subnet-group"
    }
}

# --- Parameter Group (optional: tweak if needed) ---
resource "aws_db_parameter_group" "this" {
    name        = "${var.name}-param-group"
    family      = "postgres${split(".", var.engine_version)[0]}"
    description = "Parameter group for RDS PostgreSQL instance ${var.name}"
    tags = {
        Name = "${var.name}-db-param-group"
    }

    # Example parameter overrides (uncomment and modify as needed)
    # parameter {
    #     name  = "max_connections"
    #     value = "150"
    #     apply_method = "pending-reboot"
    # }
}

# RDS PostgreSQL instance
resource "aws_db_instance" "this" {
    identifier              = "${var.name}-postgres"

    engine                  = "postgres"
    engine_version          = var.engine_version
    instance_class          = var.instance_class

    username                = var.username
    password                = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]

    allocated_storage       = var.allocated_storage
    max_allocated_storage   = var.max_allocated_storage

    multi_az                = var.multi_az
    db_subnet_group_name    = aws_db_subnet_group.this.name
    vpc_security_group_ids  = var.vpc_security_group_ids
    parameter_group_name    = aws_db_parameter_group.this.name
    
    backup_retention_period = var.backup_retention_period
    deletion_protection     = var.deletion_protection
    skip_final_snapshot     = true   # for dev/test; set to false for prod
    
    publicly_accessible     = false
    storage_encrypted       = true ? var.kms_key_id != "" : false
    kms_key_id              = var.kms_key_id != "" ? var.kms_key_id : null
    
    apply_immediately       = true
    
    tags = {
        Name = "${var.name}-postgres"
    }

    lifecycle {
        create_before_destroy = true
    }
}