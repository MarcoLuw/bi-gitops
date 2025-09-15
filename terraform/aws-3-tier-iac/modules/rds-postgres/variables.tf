# RDS PostgreSQL module variables
variable "name" {
    description = "The name of the RDS PostgreSQL instance"
    type        = string
}

variable "subnet_ids" {
    description = "List of subnet IDs for the RDS subnet group"
    type        = list(string)    # e.g. private subnet IDs
}

variable "vpc_security_group_ids" {
    description = "List of VPC security group IDs to attach to the RDS instance"
    type        = list(string)
}

variable "engine_version" {
    description = "The version of the PostgreSQL engine"
    type        = string
    default     = "16.3"   # default: PostgreSQL 16.3
}

variable "instance_class" {
    description = "The instance class for the RDS instance"
    type        = string
    default     = "db.t3.micro"   # default: db.t3.micro
}

variable "allocated_storage" {
    description = "The allocated storage in GB for the RDS instance"
    type        = number
    default     = 20        # default: 20 GB
}

variable "max_allocated_storage" {
    description = "The maximum allocated storage in GB for the RDS instance"
    type        = number
    default     = 100       # default: 100 GB
}

variable "backup_retention_period" {
    description = "The number of days to retain backups"
    type        = number
    default     = 7         # default: 7 days
}

variable "deletion_protection" {
    description = "Whether to enable deletion protection for the RDS instance"
    type        = bool
    default     = true      # prod-like default
}

variable "username" {
    description = "The master username for the RDS instance"
    type        = string
}

variable "password" {
    description = "The master password for the RDS instance"
    type        = string
    sensitive   = true
}

variable "kms_key_id" {
    description = "The KMS key ID for encrypting the RDS instance (if not provided, default AWS RDS KMS key is used)"
    type        = string
    default     = ""        # default: empty string
}

variable "multi_az" {
    description = "Whether to create a Multi-AZ RDS instance"
    type        = bool
    default     = true      # prod-like default
}