variable "zone_id" {
  description = "The ID of the hosted zone to contain this record."
  type        = string
}

variable "record_name" {
  description = "The DNS record name (e.g., app.example.com)"
  type        = string
}

variable "record_type" {
  description = "The type of DNS record (e.g., A, CNAME, etc.)"
  type        = string
  default     = "A"
}

variable "alias_name" {
  description = "The DNS name of the target (e.g., ALB DNS name)."
  type        = string
}

variable "alias_zone_id" {
  description = "The hosted zone ID of the target (e.g., ALB zone ID)."
  type        = string
}

variable "evaluate_target_health" {
  description = "Whether to evaluate the target health (default true)."
  type        = bool
  default     = true
}

variable "ttl" {
  description = "The TTL of the record (ignored if alias is set)."
  type        = number
  default     = 300
}

variable "records" {
  description = "Values for non-alias records"
  type        = list(string)
  default     = []
}