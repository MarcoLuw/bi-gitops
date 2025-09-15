# ElastiCache Redis module variables
variable "name" {
    description = "The name of the ElastiCache Redis cluster"
    type        = string
}

variable "subnet_ids" {
    description = "List of subnet IDs for the ElastiCache subnet group"
    type        = list(string)    # e.g. private subnet IDs
}

variable "vpc_security_group_ids" {
    description = "List of VPC security group IDs to attach to the ElastiCache cluster"
    type        = list(string)
}

variable "node_type" {
    description = "The compute and memory capacity of the nodes in the node group"
    type        = string
    default     = "cache.t3.micro"   # default: cache.t3.micro
}

variable "automatic_failover" {
    description = "Whether to enable automatic failover for the Redis cluster"
    type        = bool
    default     = true      # prod-like default
}

variable "num_cache_clusters" {
    description = "Number of cache clusters (nodes) when cluster mode is disabled"
    type        = number
    default     = 2     # default: 2 nodes  - primary + replica
}

variable "num_node_groups" {
  description = "Number of node groups (shards) when cluster mode is enabled"
  type        = number
  default     = 2
}

variable "replicas_per_shard" {
    description = "The number of read replicas to create per shard"
    type        = number
    default     = 1     # default: 1 replica per shard
}

variable "multi_az" {
    description = "Whether to create a Multi-AZ Redis cluster"
    type        = bool
    default     = true      # prod-like default
}

variable "cluster_mode" {
    description = "Whether to enable cluster mode (sharding)"
    type        = bool
    default     = false     # default: disabled (single shard)
}