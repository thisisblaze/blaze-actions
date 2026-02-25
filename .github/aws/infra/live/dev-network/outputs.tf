# Network Infrastructure Outputs
# These outputs are used by the app layer and feature branches

output "vpc_id" {
  description = "VPC ID"
  value       = module.environment_network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = var.vpc_cidr
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.environment_network.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.environment_network.private_subnets
}

output "app_subnets" {
  description = "Subnets where applications should run. Private (if NAT) or Public (if No NAT)."
  value       = module.environment_network.app_subnets
}

output "public_ip_enabled" {
  description = "True if applications are running in Public Subnets and need Public IPs to reach internet."
  value       = module.environment_network.public_ip_enabled
}

output "cluster_id" {
  description = "ECS cluster ID"
  value       = module.environment_network.cluster_id
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = module.environment_network.cluster_name
}

output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.environment_network.cluster_arn
}

output "service_discovery_ns_id" {
  description = "Service discovery namespace ID"
  value       = module.environment_network.service_discovery_ns_id
}

output "execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = module.environment_network.execution_role_arn
}

output "codedeploy_role_arn" {
  description = "CodeDeploy role ARN"
  value       = module.environment_network.codedeploy_role_arn
}

output "ecs_sg_id" {
  description = "ECS service security group ID"
  value       = module.environment_network.ecs_sg_id
}

output "efs_id" {
  description = "EFS file system ID"
  value       = module.environment_network.efs_id
}

output "api_ap_id" {
  description = "API EFS access point ID"
  value       = module.environment_network.api_ap_id
}

output "mongo_ap_id" {
  description = "MongoDB EFS access point ID"
  value       = module.environment_network.mongo_ap_id
}

output "es_ap_id" {
  description = "Elasticsearch EFS access point ID"
  value       = module.environment_network.es_ap_id
}

# Optional ALB Outputs (Proxied from Module, which handles conditionality)
output "alb_listener_arn" {
  description = "The ARN of the HTTPS listener (if ALB enabled)"
  value       = module.environment_network.alb_listener_arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB (if ALB enabled)"
  value       = module.environment_network.alb_dns_name
}

# Unified Config Output (Legacy compat)
output "config" {
  value = module.environment_network.config
}

# EC2 Capacity Provider (Hybrid ECS — Feb 2026)
output "ec2_capacity_provider_name" {
  description = "Name of the EC2 capacity provider (empty if EC2 not enabled)"
  value       = var.enable_ec2 ? module.ec2_capacity_provider[0].capacity_provider_name : ""
}
