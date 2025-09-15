# ElastiCache Redis module outputs
output "primary_endpoint_address" {
    description = "The primary endpoint address of the Redis cluster"
    value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
    description = "The reader endpoint address of the Redis cluster"
    value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "configuration_endpoint_address" {
    description = "The configuration endpoint address of the Redis cluster"
    value       = aws_elasticache_replication_group.this.configuration_endpoint_address
}

output "port" {
    description = "The port number on which the Redis cluster accepts connections"
    value       = aws_elasticache_replication_group.this.port
}

output "replication_group_id" {
    description = "The ID of the Redis replication group"
    value       = aws_elasticache_replication_group.this.id
}