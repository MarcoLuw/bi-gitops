# Variables for Route 53 Hosted Zone
variable "zone_name" {
  description = "The domain name for the hosted zone (e.g., example.com)."
  type        = string
}

variable "vpc_ids" {
  description = "A list of VPC IDs to associate with the hosted zone (for private hosted zones)."
  type        = list(string)
  default     = []
}

variable "comment" {
  description = "An optional comment for the hosted zone."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the hosted zone."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Whether to destroy all records in the hosted zone when deleting the zone."
  type        = bool
  default     = false
}

# variable "create_alias_record" {
#   description = "Whether to create an alias record for the hosted zone."
#   type        = bool
#   default     = false
# }

variable "record_name" {
  description = "The name of the alias record to create (e.g., www.example.com)."
  type        = string
  default     = null
}

variable "alias_target_dns" {
  description = "The DNS name of the alias target (e.g., ALB DNS name)."
  type        = string
  default     = null
}

variable "alias_target_zone_id" {
  description = "The hosted zone ID of the alias target."
  type        = string
  default     = null
}

variable "create_alias_record" {
  description = "Whether to create an alias record for the hosted zone."
  type        = bool
  default     = false
  validation {
    condition = !(var.create_alias_record && (var.record_name == null || var.alias_target_dns == null || var.alias_target_zone_id == null))
    error_message = "If create_alias_record is true, then record_name, alias_target_dns, and alias_target_zone_id must all be provided."
  }
}