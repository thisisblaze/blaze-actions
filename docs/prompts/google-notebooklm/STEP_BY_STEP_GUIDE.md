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

## Step 3: Use Studio Features (Right Panel)

**IMPORTANT:** Don't use the chat! Use the **Studio** panel on the RIGHT side of NotebookLM.

### What You'll See:

After uploading files, look at the **RIGHT SIDE** of the screen:

```
┌─────────────────────┬──────────────────────┐
│  Your notes         │   ← STUDIO →        │
│  (left side)        │  (right side)        │
│                     │                      │
│  Chat here...       │  [Slide deck] 🎯    │
│                     │  [Infographic] 📊   │
│                     │  [Notebook guide]    │
│                     │  [Study guide]       │
│                     │  [Briefing doc]      │
│                     │  [Audio overview]    │
└─────────────────────┴──────────────────────┘
```

---

### Option A: Generate "Slide deck" (🎯 BEST FOR PRESENTATIONS!)

**THIS IS EXACTLY WHAT YOU WANT!**

1. Look at RIGHT PANEL (Studio)
2. Click **"Slide deck"** button
3. Wait 30-60 seconds
4. NotebookLM creates a **complete Google Slides presentation**!

**What you get:**

- ✅ **Ready-to-use Google Slides** (opens automatically!)
- ✅ 10-15 professional slides
- ✅ Title slide + content slides
- ✅ Clean design and layout
- ✅ Immediately editable

**Perfect for:**

- Executive presentations
- Team meetings
- Conference talks
- Client demos

---

### Option B: Generate "Infographic" (📊 VISUAL ONE-PAGER!)

**Great for executive summaries!**

1. In RIGHT PANEL, click **"Infographic"**
2. Wait 20-30 seconds
3. Gets a beautiful visual one-pager with:
   - Key facts as graphics
   - Timeline or process flow
   - Stats and metrics highlighted
   - Professional design

**Perfect for:**

- Email attachments
- Slack/Teams shares
- Quick overviews
- Executive briefings
- Social media

---

### Option C: Generate "Briefing Doc"

**This is what you want for presentations!**

1. Look at RIGHT PANEL (Studio)
2. Click **"Briefing doc"** button
3. Wait 20-30 seconds
4. NotebookLM generates a structured document with:
   - Executive summary
   - Key points organized by topic
   - Supporting details
   - Perfect structure for slides!

**What you get:**

- Professional document format
- Bullet points ready for slides
- Organized sections
- Can export to Google Docs

---

### Option B: Generate "Study Guide"

1. In RIGHT PANEL, click **"Study guide"**
2. Wait 20-30 seconds
3. Gets:
   - Overview of the system
   - Key concepts explained
   - Q&A format
   - Good for onboarding docs

---

### Option C: Generate "Audio Overview" (Bonus!)

1. Click **"Audio overview"** in RIGHT PANEL
2. Wait 1-2 minutes
3. Gets an AI-generated podcast/discussion about Blaze!
4. Two AI voices discuss the platform
5. Great for listening while commuting

**Time:** ~5-10 minutes of audio

---

## Step 4: Customize the Output

After generating Briefing Doc or Study Guide, you can refine it:

### In the Chat (Left Side), Ask:

```
"Focus the briefing doc on these sections:
1. Problem statement
2. 3-repository architecture
3. Deployment workflow
4. ROI and benefits

Make it suitable for a 10-minute executive presentation."
```

Or:

```
"Reorganize the briefing doc into a presentation format:
- Opening slide: Problem
- Slide 2-3: Architecture
- Slide 4-5: Workflows
- Slide 6: Results
- Closing: Next steps"
```

### Generate New Version:

After refining with chat, click **"Briefing doc"** again to regenerate with your feedback!

---

## Step 5: Export to Google Docs/Slides

### From Briefing Doc:

1. Click the **"⋮"** (three dots) menu
2. Select **"Open in Google Docs"**
3. Now you have editable document
4. Copy sections into Google Slides
5. Add visuals

### Creating Slides:

1. Open Google Slides
2. Copy section headings as slide titles
3. Copy bullet points as slide content
4. Add diagrams from our mermaid files

---

## Step 6: Create Specific Presentation Formats

### For 5-10 Minute Executive Presentation:

**In Chat, type:**

```
Create an executive presentation outline covering:
- Problem: Infrastructure chaos (1 min)
- Solution: Hub & spoke architecture (2 min)
- Key workflows in action (2 min)
- ROI: Time and cost savings (1 min)
- Next steps (1 min)

Focus on business value and metrics, not technical details.
Use conversational tone suitable for execs.
Include specific numbers from the sources.
```

**Then click "Briefing doc"** → Get formatted output

---

### For 15-Minute Technical Deep-Dive:

**In Chat, type:**

```
Create a technical presentation outline covering:
- Problem and context (2 min)
- 3-repository architecture detailed (4 min)
- Complete workflow walkthrough (3 min)
- Namespace and multi-tenancy (2 min)
- Security and best practices (2 min)
- Lessons learned (2 min)

Include code examples, resource naming patterns, and technical details.
Target audience: Engineers and DevOps teams.
Reference specific workflows (00, 01, 02, 99) from the sources.
```

**Then click "Briefing doc"** → Get technical outline

---

## Step 7: Generate Mermaid Diagrams

**In Chat, ask:**

```
Create Mermaid diagram code showing:
1. The 3-repository architecture
2. How blaze-template-deploy calls blaze-actions
3. How blaze-actions uses blaze-terraform-infra-core
4. AWS resources created

Provide raw Mermaid markdown code.
```

**Copy the code** → Paste at https://mermaid.live → Download as PNG → Add to slides

---

## Quick Reference: Studio vs Chat

| Feature            | Where                               | When to Use                   |
| ------------------ | ----------------------------------- | ----------------------------- |
| **Briefing Doc**   | RIGHT (Studio)                      | Create presentation outline   |
| **Study Guide**    | RIGHT (Studio)                      | Create onboarding material    |
| **Audio Overview** | RIGHT (Studio)                      | Get podcast-style explanation |
| **Chat**           | LEFT                                | Refine content, ask questions |
| **Customize**      | LEFT (Chat) then RIGHT (regenerate) | Improve outputs               |

---

## The Right Workflow

```
1. Upload 5 files ✓
2. Click "Briefing doc" (RIGHT PANEL) → Wait
3. Review generated briefing doc
4. In CHAT: "Focus on [specific topics]"
5. Click "Briefing doc" again → Get refined version
6. Export to Google Docs
7. Convert to slides
8. Add diagrams
9. Present! 🎉
```

---

## Common Mistakes

❌ **Wrong:** Typing long prompts in chat and expecting presentation  
✅ **Right:** Use chat to guide, then click Studio buttons

❌ **Wrong:** Looking for presentation in chat responses  
✅ **Right:** Check RIGHT PANEL for generated docs

❌ **Wrong:** Uploading README.md  
✅ **Right:** Upload only PART_01 through PART_05

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
