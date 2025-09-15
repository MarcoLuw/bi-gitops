# Output Route 53 Hosted Zone Module

output "zone_id" {
  description = "The ID of the hosted zone"
  value       = aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "The name of the hosted zone"
  value       = aws_route53_zone.this.name
}

output "alias_record_name" {
  description = "The name of the alias record"
  value       = length(aws_route53_record.alias) > 0 ? aws_route53_record.alias[0].name : null
}