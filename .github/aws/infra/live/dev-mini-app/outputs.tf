output "vpc_id" {
  value = try(data.terraform_remote_state.network.outputs.vpc_id, "")
}

output "ecs_sg_id" {
  value = try(data.terraform_remote_state.network.outputs.ecs_sg_id, "")
}

output "cluster_id" {
  value = try(data.terraform_remote_state.network.outputs.cluster_id, "")
}

output "cluster_name" {
  value = try(data.terraform_remote_state.network.outputs.cluster_name, "")
}

output "service_discovery_ns_id" {
  value = try(data.terraform_remote_state.network.outputs.service_discovery_ns_id, "")
}

output "execution_role_arn" {
  value = try(data.terraform_remote_state.network.outputs.execution_role_arn, "")
}

output "alb_listener_arn" {
  value = try(data.terraform_remote_state.network.outputs.alb_listener_arn, "")
}

output "efs_id" {
  value = try(data.terraform_remote_state.network.outputs.efs_id, "")
}

output "mongo_ap_id" {
  value = try(data.terraform_remote_state.network.outputs.mongo_ap_id, "")
}

output "es_ap_id" {
  value = try(data.terraform_remote_state.network.outputs.es_ap_id, "")
}

output "api_ap_id" {
  value = try(data.terraform_remote_state.network.outputs.api_ap_id, "")
}

output "tunnel_token" {
  description = "Cloudflare tunnel token for feature branch (if applicable)"
  value       = local.tunnel_token
  sensitive   = true
}
