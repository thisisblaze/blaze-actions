mock_provider "mongodbatlas" {}
mock_provider "aws" {}

run "naming_schema_matches_expected" {
  command = plan

  variables {
    client_key  = "kmdemo"
    project_key = "stuffdemo"
    stage       = "prod"
    aws_region  = "eu-west-1"
    platform    = "ecs"

    # Required by shared/common variables in live stacks (not used by this stack)
    cloudflare_api_token  = "dummy"
    cloudflare_account_id = "dummy"
    cloudflare_zone_id    = "dummy"
    domain_root           = "example.com"

    # Required provider config vars (mocked provider; values don't matter)
    atlas_public_key  = "dummy"
    atlas_private_key = "dummy"
    atlas_org_id      = "dummy"

    # Use an existing project id to avoid creating a project in tests.
    atlas_project_id = "000000000000000000000000"
  }

  assert {
    condition     = mongodbatlas_cluster.main.name == "blaze-kmdemo-ecs-prod"
    error_message = "Expected Atlas cluster name to be blaze-<client>-<platform>-<stage>"
  }

  assert {
    condition     = mongodbatlas_database_user.app.username == "blaze-kmdemo-stuffdemo-prod"
    error_message = "Expected Atlas username to be blaze-<client>-<project>-<stage>"
  }

  assert {
    condition     = output.db_name == "blaze-kmdemo-stuffdemo-prod"
    error_message = "Expected default database name to be blaze-<client>-<project>-<stage>"
  }

  # Verify admin username follows pattern: {db_name}-admin
  assert {
    condition     = output.admin_username == "blaze-kmdemo-stuffdemo-prod-admin"
    error_message = "Expected admin username to be blaze-<client>-<project>-<stage>-admin"
  }
}
