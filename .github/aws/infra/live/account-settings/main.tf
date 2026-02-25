# ─────────────────────────────────────────────────────────────
# ACCOUNT-LEVEL SETTINGS
# ─────────────────────────────────────────────────────────────
# These settings apply to the entire AWS account (regional).
# They are NOT per-environment — deploy once per region.
#
# ENI Trunking: Enables 20+ ECS tasks per EC2 instance by
# allowing multiple ENIs via trunk network interfaces.
# Without this, instances are limited to ~2-3 tasks.
# ─────────────────────────────────────────────────────────────

terraform {
  backend "s3" {}
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

# ─── ENI Trunking (Required for high-density EC2) ───────────

resource "aws_ecs_account_setting_default" "awsvpc_trunking" {
  name  = "awsvpcTrunking"
  value = "enabled"
}

# ─── Container Insights (Account Default) ───────────────────

resource "aws_ecs_account_setting_default" "container_insights" {
  name  = "containerInsights"
  value = var.container_insights
}
