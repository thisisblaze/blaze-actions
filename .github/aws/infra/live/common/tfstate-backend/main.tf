module "tfstate_backend" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/storage/tfstate-backend?ref=v2.1.2"

  namespace = var.namespace
  stage     = var.environment
  name      = "tfstate"
}

output "s3_bucket_id" {
  value = module.tfstate_backend.s3_bucket_id
}

output "dynamodb_table_name" {
  value = module.tfstate_backend.dynamodb_table_name
}
