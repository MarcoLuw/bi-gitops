# WAF module variables
variable "name" {
    description = "The name of the WAF"
    type        = string
}

variable "scope" {
    description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application"
    type        = string
    default     = "REGIONAL"   # for ALB
}

variable "managed_rule_sets" {
    description = "List of managed rule sets to include in the WebACL"
    type        = list(string)
    default     = [
        "AWSManagedRulesCommonRuleSet",
        "AWSManagedRulesAmazonIpReputationList",
        "AWSManagedRulesKnownBadInputsRuleSet",
        "AWSManagedRulesSQLiRuleSet",
        "AWSManagedRulesLinuxRuleSet",
        "AWSManagedRulesWindowsRuleSet"
    ]
}

variable "alb_arn" {
    description = "The ARN of the ALB to associate with the WAF WebACL"
    type        = string
}