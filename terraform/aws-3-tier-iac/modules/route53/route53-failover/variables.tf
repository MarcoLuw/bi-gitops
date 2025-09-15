# Route53 failover module variables
variable "zone_id" {
    description = "The ID of the Route53 hosted zone"
    type        = string
}

variable "record_name" {
    description = "The DNS record name for the failover record"
    type        = string    # e.g. "app.example.com"
}

variable "primary_alb_dns" {
    description = "The DNS name of the primary ALB"
    type        = string
}

variable "secondary_alb_dns" {
    description = "The DNS name of the secondary ALB"
    type        = string
}

variable "primary_evaluate_target_health" {
    description = "Whether to evaluate target health for the primary record"
    type        = bool
    default     = true      # prod-like default
}

variable "secondary_evaluate_target_health" {
    description = "Whether to evaluate target health for the secondary record"
    type        = bool
    default     = true      # prod-like default
}