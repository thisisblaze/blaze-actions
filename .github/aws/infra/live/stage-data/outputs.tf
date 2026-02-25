# Unified Config Output (for app stack consumption)
output "config" {
  description = "Unified configuration for data services"
  value = {
    redis_endpoint = var.enable_redis ? module.redis.primary_endpoint_address : null
    redis_port     = var.enable_redis ? module.redis.port : null
    redis_enabled  = var.enable_redis
  }
}

# Individual Outputs (Legacy compatibility)
output "redis_endpoint" {
  description = "Redis primary endpoint address"
  value       = var.enable_redis ? module.redis.primary_endpoint_address : null
}

output "redis_port" {
  description = "Redis port number"
  value       = var.enable_redis ? module.redis.port : null
}

output "redis_id" {
  description = "Redis replication group ID"
  value       = var.enable_redis ? module.redis.id : null
}

output "redis_arn" {
  description = "Redis replication group ARN"
  value       = var.enable_redis ? module.redis.arn : null
}
