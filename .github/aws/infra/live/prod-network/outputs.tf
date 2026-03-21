output "vpc_id" {
  description = "VPC ID for use in dependent stacks"
  value       = module.environment_network.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs for load balancers and NAT gateways"
  value       = module.environment_network.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs for ECS services"
  value       = module.environment_network.private_subnets
}

output "cluster_id" {
  description = "ECS cluster ID for service deployments"
  value       = module.environment_network.cluster_id
}

output "cluster_name" {
  description = "ECS cluster name for service deployments"
  value       = module.environment_network.cluster_name
}

output "service_discovery_ns_id" {
  description = "Service discovery namespace ID for internal DNS"
  value       = module.environment_network.service_discovery_ns_id
}

output "execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = module.environment_network.execution_role_arn
}

output "ecs_sg_id" {
  description = "ECS service security group ID"
  value       = module.environment_network.ecs_sg_id
}

output "alb_listener_arn" {
  description = "Application Load Balancer HTTPS listener ARN"
  value       = module.environment_network.alb_listener_arn
}

output "alb_tg_blue_arn" {
  description = "ALB target group blue ARN for API service"
  value       = module.environment_network.alb_tg_blue_arn
}

output "alb_tg_blue_name" {
  description = "ALB target group blue name for API service"
  value       = module.environment_network.alb_tg_blue_name
}

output "alb_tg_green_arn" {
  description = "ALB target group green ARN for API service"
  value       = module.environment_network.alb_tg_green_arn
}

output "alb_tg_green_name" {
  description = "ALB target group green name for API service"
  value       = module.environment_network.alb_tg_green_name
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.environment_network.alb_dns_name
}

output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = module.environment_network.alb_arn
}

output "cdn_arn" {
  description = "CloudFront Distribution ARN"
  value       = module.environment_network.config.cloudfront_distribution_arn
}

output "alb_tg_frontend_blue_arn" {
  description = "ALB target group blue ARN for Frontend service"
  value       = module.environment_network.alb_tg_frontend_blue_arn
}

output "alb_tg_frontend_blue_name" {
  description = "ALB target group blue name for Frontend service"
  value       = module.environment_network.alb_tg_frontend_blue_name
}

output "alb_tg_frontend_green_name" {
  description = "ALB target group green name for Frontend service"
  value       = module.environment_network.alb_tg_frontend_green_name
}

output "efs_id" {
  description = "EFS file system ID for mounting in containers"
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

output "codedeploy_role_arn" {
  description = "CodeDeploy role ARN for blue/green deployments"
  value       = module.environment_network.codedeploy_role_arn
}

output "alb_tg_admin_blue_arn" {
  description = "ALB target group blue ARN for Admin service"
  value       = module.environment_network.alb_tg_admin_blue_arn
}

output "alb_tg_admin_blue_name" {
  description = "ALB target group blue name for Admin service"
  value       = module.environment_network.alb_tg_admin_blue_name
}

output "alb_tg_admin_green_name" {
  description = "ALB target group green name for Admin service"
  value       = module.environment_network.alb_tg_admin_green_name
}
