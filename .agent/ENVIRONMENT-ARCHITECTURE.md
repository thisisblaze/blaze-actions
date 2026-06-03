# Environment Architecture Reference

Quick reference for environment-specific features and multi-cloud architecture (AWS, GCP, Azure).

## CDN Strategy by Environment

| Environment | CDN                     | CloudFront | Image Resize                       | Use Case                                |
| ----------- | ----------------------- | ---------- | ---------------------------------- | --------------------------------------- |
| **DEV**     | Cloudflare              | ❌ No      | ❌ No                              | Development, testing, Cloudflare Tunnel |
| **STAGE**   | Cloudflare + CloudFront | ✅ Yes     | ⏸️ Available (disabled by default) | Pre-production, integration testing     |
| **PROD**    | Cloudflare + CloudFront | ✅ Yes     | ⏸️ Available (disabled by default) | Production workloads                    |

---

## Architecture Differences

### DEV Environment

```
Internet
   ↓
Cloudflare (Proxy + Cache)
   ↓
AWS ALB
   ↓
ECS Tasks
```

**Features:**

- ✅ Cloudflare Tunnel for local development
- ✅ Cloudflare WAF & DDoS protection
- ✅ Cloudflare caching & optimization
- ❌ No AWS CloudFront
- ❌ No Lambda@Edge
- ❌ No AWS-based image resize

**DNS Records:**

- `api-dev.thisisblaze.uk` → Cloudflare → ALB
- `frontend-dev.thisisblaze.uk` → Cloudflare → ALB
- `admin-dev.thisisblaze.uk` → Cloudflare Pages

---

### STAGE/PROD Environments

```
Internet
   ↓
Cloudflare (DNS + WAF)
   ↓
AWS CloudFront (CDN + Cache)
   ↓
Lambda@Edge (Optional: Image Resize)
   ↓
AWS ALB / S3
   ↓
ECS Tasks / Static Assets
```

**Features:**

- ✅ Cloudflare WAF & DDoS protection (DNS level)
- ✅ AWS CloudFront global CDN
- ✅ Lambda@Edge for request/response manipulation
- ✅ AWS-based image resize (when enabled)
- ✅ Direct ALB access via `api-direct-stage`

**DNS Records:**

- `api-stage.thisisblaze.uk` → Cloudflare → CloudFront → ALB
- `frontend-stage.thisisblaze.uk` → Cloudflare → CloudFront → ALB
- `admin-stage.thisisblaze.uk` → Cloudflare Pages
- `api-direct-stage.thisisblaze.uk` → Cloudflare → ALB (bypass CloudFront)

---

## Why Different Architectures?

### DEV: Cloudflare Only

**Reasons:**

1. **Cost Optimization** - No CloudFront charges for development
2. **Simplicity** - Fewer moving parts, faster iteration
3. **Tunnel Support** - Cloudflare Tunnel for local development
4. **Sufficient Performance** - Cloudflare cache adequate for dev workloads

**Limitations:**

- No Lambda@Edge testing
- No CloudFront-specific features
- Different cache behavior than production

---

### STAGE/PROD: Cloudflare + CloudFront

**Reasons:**

1. **Production Parity** - STAGE mirrors PROD architecture
2. **Advanced Features** - Lambda@Edge, custom origins, OAC
3. **Global Performance** - CloudFront PoPs + Cloudflare PoPs
4. **Image Optimization** - Sharp Lambda Layer for resize
5. **Flexibility** - Can bypass CloudFront for debugging

**Benefits:**

- Test production architecture in STAGE
- Lambda@Edge functions for dynamic content
- S3 origin access control (OAC)
- Image resize at edge locations

---

## Feature Availability Matrix

| Feature                | DEV          | STAGE                 | PROD                 |
| ---------------------- | ------------ | --------------------- | -------------------- |
| **Cloudflare Proxy**   | ✅           | ✅                    | ✅                   |
| **Cloudflare WAF**     | ✅           | ✅                    | ✅                   |
| **CloudFront CDN**     | ❌           | ✅                    | ✅                   |
| **Lambda@Edge**        | ❌           | ✅                    | ✅                   |
| **Sharp Image Resize** | ❌           | Available             | Available            |
| **Cloudflare Tunnel**  | ✅           | ❌                    | ❌                   |
| **Direct ALB Access**  | ✅ (default) | ✅ (api-direct-stage) | ✅ (api-direct-prod) |
| **S3 Image Storage**   | ❌           | When enabled          | When enabled         |
| **ECS Fargate**        | ✅ (default) | ✅ (default)          | ✅ (default)         |
| **ECS EC2 (Hybrid)**   | Available    | Available             | Available            |
| **ENI Trunking**       | When enabled | When enabled          | When enabled         |

---

## ECS Compute Strategy

### Hybrid Architecture (Fargate + EC2)

Each service independently selects its launch type:

| Service Type     | Launch Type | CPU Arch | compute_mode | Use Case                  |
| ---------------- | ----------- | -------- | ------------ | ------------------------- |
| Low-traffic API  | FARGATE     | X86_64   | `ecsfg`      | Development, small sites  |
| High-density API | EC2         | ARM64    | `ecsec2-arm` | 100+ site clients         |
| Worker/batch     | EC2         | ARM64    | `ecsec2-arm` | Background processing     |
| Bursty workload  | FARGATE     | ARM64    | `ecsfg`      | Auto-scaling, zero-to-one |

### GCP Cloud Run

Cloud Run services are serverless containers — no capacity provider management needed:

| Service Type     | Platform   | CPU Arch | Use Case                    |
| ---------------- | ---------- | -------- | --------------------------- |
| API Service      | Cloud Run  | X86_64   | REST/GraphQL endpoints      |
| Background Job   | Cloud Run  | X86_64   | Async processing, queues    |

### Azure Container Apps

Container Apps run on a shared managed environment:

| Service Type     | Platform        | CPU Arch | Use Case                  |
| ---------------- | --------------- | -------- | ------------------------- |
| API Service      | Container Apps  | X86_64   | REST/GraphQL endpoints    |
| Background Job   | Container Apps  | X86_64   | Event-driven processing   |

**Prerequisites:**
- `account-settings` stack deployed (ENI Trunking enabled)
- `ec2-capacity-provider` module provisioned via `network` stack

---

## Testing Strategy

### Development Testing (DEV)

```bash
# Test via Cloudflare
curl "https://api-dev.thisisblaze.uk/health"

# Test local via Tunnel
curl "http://localhost:3000/health"
```

### Pre-Production Testing (STAGE)

```bash
# Test via CloudFront (default)
curl "https://api-stage.thisisblaze.uk/health"

# Test bypassing CloudFront (debugging)
curl "https://api-direct-stage.thisisblaze.uk/health"

# Test image resize (if enabled)
curl "https://frontend-stage.thisisblaze.uk/convert/test.jpg?width=800"
```

### Production Testing (PROD)

```bash
# Test via CloudFront (production traffic)
curl "https://api.thisisblaze.uk/health"

# Emergency bypass (if CloudFront issues)
curl "https://api-direct-prod.thisisblaze.uk/health"
```

---

## Migration Path

If you want to enable CloudFront in DEV (not recommended):

1. Update `dev-network/main.tf`:

   ```hcl
   enable_cloudfront = true
   ```

2. Provision network:

   ```bash
   gh workflow run "01a-provision-network.yml" \
     --repo thebyte9/blaze-template-deploy \
     -f environment=DEV \
     -f apply=true
   ```

3. Update DNS to point to CloudFront

**Note:** This will increase costs and complexity for minimal dev benefit.

---

## Cost Implications

**DEV (Cloudflare Only):**

- Cloudflare: $0 (Free plan)
- ALB: ~$20/month
- **Total CDN Cost: $0/month**

**STAGE/PROD (Cloudflare + CloudFront):**

- Cloudflare: $0 (Free plan)
- CloudFront: ~$50-200/month (depending on traffic)
- Lambda@Edge: ~$5-20/month (if image resize enabled)
- ALB: ~$20/month
- **Total CDN Cost: $55-220/month per environment**

---

## Multi-Site Architecture (April 2026 — two-pillar-v2)

The platform now supports multiple projects sharing a single ECS cluster, ALB, and VPC. Each project gets fully isolated ECS services, CloudFront distributions, S3 buckets, and (optionally) Atlas DB users.

### Active Projects

| Project | Environments | Stack | Priority Base |
|---------|-------------|-------|---------------|
| `thisisblaze` | dev, stage, prod | `{env}-multi-site-app` | 100 |
| `support` | dev, stage, prod | `{env}-multi-site-app-support` | 200 |

### Shared vs. Isolated Resources

| Resource | Shared | Isolated |
|----------|--------|----------|
| ECS Cluster + VPC | ✅ All projects | — |
| ALB + Listeners | ✅ All projects | — |
| Atlas Cluster (db-pod-alpha) | ✅ Per environment | — |
| ECS Services | — | ✅ Per project |
| ALB Listener Rules + TGs | — | ✅ Per site (`lb_priority` pinned) |
| CloudFront Distributions | — | ✅ Per site |
| S3 Buckets (admin, CDN, storage) | — | ✅ Per project |
| Atlas DB User + SSM `BLAZE_CONNECTION_STRING` | — | ✅ Per `project_key` |

### Database Provisioning Model (2026-04-14)

```
01g  → shared Atlas M10 cluster + VPC peering  (once per environment)
01c  → per-project Atlas DB user + SSM secret    (automatic when enable_db_users=true)
```

- SSM path: `/blaze/{client}/{project_key}/{stage}/BLAZE_CONNECTION_STRING`
- ECS containers read via `valueFrom` — no runtime secret injection needed
- VPC peering locks Atlas IP access to VPC CIDR only (no open 0.0.0.0/0)

### Adding a New Tenant

1. Add entry to `sites = {}` in `{env}-multi-site-app/terraform.tfvars` with `project_key`
2. Run `01c` for that environment
3. Done — ECS service, ALB rules, CloudFront, S3, Atlas user all provisioned automatically

---

**Last Updated:** 2026-05-09  
**Maintained By:** Infrastructure Team  
**Review Frequency:** Quarterly or when architecture changes  
**Cloud Providers:** AWS (ECS Fargate/EC2 Hybrid), GCP (Cloud Run), Azure (Container Apps)
