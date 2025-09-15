# Route53 record module outputs
output "record_fqdn" {
    description = "The fully qualified domain name of the record"
    value       = aws_route53_record.this.fqdn
}

output "record_id" {
    description = "The ID of the Route53 record"
    value       = aws_route53_record.this.id
}

output "record_name" {
    description = "The name of the Route53 record"
    value       = aws_route53_record.this.name
}