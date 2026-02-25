# Stage Data Layer Stack

This stack manages data services for the stage environment.

## Resources

- **ElastiCache Redis**: Disabled by default (`enable_redis = false`)
  - Enable when needed for testing by setting `enable_redis = true`
  - Same configuration as PROD when enabled (cache.t4g.micro)

## Cost

- **Monthly**: $0 (Redis disabled by default)
- **If Enabled**: ~$12/month

## Deployment Order

1. **dev-network** (prerequisite)
2. **dev-data** (this stack) ← Placeholder, no resources by default
3. **dev-app** (consumes outputs from this stack)

## Usage

### Initialize
```bash
cd .github/aws/infra/live/stage-data
terraform init \
  -backend-config="bucket=b9-stage-blaze-tfstate" \
  -backend-config="key=infra/thisisblaze/stage/data.tfstate" \
  -backend-config="region=eu-west-1"
```

### Deploy (No Resources by Default)
```bash
terraform plan  # Should show: Plan: 0 to add, 0 to change, 0 to destroy
terraform apply
```

### Enable Redis (When Needed)
Update `variables.tf`:
```hcl
variable "enable_redis" {
  default = true  # ← Change from false
}
```

Then apply:
```bash
terraform apply
# Will create 4 resources (Redis cluster, parameter group, subnet group, security group)
```

## Outputs

Even with Redis disabled, outputs are available (return null):
- `redis_endpoint`: null when disabled
- `redis_port`: null when disabled  
- `config.redis_enabled`: false

## Benefits

✅ **Consistent Architecture**: Same 3-layer pattern as STAGE/PROD  
✅ **Zero Cost**: No charges when disabled  
✅ **Easy to Enable**: Flip one variable to add Redis for testing  
✅ **Clean Integration**: App stack doesn't break when Redis is disabled
