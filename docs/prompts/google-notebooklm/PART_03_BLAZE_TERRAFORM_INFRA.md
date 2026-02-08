# PART 3: blaze-terraform-infra-core - Infrastructure Modules

**Document Purpose:** Infrastructure module library for Google NotebookLM  
**Target Length:** 2-3 minutes of presentation content  
**Focus:** Reusable Terraform modules and infrastructure patterns

---

## blaze-terraform-infra-core: The Module Library

### Repository Purpose

**What:** Production-ready Terraform modules for AWS infrastructure

**Why:**

- Avoid reinventing infrastructure code
- Enforce best practices
- Ensure consistency across projects
- Reduce deployment time from weeks to hours

**Location:** `github.com/thisisblaze/blaze-terraform-infra-core`

---

## Module Categories

### 1. Network & Foundation

- **vpc** - Virtual Private Cloud with public/private subnets
- **security-group** - Firewall rules for resources
- **route53-zone** - DNS zone management

### 2. Compute & Containers

- **ecs-cluster** - Container orchestration cluster (Fargate + EC2 hybrid)
- **ec2-capacity-provider** - EC2 capacity provider (ASG, Launch Template, IAM)
- **ecs-service** - Individual service definitions (per-service launch type)
- **ecs-task-definition** - Container task configurations

### 3. Load Balancing & CDN

- **alb** - Application Load Balancer
- **alb-target-group** - Backend service groups
- **cloudfront** - Global CDN distribution

### 4. Storage

- **s3-bucket** - Object storage with security defaults
- **efs** - Elastic File System for shared storage

### 5. Security & Access

- **iam-role** - Identity and access management
- **acm-certificate** - SSL/TLS certificates
- **kms-key** - Encryption key management

### 6. Monitoring & Logs

- **cloudwatch-log-group** - Centralized logging
- **cloudwatch-alarm** - Alerting and monitoring

---

## Key Module: environment-network

**Purpose:** Complete network stack for an environment

**Creates:**

```
VPC
├── Public Subnets (2-3 AZs)
│   └── NAT Gateways
├── Private Subnets (2-3 AZs)
│   └── Application resources
├── Security Groups
│   ├── ALB (ports 80, 443)
│   ├── ECS (port 3000)
│   └── Database (port 27017)
├── Application Load Balancer
│   ├── HTTP → HTTPS redirect
│   └── HTTPS listeners
└── EC2 Capacity Provider (optional)
    ├── Auto Scaling Group (Graviton ARM64)
    ├── Launch Template (ECS-optimized AMI)
    └── IAM Role + Security Group
```

**Usage:**

```hcl
module "network" {
  source = "git::https://github.com/thisisblaze/blaze-terraform-infra-core.git//modules/environment-network?ref=v2.0.0"

  namespace    = var.namespace  # e.g., "blaze"
  client_key   = "b9"
  project_key  = "thisisblaze"
  stage_key    = "dev"

  vpc_cidr     = "10.0.0.0/16"
  azs          = ["eu-west-1a", "eu-west-1b"]
}
```

---

## Key Module: environment-app

**Purpose:** Complete application infrastructure

**Creates:**

- ECS Cluster (Hybrid: Fargate + EC2 capacity providers)
- ECS Services (API, Frontend — per-service launch type)
- Task Definitions (Fargate or EC2, ARM64 or x86)
- CloudFront Distribution
- Lambda@Edge for image resizing
- S3 buckets for storage

**Features:**

- Auto-scaling based on CPU/memory
- Blue/green deployments
- Circuit breakers
- Health checks

---

## Module Design Patterns

### 1. Namespace Support

All resources include dynamic namespace prefix:

```hcl
resource "aws_ecs_cluster" "main" {
  name = "${var.namespace}-${var.client_key}-${var.project_key}-${var.stage_key}-cluster"
}
```

### 2. Sensible Defaults

Modules work out-of-the-box with minimal configuration:

```hcl
module "vpc" {
  source = "..."

  # Required
  namespace = "blaze"

  # Optional (has defaults)
  vpc_cidr = "10.0.0.0/16"  # default
  enable_nat = true          # default
}
```

### 3. Security Best Practices

- Encryption at rest enabled by default
- Least privilege IAM policies
- Private subnets for compute
- Security groups with minimal ports

### 4. Cost Optimization

- Spot instances for dev environments
- AutoScaling to handle load
- Lifecycle policies for S3
- CloudWatch log retention limits

---

## Version Management

**Strategy:** Semantic versioning with Git tags

**Example:**

```hcl
# Stable (recommended for production)
source = "git::https://github.com/thisisblaze/blaze-terraform-infra-core.git//modules/vpc?ref=v2.0.0"

# Latest on branch
source = "git::https://github.com/thisisblaze/blaze-terraform-infra-core.git//modules/vpc?ref=dev"
```

**Benefits:**

- Pin to stable versions in production
- Test new features in dev
- Clear upgrade path

---

## Real-World Example

**Scenario:** Stand up complete DEV environment

**Terraform Stack:**

```hcl
# 1. Network Stack
module "network" {
  source = ".../environment-network?ref=v2.0.0"
  # Creates VPC, subnets, ALB, security groups
}

# 2. Application Stack
module "app" {
  source = ".../environment-app?ref=v2.0.0"

  # Use network outputs
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids
  alb_arn    = module.network.alb_arn

  # Application config
  api_image    = "123456789.dkr.ecr.eu-west-1.amazonaws.com/blaze-api:latest"
  api_cpu      = 256
  api_memory   = 512
}
```

**Result:**

- Complete infrastructure in 15 minutes
- Secure by default
- Production-ready
- Cost-optimized

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-08  
**Estimated Presentation Time:** 2-3 minutes
