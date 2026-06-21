---
paths: ["**/*.tf", ".aws/live/**", ".github/workflows/**"]
---
## 3. Technology Stack & Parity
- **Infrastructure**: Terraform (S3 Backend, DynamoDB Locking). Native AWS ECS Fargate/EC2 Blue/Green. **NO CodeDeploy**. AWS (primary), GCP, Azure (messaging layer parity).
- **CI/CD**: GitHub Actions.
- **Environment Model**:
  - `dev-mini`: Local/Feature-branch sandbox (Cloudflare Tunnel).
  - `dev`: Mirrored staging layer.
  - `stage`: Pre-production.
  - `prod`: Production layer.
- **Destruction Gate**: Zero Autonomous Destruction. Never run nuke/destroy operations without the user explicitly typing `DESTROY` or `EXECUTE`.
