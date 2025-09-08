# ASG EC2 module variables
variable "name" {
    description = "Name of the ASG"
    type        = string
}

variable "subnet_ids" {
    description = "List of subnet IDs for the ASG"
    type        = list(string)
}

variable "security_group_ids" {
    description = "List of security group IDs to attach to the ASG instances"
    type        = list(string)
}

variable "min_size" {
    description = "Minimum number of instances in the ASG"
    type        = number
    default     = 2     # prod-like default
}

variable "max_size" {
    description = "Maximum number of instances in the ASG"
    type        = number
    default     = 4     # prod-like default 
}

variable "desired_capacity" {
    description = "Desired number of instances in the ASG"
    type        = number
    default     = 2     # prod-like default
}

variable "instance_type" {
    description = "EC2 instance type for the ASG instances"
    type        = string
    default     = "t3.micro"   # default: t3.micro
}

variable "ami_id" {
    description = "AMI ID for the EC2 instances"
    type        = string        # baked or Packer/Image Builder
}

variable "iam_instance_profile" {
    description = "IAM instance profile to attach to the EC2 instances"
    type        = string        # pre-created IAM instance profile name
}

variable "user_data" {
    description = "User data script to configure the EC2 instances"
    type        = string        # e.g. cloud-init script
    default     = ""            # default: empty
}

variable "target_group_arns" {
    description = "List of target group ARNs to attach to the ASG"
    type        = list(string)  # e.g. ALB target group ARN
    default     = []            # default: empty list
}

variable "enable_detailed_monitoring" {
    description = "Whether to enable detailed monitoring for the ASG instances"
    type        = bool
    default     = false       # default: basic monitoring
}