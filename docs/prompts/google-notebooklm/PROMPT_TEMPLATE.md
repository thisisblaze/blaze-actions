# NotebookLM Prompt Template

**Copy and paste this into NotebookLM chat to guide the Slide deck/Infographic generation**

---

## THE MASTER PROMPT (Copy-Paste This)

```
IMPORTANT RULES:
1. Use ONLY information from the 5 uploaded source documents
2. Do NOT add information from your general knowledge
3. If something is not in the sources, say "not mentioned in sources"
4. Use simple, clear language - avoid jargon and complex terms
5. When you must use technical terms, explain them simply

Create presentation content covering:

SECTION 1: The Problem (2 minutes)
- What problems existed before Blaze?
- Use specific examples from PART_01
- Include real numbers (time wasted, costs)
- Keep explanations simple for non-technical executives

SECTION 2: The Solution Architecture (3 minutes)
- Explain the 3 repositories (blaze-actions, blaze-terraform-infra-core, blaze-template-deploy)
- Show hub & spoke pattern
- Use the "400 lines vs 15 lines" comparison from sources
- Explain in simple terms - avoid technical jargon

SECTION 3: How It Works (3 minutes)
- The 4 main workflows: 00, 01, 02, 99
- Use real examples from PART_02
- Show actual timeline: 2 hours to production
- Keep it practical, not theoretical

SECTION 4: Real Results (2 minutes)
- Time savings: Use exact percentages from sources
- Cost savings: Use exact numbers from sources
- Security improvements: Use facts from sources
- Do NOT exaggerate or add extra benefits not mentioned

DIAGRAMS NEEDED (request Mermaid code for these):
1. Architecture diagram: 3 repositories and how they connect
2. Workflow flowchart: Code commit → Production deployment
3. Before vs After: 400 lines of code vs 15 lines
4. AWS resources created: VPC, ECS, CloudFront, etc.

TONE & STYLE:
- Talk like you're explaining to a smart friend
- Use "we" and "you"
- Avoid words like "leverage", "paradigm", "synergy"
- Use words like "use", "pattern", "benefit"
- Be specific, not vague

WHAT TO AVOID:
- Do NOT say "cutting-edge" or "revolutionary" unless sources say it
- Do NOT add features not mentioned in sources
- Do NOT use buzzwords not in the sources
- Do NOT make up statistics

VERIFICATION:
For each fact you include, you should be able to point to which PART it came from.
If you're unsure, cite the source: "According to PART_02..."
```

---

## ALTERNATIVE: Simple Executive Version

```
Create a simple, executive-friendly presentation using ONLY the 5 source documents.

TARGET AUDIENCE: Non-technical executives who need to understand business value

RULES:
✓ Use only facts from the sources
✓ Simple language (explain like I'm 12)
✓ Real numbers and examples only
✗ No jargon unless explained
✗ No making up benefits
✗ No complex technical terms

STRUCTURE:

Slide 1: The Problem
- What was broken? (from PART_01)
- How much did it cost? (exact numbers)
- Why did it matter?

Slides 2-3: The Solution
- What is Blaze? (simple explanation)
- The 3 parts and how they work together
- Show the "400→15 lines" example

Slides 4-5: How It Works
- 4 simple steps (from the workflows)
- Real timeline: 2 hours
- What happens at each step

Slide 6: Results
- Time saved (exact %)
- Money saved (exact $)
- Problems solved
- All numbers from sources only

DIAGRAMS TO CREATE:
1. Simple architecture: 3 boxes showing the 3 repos
2. Timeline: Steps from start to finish
3. Before/After comparison
4. Results chart: Time & cost savings

LANGUAGE LEVEL:
- 8th grade reading level
- Short sentences
- One idea per bullet point
- Explain all acronyms (ECS = container service, etc.)
```

---

## MERMAID DIAGRAM REQUEST

```
Create Mermaid diagram code for the following. Use ONLY information from the sources.

1. SYSTEM ARCHITECTURE DIAGRAM
Show:
- blaze-actions (hub)
- blaze-terraform-infra-core (modules)
- blaze-template-deploy (spoke/project)
- How they connect
- Use relationships mentioned in PART_01

2. DEPLOYMENT FLOW DIAGRAM
Show step-by-step from the sources:
- Developer commits code
- Workflow 02 triggers
- Docker images built
- Pushed to ECR
- Deployed to ECS
- Health checks
- Production live

Include actual times from PART_05 (8-10 minutes)

3. BEFORE VS AFTER DIAGRAM
Show:
- Before: 400 lines per project (from sources)
- After: 15 lines per project (from sources)
- Include the "87% less code" stat if mentioned

4. AWS RESOURCES DIAGRAM
Show only resources mentioned in sources:
- VPC
- ECS Cluster
- CloudFront
- S3 buckets
- Whatever else is in PART_03

FORMAT: Provide raw Mermaid markdown code I can copy-paste.
REMEMBER: Only use information from the 5 sources.
```

---

## INFOGRAPHIC REQUEST

```
Create an infographic using ONLY source information.

TITLE: "Blaze Infrastructure Platform: By The Numbers"

INCLUDE ONLY THESE IF IN SOURCES:
- Time to deploy: Before vs After
- Cost savings: $ amount
- Code reduction: Lines before vs after
- Deployment frequency: How often
- Security incidents: Before vs After
- Team productivity: Improvement %

STYLE:
- Clean and simple
- Big numbers that stand out
- Icons for each metric
- Before/After comparisons
- Timeline if mentioned

Do NOT add:
- Metrics not in sources
- Rounded or estimated numbers
- Industry comparisons not mentioned
- Claims not backed by sources
```

---

## QUICK CONSTRAINTS CHECKLIST

Before generating, NotebookLM should verify:

- [ ] Every fact has a source (PART_01 through PART_05)
- [ ] No technical jargon without explanation
- [ ] All numbers are exact from sources
- [ ] No buzzwords not in sources
- [ ] Language is simple and clear
- [ ] Diagrams use only source information
- [ ] No invented benefits or features

---

## EXAMPLE GOOD VS BAD

❌ **BAD (Hallucinated):**
"Blaze leverages cutting-edge cloud-native paradigms to synergize deployment workflows"

✅ **GOOD (From sources):**
"Blaze reduces deployment code from 400 lines to 15 lines by centralizing workflows"

---

❌ **BAD (Made up):**
"Improves developer satisfaction by 10x"

✅ **GOOD (From sources):**
"Deployment time reduced from 2-3 days to 15 minutes" (PART_01)

---

❌ **BAD (Too technical):**
"Utilizes ECS Fargate with ALB for ephemeral containerized microservices"

✅ **GOOD (Simple):**
"Runs application code in containers on AWS, with a load balancer to distribute traffic"

---

## HOW TO USE

1. Upload the 5 PART files to NotebookLM
2. Copy the MASTER PROMPT above
3. Paste into NotebookLM chat
4. Click "Slide deck" or "Infographic" in Studio (right panel)
5. Review output - verify all facts are from sources
6. Request Mermaid diagrams separately if needed

---

**Last Updated:** 2026-02-08  
**Purpose:** Ensure NotebookLM creates accurate, source-based, simple presentations
