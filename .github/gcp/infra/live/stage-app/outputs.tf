# ── API Service ──

output "api_url" {
  description = "Cloud Run URL for the API service"
  value       = module.environment_app.api_url
}

output "api_service_name" {
  description = "Cloud Run service name for API"
  value       = module.environment_app.api_service_name
}

# ── Frontend Service ──

output "frontend_url" {
  description = "Cloud Run URL for the Frontend service"
  value       = module.environment_app.frontend_url
}

output "frontend_service_name" {
  description = "Cloud Run service name for Frontend"
  value       = module.environment_app.frontend_service_name
}

# ── Storage ──

output "storage_bucket_name" {
  description = "GCS storage bucket name"
  value       = module.environment_app.storage_bucket_name
}

output "storage_bucket_url" {
  description = "GCS storage bucket URL"
  value       = module.environment_app.storage_bucket_url
}

# ── Service Account ──

output "app_service_account_email" {
  description = "Application service account email"
  value       = module.environment_app.app_service_account_email
}

# ── VPC Connector ──

output "vpc_connector_id" {
  description = "VPC Access Connector ID (if created)"
  value       = module.environment_app.vpc_connector_id
}
