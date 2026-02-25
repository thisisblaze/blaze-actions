terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }

module "tfstate_backend" {
  source    = "git::https://github.com/thisisblaze/blaze-terraform-infra-core.git//modules/aws/storage/tfstate-backend?ref=dev"
  namespace = var.client_key
  stage     = var.stage
  name      = "blaze"

  force_destroy                 = true
  enable_server_side_encryption = true
}

