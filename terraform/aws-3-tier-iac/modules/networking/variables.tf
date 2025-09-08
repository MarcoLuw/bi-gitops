# Networking module variables
variable "name" {
  type = string     # e.g. "prod-primary"
}

variable "cidr_block" {
  type = string     # e.g. 10.0.0.0/16"
}

variable "azs" {
  type = list(string)  # e.g. ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets" {
  type = list(string)      # e.g. 3 CIDR blocks (one per AZ)
}

variable "app_subnets" {
  type = list(string)      # e.g. 3 CIDR blocks (one per AZ)
}

variable "db_subnets" {
  type = list(string)      # e.g. 3 CIDR blocks (one per AZ)
}

variable "create_natgw_per_az" {
  type    = bool
  default = true        # prod-like default
}

variable "enable_flow_logs" {
  type    = bool
  default = false       # flow logs off by default
}

variable "tags" {
  type    = map(string)
  default = {}          # optional additional tags
}