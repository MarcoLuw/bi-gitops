# Variables for dev primary region
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = ""
}
variable "azs" {
  description = "List of availability zones in the region"
  type        = list(string)
  default     = []
}
variable "public_cidrs" { # 3 cidrs (web)
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = []
}
variable "app_cidrs" { # 3 cidrs (app)
  description = "List of CIDR blocks for application subnets"
  type        = list(string)
  default     = []
}
variable "db_cidrs" { # 3 cidrs (db)
  description = "List of CIDR blocks for database subnets"
  type        = list(string)
  default     = []
}

### Profile
variable "iam_instance_profile" {
  description = "IAM instance profile to attach to the EC2 instances so that they can access AWS services"
  type        = string
  default     = ""
} # instance profile name for EC2 instances

#####
variable "domain_zone_id" {
  description = "Route53 hosted zone ID for the domain"
  type        = string
  default     = ""
}
variable "record_name" {
  description = "DNS record name for the application"
  type        = string
  default     = "" # e.g. "app.example.com"
}
variable "record_type" {
  description = "DNS record type (A, CNAME, etc.)"
  type        = string
  default     = "A"
}
variable "certificate_arn" {
  description = "ARN of the ACM certificate for the ALB"
  type        = string
  default     = "" # e.g. "arn:aws:acm:us-east-1:123456
}

###
variable "private_zone_name" {
  description = "Name of the private hosted zone for internal DNS"
  type        = string
  default     = "" # e.g. "internal.dev.example.com"
}

#####
variable "web_ami_id" {
  description = "AMI ID for the web servers"
  type        = string
  default     = "" # e.g. "ami-0abcdef1234567890"
}
variable "app_ami_id" {
  description = "AMI ID for the app servers"
  type        = string
  default     = "" # e.g. "ami-0abcdef1234567890"
}

#####
variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "admin" # sensible default
}
variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  default     = "" # no default - must be set via TF_VAR or env var
  sensitive   = true
}
variable "kms_key_id" {
  description = "KMS Key ID for encrypting RDS storage"
  type        = string
  default     = "" # e.g. "arn:aws:kms:us-east-1:123456:key/abcd-efgh-ijkl"
}

#### Secrets Manager key names for EC2 instances to retrieve at startup
variable "app_userdata_secret_keys" {
  description = "Secrets Manager key names for app EC2 instances to retrieve at startup"
  type        = string
  default     = "" # e.g. "dev/primary/app_userdata"
}

variable "web_userdata_secret_keys" {
  description = "Secrets Manager key names for web EC2 instances to retrieve at startup"
  type        = string
  default     = "" # e.g. "dev/primary/web_userdata"
}