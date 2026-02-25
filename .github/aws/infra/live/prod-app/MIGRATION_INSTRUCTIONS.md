# 🚀 Prod Environment Terraform State Migration (Cross-Environment Consistency)

When `prod-network` and `prod-app` are next run, the Terraform state MUST be migrated to align with the STAGE and DEV environment refactors (parity drift fixed during `Engine 7` check).

## Overview of Changes

1. The `ec2_capacity_provider` module and `aws_ecs_cluster_capacity_providers` resource were MOVED from `prod-app` to `prod-network` for consistency with `dev-network` and `stage-network`.
2. The `environment_app` module was renamed to `app` inside `prod-app/main.tf` to match `stage-app`.

## Migration Commands

Before running `terraform apply` on Production, the state must be moved manually to prevent destructive recreation.

### 1. Move App Module State (Inside `prod-app`)

Run this from `.github/aws/infra/live/prod-app`:

```bash
terraform init
# Rename the module in state
terraform state mv 'module.environment_app' 'module.app'
```

### 2. Move Capacity Provider State to Network Stack

You must move the EC2 capacity provider state OUT of the `prod-app` statefile and INTO the `prod-network` statefile.

Run this from `.github/aws/infra/live/prod-app`:

```bash
terraform init

# Pull prod-app state
terraform state pull > prod-app.tfstate

# Move the resources out of prod-app into a temporary statefile
terraform state mv -state=prod-app.tfstate -state-out=moved.tfstate 'module.ec2_capacity_provider' 'module.ec2_capacity_provider'
terraform state mv -state=prod-app.tfstate -state-out=moved.tfstate 'aws_ecs_cluster_capacity_providers.prod' 'aws_ecs_cluster_capacity_providers.prod'

# Push the updated prod-app state back
terraform state push prod-app.tfstate
```

Then, run this from `.github/aws/infra/live/prod-network`:

```bash
terraform init

# Pull prod-network state
terraform state pull > prod-network.tfstate

# Move the resources from the temporary statefile into prod-network
terraform state mv -state=../prod-app/moved.tfstate -state-out=prod-network.tfstate 'module.ec2_capacity_provider' 'module.ec2_capacity_provider'
terraform state mv -state=../prod-app/moved.tfstate -state-out=prod-network.tfstate 'aws_ecs_cluster_capacity_providers.prod' 'aws_ecs_cluster_capacity_providers.prod'

# Push the updated prod-network state back
terraform state push prod-network.tfstate
```

After these steps, `terraform plan` in both `prod-network` and `prod-app` should show **0 to add, 0 to change, 0 to destroy**.
