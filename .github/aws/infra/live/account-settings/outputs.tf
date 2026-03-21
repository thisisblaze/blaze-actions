output "awsvpc_trunking_status" {
  description = "ENI Trunking status (should be 'enabled')"
  value       = aws_ecs_account_setting_default.awsvpc_trunking.value
}

output "container_insights_status" {
  description = "Container Insights default setting"
  value       = aws_ecs_account_setting_default.container_insights.value
}
