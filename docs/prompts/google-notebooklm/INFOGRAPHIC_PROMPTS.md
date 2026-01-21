# INFOGRAPHIC PROMPT: Workflow Visualizations

**Copy-paste this into NotebookLM to create workflow-focused infographics**

---

## WORKFLOW INFOGRAPHIC PROMPT

```
Create a visual infographic showing the 3 main Blaze workflows.

USE ONLY INFORMATION FROM SOURCES (PART_02 and PART_05)

TITLE: "Blaze Workflows: From Setup to Production"

LAYOUT: 3 columns, one for each workflow

---

COLUMN 1: Workflow 01 - Provision Infrastructure
Icon: 🏗️
Time: 5-15 minutes

STEPS (from sources):
1. Select environment (DEV/STAGE/PROD)
2. Choose stack (network/app/acm/etc.)
3. Terraform init (S3 backend)
4. Terraform plan (preview changes)
5. Terraform apply (create resources)

CREATED RESOURCES:
- VPC and subnets
- ECS cluster
- Load balancer (ALB)
- Security groups
- CloudFront (if app stack)

KEY DETAIL: "Plan before apply - always preview"

---

COLUMN 2: Workflow 02 - Deploy Application
Icon: 🚀
Time: 8-12 minutes

STEPS (from sources):
1. Build Docker images
2. Push to ECR
3. Update ECS task definitions
4. Blue/green deployment
5. Health check validation
6. Deploy admin to Cloudflare Pages

TARGETS:
- API: ECS container
- Frontend: ECS container
- Admin: Cloudflare Pages

KEY DETAIL: "Zero downtime deployment"

---

COLUMN 3: Workflow 99 - Ops Utility
Icon: 🔧
Time: Varies

ACTIONS (from sources):
- view-config: Display settings
- cleanup-lambdas: Remove zombies
- unlock-state: Fix Terraform locks
- destroy-cloudflare-pages: Delete projects
- nuke-environment: Complete teardown

SAFETY:
- Dry-run mode available
- Confirmation required
- Pre-destroy cleanup automatic

KEY DETAIL: "Operations and cleanup"

---

FOOTER STATS (use exact numbers from sources):
- Time saved: 95%+
- Code reduction: 400→15 lines
- Deployment frequency: Minutes vs days

VISUAL STYLE:
- Clean, professional
- Each workflow as a vertical flowchart
- Icons for each step
- Color-coded: Blue (provision), Green (deploy), Red (ops)
- Bold time estimates
- Arrows showing flow

DO NOT ADD:
- Steps not in sources
- Made-up statistics
- Features not mentioned
- Complex technical jargon
```

---

## ALTERNATIVE: TIMELINE INFOGRAPHIC

```
Create a timeline infographic: "Complete Environment in 2 Hours"

USE ONLY INFORMATION FROM PART_05

TITLE: "From Zero to Production: The Blaze Timeline"

TIMELINE FORMAT (horizontal):

┌─────────────────────────────────────────────────────┐
│  0:00    0:05    0:15    1:15    1:30    2:00       │
│   │       │       │       │       │       │         │
│  Start  Setup  Network  Wait   App    Deploy  DONE  │
└─────────────────────────────────────────────────────┘

PHASE 1: Bootstrap (0:00-0:05)
- Create S3 backend
- Create DynamoDB lock table
- Create ECR repositories
Icon: ⚙️
Duration: 5 minutes

PHASE 2: Network Stack (0:05-0:15)
- VPC creation
- Subnets and routing
- Load balancer setup
- Security groups
Icon: 🌐
Duration: 8 minutes

PHASE 3: SSL Certificates (0:15-1:15)
- Request ACM certificate
- Wait for DNS validation
- Certificate issued
Icon: 🔒
Duration: 30-60 minutes (mostly waiting)

PHASE 4: Application Stack (1:15-1:30)
- ECS cluster
- ECS services
- CloudFront setup
- Lambda@Edge
Icon: 📦
Duration: 12 minutes

PHASE 5: Deploy Code (1:30-2:00)
- Build Docker images
- Push to ECR
- Deploy to ECS
- Deploy admin to Pages
Icon: 🚀
Duration: 10 minutes

RESULT BOX:
✅ Complete production environment
✅ API running
✅ Frontend live
✅ Admin dashboard deployed

COMPARISON:
Before Blaze: 2-3 DAYS
With Blaze: 2 HOURS
Improvement: 95%+ faster

USE ONLY:
- Times from PART_05
- Steps from PART_02
- No invented phases
```

---

## MERMAID-STYLE INFOGRAPHIC

```
Create an infographic matching the style of these existing diagrams:

REFERENCE (from source files):
- workflow_01_provision.mermaid
- workflow_02_deploy_app.mermaid
- workflow_99_ops_utility.mermaid

MAINTAIN SAME STYLE:
- Flowchart format (flowchart TD or TB)
- Colored boxes for different phases
- Subgraphs for grouping
- Decision diamonds for choices
- Clear start/end points

CREATE 3 SEPARATE INFOGRAPHICS:

INFOGRAPHIC 1: "The Hub & Spoke Pattern"
Show:
- blaze-template-deploy (spoke) at top
- Calls blaze-actions (hub) in middle
- Uses blaze-terraform-infra-core (modules) at bottom
- AWS resources created on right
Use info from PART_01

INFOGRAPHIC 2: "Namespace Flow"
Show:
- vars/blaze-env.json (config source)
- calculate-config reads it
- Outputs namespace variable
- Used in all resource names
- Examples: VPC, ECS, S3, ECR
Use info from PART_01 namespace section

INFOGRAPHIC 3: "Complete Deployment Flow"
Show step-by-step from PART_05:
- Developer commits code
- GitHub Actions trigger
- Workflow 02 executes
- Docker build
- ECR push
- ECS deployment
- Health checks
- Production live
Include timing: 8-10 minutes total

FORMAT:
Provide Mermaid code I can copy-paste
Use same syntax as existing diagrams
Keep it simple and clear
```

---

## SIMPLE ONE-PAGER

```
Create a single-page infographic: "Blaze at a Glance"

4 QUADRANTS:

TOP-LEFT: THE PROBLEM
- Manual deployments: 2-3 days
- Copy-paste errors
- Security risks
- High costs
Icon: ⚠️

TOP-RIGHT: THE SOLUTION
- Centralized workflows
- Reusable modules
- Automated security
- Hub & spoke pattern
Icon: ✅

BOTTOM-LEFT: HOW IT WORKS
3 Simple Steps:
1. Configure (vars/blaze-env.json)
2. Provision (Terraform)
3. Deploy (Docker + ECS)
Icon: ⚡

BOTTOM-RIGHT: THE RESULTS
- 95% faster deployments
- 87% less code
- $100K/year saved
- Zero security incidents
Icon: 📈

CENTER (connecting all):
"3 Repositories Working Together"
- blaze-actions (hub)
- blaze-terraform-infra-core (modules)
- blaze-template-deploy (projects)

USE ONLY:
- Stats from PART_01
- Facts from sources
- No exaggeration
```

---

## HOW TO USE

1. Upload 5 PART files to NotebookLM
2. Copy one of the prompts above
3. Paste into NotebookLM chat
4. Click **"Infographic"** button in Studio (right panel)
5. Wait 20-30 seconds
6. Download or export the visual

**TIP:** Try multiple prompts to get different visual styles!

---

**Created:** 2026-01-21  
**Based on:** Existing Mermaid diagrams in docs/graphs/  
**Purpose:** Create consistent, source-based workflow infographics
