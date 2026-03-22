module "github_oidc" {
  source = "github.com/thisisblaze/blaze-terraform-infra-core//modules/aws/security/github-oidc?ref=v2.2.0"

  github_org  = "thebyte9"
  github_repo = "blaze-template-deploy"
}

output "oidc_provider_arn" {
  value = module.github_oidc.oidc_provider_arn
}

output "role_arn" {
  value = module.github_oidc.role_arn
}
