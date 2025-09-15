# ALB module variables
variable "name" {
    description = "The name of the ALB"
    type        = string
}

variable "vpc_id" {
    description = "The ID of the VPC"
    type        = string
}

variable "internal" {
    description = "Whether the ALB is internal or internet-facing"
    type        = bool
    default     = false      # false = public, true = internal
}

variable "subnet_ids" {
    description = "List of subnet IDs for the ALB"
    type        = list(string)    # e.g. public subnet IDs
}

variable "security_group_ids" {
    description = "List of security group IDs to attach to the ALB"
    type        = list(string)
}

variable "listener_https" {
    description = "Whether to create an HTTPS listener on port 443"
    type        = bool
    default     = false      # default: no HTTPS listener
}

variable "certificate_arn" {
    description = "ARN of the ACM certificate for the HTTPS listener (required if listener_https is true)"
    type        = string
    default     = ""         # default: empty string
}

variable "target_group_port" {
    description = "The port on which the target group is listening"
    type        = number
    default     = 80
}

variable "target_type" {
    description = "The type of target that you must specify when registering targets with this target group. Valid values are instance, ip, and lambda."
    type        = string    # valid values are "instance", "ip", "lambda" (ASG target)
    default     = "instance"  # default: instance
}

variable "health_check" {
    description = "Health check configuration for the target group"
    type = object({
        path                = string   # e.g. "/"
        matcher             = string   # e.g. "200-399"
        interval           = number   # e.g. 30
        healthy_threshold   = number   # e.g. 2
        unhealthy_threshold = number   # e.g. 2
        timeout            = number   # e.g. 5
    })
    default = {
        path                = "/"
        matcher             = "200-399"
        interval           = 30
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout            = 5
    }
}