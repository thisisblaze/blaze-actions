# STEP-BY-STEP: How to Create Presentations with Google NotebookLM

This guide walks you through **exactly** how to use the prompt files to generate presentations.

---

## What is Google NotebookLM?

Google NotebookLM is an AI tool that reads your documents and can:

- Answer questions about them
- Create summaries
- Generate presentations
- Create study guides

**Access it here:** https://notebooklm.google.com

---

## Step 1: Access Google NotebookLM

1. Open your browser
2. Go to: **https://notebooklm.google.com**
3. Sign in with your Google account
4. Click **"+ New notebook"**

---

## Step 2: Upload the Source Documents

**IMPORTANT:** Upload the **PART** files, NOT the README!

### Files to Upload (in this order):

1. `PART_01_OVERVIEW_AND_ARCHITECTURE.md`
2. `PART_02_BLAZE_ACTIONS.md`
3. `PART_03_BLAZE_TERRAFORM_INFRA.md`
4. `PART_04_BLAZE_TEMPLATE_DEPLOY.md`
5. `PART_05_INTEGRATION_AND_WORKFLOWS.md`

### How to Upload:

**Option A: Drag and Drop**

- Open the folder: `blaze-actions/docs/prompts/google-notebooklm/`
- Select all 5 PART files
- Drag them into the NotebookLM window

**Option B: Manual Upload**

1. Click **"+ Add source"** in NotebookLM
2. Choose **"Upload"**
3. Select **"Document"**
4. Choose first PART file
5. Repeat for all 5 PART files

**What you'll see:**

```
Sources (5)
├── PART_01_OVERVIEW_AND_ARCHITECTURE.md
├── PART_02_BLAZE_ACTIONS.md
├── PART_03_BLAZE_TERRAFORM_INFRA.md
├── PART_04_BLAZE_TEMPLATE_DEPLOY.md
└── PART_05_INTEGRATION_AND_WORKFLOWS.md
```

---

## Step 3: Generate Short Presentation (5-10 minutes)

### Copy This Exact Prompt:

```
Create a professional 5-10 minute presentation about the Blaze Infrastructure Platform.

Structure:
1. Opening: The Problem (1-2 minutes)
   - Show pain points before Blaze
   - Business impact (cost, time, security)

2. The Solution: Architecture Overview (2-3 minutes)
   - The 3-repository architecture
   - Hub & Spoke pattern visual
   - How it reduces 400 lines to 15 lines

3. Key Workflows (2-3 minutes)
   - Workflow 00: Bootstrap
   - Workflow 01: Provision Infrastructure
   - Workflow 02: Deploy Application
   - Show timeline: Zero to production in 2 hours

4. Real-World Impact (1-2 minutes)
   - Time savings: 95%+ faster deployments
   - Cost savings: $100K/year
   - Security: Zero incidents

5. Closing: Next Steps (1 minute)
   - How to get started
   - ROI summary

Visual Requirements:
- Include diagram showing hub & spoke pattern
- Show before/after code comparison (400 vs 15 lines)
- Display success metrics in charts
- Use timeline graphic for deployment workflow

Audience: Technical leadership, CTOs, Engineering VPs
Tone: Professional, results-focused, visual-heavy
Goal: Get buy-in to adopt the platform
```

### What to Do:

1. Paste the prompt above into the NotebookLM chat
2. Press Enter
3. Wait 30-60 seconds
4. NotebookLM will generate the presentation outline

### What You'll Get:

NotebookLM will provide:

- **Slide-by-slide outline** with talking points
- **Content for each slide**
- **Suggested visuals**
- **Time estimates** per section

---

## Step 4: Generate Long Technical Presentation (15 minutes)

### Copy This Exact Prompt:

```
Create a comprehensive 15-minute technical deep-dive presentation about the Blaze Infrastructure Platform.

Structure:
1. Problem Statement & Context (2 minutes)
   - Infrastructure chaos before Blaze
   - Manual deployment nightmares
   - Security gaps and compliance issues
   - Real cost: $100K/year wasted

2. Solution Architecture (4 minutes)
   - The 3-repository ecosystem explained
   - blaze-actions: The automation hub
   - blaze-terraform-infra-core: Module library
   - blaze-template-deploy: Project templates
   - Hub & Spoke pattern deep-dive
   - Show Mermaid diagram of system integration

3. Repository Deep-Dive (3 minutes)
   - blaze-actions: 24 workflows, 5 composite actions
   - Key workflows: 00 (setup), 01 (provision), 02 (deploy), 99 (ops)
   - Terraform modules: VPC, ECS, ALB, CloudFront
   - Workflow wrapper example: 15 lines vs 400

4. Complete Workflow Example (3 minutes)
   - Walk through: New environment from zero
   - Step 1: Bootstrap (5 min)
   - Step 2: Network stack (8 min)
   - Step 3: SSL certificates (wait)
   - Step 4: Application stack (12 min)
   - Step 5: Deploy code (10 min)
   - Total: ~2 hours to full production

5. Advanced Features (2 minutes)
   - Dynamic namespace for multi-tenancy
   - OIDC security (no long-lived keys)
   - Automated security scanning
   - Hybrid deployment (AWS + Cloudflare)

6. Results & Lessons Learned (1 minute)
   - Time savings: 95%+
   - Cost savings: $100K/year
   - Zero security incidents
   - 96% less code to maintain

Visual Requirements:
- Architecture diagram showing all 3 repositories
- Workflow sequence diagrams
- Resource naming pattern examples
- Code comparison slides (before/after)
- Timeline visualization for complete deployment
- Success metrics dashboard
- Multi-tenant namespace example

Audience: Engineering teams, DevOps practitioners, Solutions architects
Tone: Technical but accessible, code-heavy, detailed
Goal: Enable engineers to understand and use the platform
Include: Real code examples, actual resource names, specific metrics
```

### What to Do:

1. Paste the prompt above into NotebookLM chat
2. Press Enter
3. Wait 30-60 seconds
4. Review the detailed technical presentation

---

## Step 5: Request Specific Outputs

After generating the presentation, you can ask NotebookLM for specific formats:

### Get PowerPoint-Style Outline:

```
Convert the presentation into a slide-by-slide outline with:
- Slide title
- Bullet points for each slide
- Speaker notes
- Suggested visuals

Format as a numbered list of slides.
```

### Get Mermaid Diagrams:

```
Create Mermaid diagram code for:
1. The 3-repository architecture
2. Hub & spoke pattern
3. Complete deployment workflow
4. Resource naming pattern

Provide the raw Mermaid code I can copy-paste.
```

### Get Script for Video:

```
Create a word-for-word script for a video presentation.

Include:
- Exact words to say for each slide
- Timing cues
- Transition phrases
- Emphasis points

Target length: [5-10 or 15] minutes
```

---

## Step 6: Export or Use the Content

### Option 1: Copy to Google Slides

1. Create new Google Slides presentation
2. Copy slide titles from NotebookLM
3. Paste content into slides
4. Add visuals (diagrams, charts)

### Option 2: Export as Document

1. In NotebookLM, click "Export note"
2. Opens in Google Docs
3. Edit and format as needed
4. Share with team

### Option 3: Use for Conference Talk

1. Use NotebookLM outline as structure
2. Create slides in your preferred tool
3. Add generated Mermaid diagrams
4. Include code examples provided

---

## Pro Tips

### 1. Ask Follow-Up Questions

```
"Expand on the Hub & Spoke pattern section with more technical details"
"Give me 3 real-world examples of multi-tenant deployments"
"Create a comparison table: Before Blaze vs After Blaze"
```

### 2. Request Different Formats

```
"Convert this to an executive briefing (2 pages)"
"Create a technical whitepaper (5-10 pages)"
"Generate FAQ from this content"
```

### 3. Get Specific Diagrams

```
"Create a detailed Mermaid flowchart showing the complete deployment from code commit to production"
"Generate a architecture diagram showing AWS resources created"
```

### 4. Customize for Audience

```
"Adjust this presentation for non-technical executives"
"Make this more detailed for senior engineers"
"Create a version for security compliance team"
```

---

## Troubleshooting

### Issue: NotebookLM says "I can't find that information"

**Solution:** Be more specific in your prompt:

```
Bad:  "Tell me about workflows"
Good: "Explain the 4 core lifecycle workflows: 00, 01, 02, and 99"
```

### Issue: Presentation is too generic

**Solution:** Request specific details:

```
"Include actual code examples from PART_02"
"Use the real resource naming examples from PART_01"
"Show the exact time savings metrics mentioned in PART_05"
```

### Issue: Missing visualizations

**Solution:** Explicitly request them:

```
"For each section, suggest a specific diagram or visualization"
"Create Mermaid code for the architecture diagram"
```

---

## Example Complete Workflow

Here's what a complete session looks like:

1. **Upload 5 PART files** → NotebookLM: "5 sources added"
2. **Paste short presentation prompt** → NotebookLM generates outline
3. **Ask: "Create Mermaid diagrams"** → Gets diagram code
4. **Ask: "Convert to slide outline"** → Gets PowerPoint-style structure
5. **Copy to Google Slides** → Create actual presentation
6. **Render Mermaid diagrams** at https://mermaid.live
7. **Screenshots diagrams** → Add to slides
8. **Present!** 🎉

---

## Quick Reference

| What You Want       | Prompt to Use                              |
| ------------------- | ------------------------------------------ |
| Executive summary   | Use "Short Presentation" prompt above      |
| Technical deep-dive | Use "Long Presentation" prompt above       |
| Mermaid diagrams    | "Create Mermaid diagram code for..."       |
| Speaker script      | "Create word-for-word script..."           |
| Slide outline       | "Convert to slide-by-slide outline"        |
| More details        | "Expand on [topic] with technical details" |

---

## Need Help?

**Common Questions:**

**Q: Which files do I upload?**  
A: The 5 PART files, NOT the README

**Q: Can I upload just some of them?**  
A: Yes, but you'll get incomplete presentation. Upload all 5 for best result.

**Q: How long does it take?**  
A: 30-60 seconds per prompt

**Q: Can I edit the generated content?**  
A: Yes! Copy to Google Docs/Slides and customize

**Q: Do I need to pay for NotebookLM?**  
A: No, it's currently free with a Google account

---

**Last Updated:** 2026-01-20  
**Tool:** Google NotebookLM  
**Files Needed:** PART_01 through PART_05 (5 files)  
**Time to Create Presentation:** 5-10 minutes
