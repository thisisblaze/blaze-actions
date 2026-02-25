# Production Data Layer Stack

This stack manages data services for the production environment:

## Resources

- **ElastiCache Redis**: Single `cache.t4g.micro` instance for caching
  - No password (transit encryption disabled)
  - At-rest encryption enabled
  - Private subnets only
  - Secured via Security Group (ECS tasks only)

## Cost

- **Monthly**: ~$12 (ElastiCache cache.t4g.micro)

## Deployment Order

1. **prod-network** (prerequisite)
2. **prod-data** (this stack) ← Deploy Redis
3. **prod-app** (consumes outputs from this stack)

## Usage

### Initialize
```bash
cd .github/aws/infra/live/prod-data
terraform init \
  -backend-config="bucket=b9-prod-blaze-tfstate" \
  -backend-config="key=infra/thisisblaze/prod/data.tfstate" \
  -backend-config="region=eu-west-1"
```

### Deploy
```bash
terraform plan
terraform apply
```

### Outputs
After deployment, this stack provides:
- `redis_endpoint`: Connection endpoint for Redis
- `redis_port`: Port number (6379)
- `config`: Unified config object for app stack

## Integration with prod-app

Update `prod-app/main.tf` to consume Redis endpoint:

```hcl
data "terraform_remote_state" "data" {
  backend = "s3"
  config = {
    bucket = "${var.client_key}-${var.stage}-${var.namespace}-tfstate"
    key    = "infra/${var.project_key}/prod/data.tfstate"
    region = var.aws_region
  }
}

module "environment_app" {
  # ... existing config
  
  api_environment_variables = merge(
    var.api_environment_variables,
    {
      REDIS_HOST = data.terraform_remote_state.data.outputs.redis_endpoint
      REDIS_PORT = tostring(data.terraform_remote_state.data.outputs.redis_port)
    }
  )
}
```

## Future Services

This stack can be extended to include:
- RDS databases
- DocumentDB
- Additional ElastiCache clusters
- OpenSearch

## Replication for DEV/STAGE

To create similar stacks for other environments:
```bash
# Copy to dev-data/
cp -r prod-data dev-data
# Update variables.tf with stage = "dev"

# Copy to stage-data/
cp -r prod-data stage-data  
# Update variables.tf with stage = "stage"
```
