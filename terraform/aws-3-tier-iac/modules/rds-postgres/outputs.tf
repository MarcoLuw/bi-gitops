# RDS PostgreSQL module outputs

output "db_instance_id" {
    description = "The ID of the RDS PostgreSQL instance"
    value       = aws_db_instance.this.id
}

output "db_endpoint" {
    description = "The connection endpoint for the RDS PostgreSQL instance"
    value       = aws_db_instance.this.endpoint
}

output "db_port" {
    description = "The port on which the RDS PostgreSQL instance is listening"
    value       = aws_db_instance.this.port
}

output "db_name" {
    description = "The name of the RDS PostgreSQL instance"
    value       = aws_db_instance.this.identifier
}