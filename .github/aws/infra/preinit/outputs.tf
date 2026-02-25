output "bucket_id" {
  value = module.tfstate_backend.s3_bucket_id
}

output "dynamodb_table_name" {
  value = module.tfstate_backend.dynamodb_table_name
}