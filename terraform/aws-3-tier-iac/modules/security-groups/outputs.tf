# Security groups module outputs
output "alb_web_sg_id" {
    description = "Security Group ID for the public web ALB"
    value = aws_security_group.alb_web_sg.id
}

output "alb_app_sg_id" {
    description = "Security Group ID for the internal app ALB"
    value = aws_security_group.alb_app_sg.id
}

output "web_ec2_sg_id" {
    description = "Security Group ID for web tier EC2 instances"
    value = aws_security_group.web_sg.id
}

output "app_ec2_sg_id" {
    description = "Security Group ID for app tier EC2 instances"
    value = aws_security_group.app_sg.id
}

output "reids_sg_id" {
    description = "Security Group ID for Redis/ElastiCache"
    value = aws_security_group.redis_sg.id
}

output "db_sg_id" {
    description = "Security Group ID for RDS Postgres"
    value = aws_security_group.db_sg.id
}

## Consolidated map output
# Provides all security group IDs in a single map for flexible access patterns
# Usage: module.sg.sg_ids["alb_web"] or lookup(module.sg.sg_ids, "alb_web", "")
output "sg_ids" {
    description = "Map of all SG IDs by logical name"
    value = {
        alb_web = aws_security_group.alb_web_sg.id
        alb_app = aws_security_group.alb_app_sg.id
        web_tier = aws_security_group.web_sg.id
        app_tier = aws_security_group.app_sg.id
        redis   = aws_security_group.redis_sg.id
        db      = aws_security_group.db_sg.id
    }
}

output "sg_arns" {
    description = "Map of all SG ARNs by logical name"
    value = {
        alb_web = aws_security_group.alb_web_sg.arn
        alb_app = aws_security_group.alb_app_sg.arn
        web_tier = aws_security_group.web_sg.arn
        app_tier = aws_security_group.app_sg.arn
        redis   = aws_security_group.redis_sg.arn
        db      = aws_security_group.db_sg.arn
    }
}