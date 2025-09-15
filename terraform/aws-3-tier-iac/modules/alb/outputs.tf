# ALB module outputs
output "alb_arn" {
    description = "The ARN of the ALB"
    value       = aws_lb.this.arn
}

output "alb_dns_name" {
    description = "The DNS name of the ALB"
    value       = aws_lb.this.dns_name
}

output "alb_security_group_ids" {
    description = "The security group IDs attached to the ALB"
    value       = aws_lb.this.security_groups
}

output "alb_target_group_arn" {
    description = "The ARN of the ALB target group"
    value       = aws_lb_target_group.this.arn
}

output "alb_target_group_name" {
    description = "The name of the ALB target group"
    value       = aws_lb_target_group.this.name
}

output "alb_zone_id" {
    description = "The canonical hosted zone ID of the ALB"
    value       = aws_lb.this.zone_id
}