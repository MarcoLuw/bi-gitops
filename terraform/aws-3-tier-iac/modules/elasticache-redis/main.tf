# Redis replication group, subnet group, params

## Create a subnet group for ElastiCache
resource "aws_elasticache_subnet_group" "this" {
    name       = var.name
    subnet_ids = var.subnet_ids
    description = "Subnet group for ElastiCache Redis cluster ${var.name}"
}

## Parameter group for Redis
resource "aws_elasticache_parameter_group" "this" {
    name        = "${var.name}-param-group"
    family      = "redis6.x"
    description = "Parameter group for ElastiCache Redis cluster ${var.name}"
}

## Create the ElastiCache Redis replication group
resource "aws_elasticache_replication_group" "this" {
    replication_group_id          = "${var.name}-rg"
    description = "ElastiCache Redis replication group ${var.name}"
    engine                        = "redis"
    engine_version                = "6.x"
    node_type                     = var.node_type
    
    subnet_group_name             = aws_elasticache_subnet_group.this.name
    security_group_ids            = var.vpc_security_group_ids
    parameter_group_name          = aws_elasticache_parameter_group.this.name

    # Availability & durability
    automatic_failover_enabled    = var.automatic_failover
    
    # Based on cluster mode
    num_cache_clusters            = var.cluster_mode ? null : var.num_cache_clusters
    num_node_groups               = var.cluster_mode ? var.num_node_groups : null
    replicas_per_node_group       = var.cluster_mode ? var.replicas_per_shard : null
    multi_az_enabled              = var.multi_az
    
    port                          = 6379

    apply_immediately             = true
    transit_encryption_enabled    = true
    at_rest_encryption_enabled    = true
    
    tags = {
        Name = var.name
    }

    lifecycle {
        create_before_destroy = true
    }
}