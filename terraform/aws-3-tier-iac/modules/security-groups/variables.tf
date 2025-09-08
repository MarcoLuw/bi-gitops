# Security groups module variables
variable "vpc_id" {
    description = "The ID of the VPC where security groups will be created"
    type        = string
}

variable "name_prefix" {
    description = "Prefix for naming the security groups"
    type        = string
    default     = "sg-3-tier"   # default prefix
    validation {
        condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 20
        error_message = "Name prefix must be between 1 and 20 characters."
    }
}

variable "alb_web_sg_ingress_cidrs" {
    description = "List of CIDR blocks allowed to access the ALB web security group"
    type        = list(string)
    default = ["0.0.0.0/0"]
    validation {
        condition = alltrue([
            for cidr in var.alb_web_sg_ingress_cidrs : can(cidrhost(cidr, 0))
        ])
        error_message = "All CIDR blocks must be valid IPv4 notation."
    }
}

variable "alb_web_port" {
    description = "Port for the ALB web access (HTTP)"
    type        = number
    default     = 80
}

variable "alb_web_ssl_port" {
    description = "Port for the ALB web access (HTTPS)"
    type        = number
    default     = 443
}

variable "alb_app_sg_ingress_cidrs" {
    description = "List of CIDR blocks allowed to access the ALB app security group"
    type        = list(string)
    default     = ["0.0.0.0/0"]
    validation {
        condition = alltrue([
            for cidr in var.alb_app_sg_ingress_cidrs : can(cidrhost(cidr, 0))
        ])
        error_message = "All CIDR blocks must be valid IPv4 notation."
    }
}

variable "alb_app_port" {
    description = "Port for the ALB app access (HTTP)"
    type        = number
    default     = 3000
}

variable "web_port" {
    description = "Port for the web server access (HTTP)"
    type = number
    default = 80
}

variable "app_port" {
    description = "Port for the app server access (HTTP)"
    type        = number
    default     = 3000
}

variable "redis_port" {
    description = "Port for the Redis cache access"
    type        = number
    default     = 6379
}

variable "db_port" {
    description = "Port for the PostgreSQL database access"
    type        = number
    default     = 5432
}

variable "enable_ssh" {
    description = "Whether to enable SSH access to the app security group"
    type        = bool
    default     = false       # prod default: off
}