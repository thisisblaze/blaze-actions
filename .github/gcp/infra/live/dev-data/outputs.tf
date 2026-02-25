# ── Memorystore Redis ──

output "redis_host" {
  description = "Redis instance private IP"
  value       = var.enable_redis ? module.redis[0].redis_host : ""
}

output "redis_port" {
  description = "Redis instance port"
  value       = var.enable_redis ? module.redis[0].redis_port : 6379
}

output "redis_connection_string" {
  description = "Redis connection string (host:port)"
  value       = var.enable_redis ? module.redis[0].redis_connection_string : ""
}

# ── Cloud SQL ──

output "cloud_sql_connection_name" {
  description = "Cloud SQL connection name (for Cloud Run Cloud SQL Proxy)"
  value       = var.enable_cloud_sql ? module.cloud_sql[0].connection_name : ""
}

output "cloud_sql_private_ip" {
  description = "Cloud SQL private IP address"
  value       = var.enable_cloud_sql ? module.cloud_sql[0].private_ip : ""
}

output "cloud_sql_database_name" {
  description = "Default database name"
  value       = var.enable_cloud_sql ? module.cloud_sql[0].database_name : ""
}
