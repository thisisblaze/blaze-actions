provider "aws" {
  region = var.aws_region
}

module "tfstate_backend" {
  source    = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/storage/tfstate-backend?ref=v1.44.1"
  namespace = var.client_key
  stage     = var.stage
  name      = var.project_key
}

output "tf_state_bucket" {
  value = module.tfstate_backend.s3_bucket_id
}

output "tf_dynamodb_table" {
  value = module.tfstate_backend.dynamodb_table_name
}
