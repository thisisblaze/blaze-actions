# Network Infrastructure Outputs (GCP)
# Proxied from environment_network module

output "vpc_id" {
  description = "VPC Network ID"
  value       = module.environment_network.vpc_id
}

output "vpc_name" {
  description = "VPC Network name"
  value       = module.environment_network.vpc_name
}

output "vpc_self_link" {
  description = "VPC Network self link"
  value       = module.environment_network.vpc_self_link
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = module.environment_network.private_subnet_id
}

output "private_subnet_name" {
  description = "Private subnet name"
  value       = module.environment_network.private_subnet_name
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.environment_network.public_subnet_id
}

output "public_subnet_name" {
  description = "Public subnet name"
  value       = module.environment_network.public_subnet_name
}

output "nat_name" {
  description = "Cloud NAT name"
  value       = module.environment_network.nat_name
}

output "artifact_registry_url" {
  description = "Artifact Registry URL for Docker images"
  value       = module.environment_network.artifact_registry_url
}

output "artifact_registry_id" {
  description = "Artifact Registry repository ID (for IAM bindings)"
  value       = module.environment_network.artifact_registry_id
}
