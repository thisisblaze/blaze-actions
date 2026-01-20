---
description: Quick-reference card for daily documentation audit
---

# DAILY DOCUMENTATION AUDIT - QUICK START

**Time:** 2 hours max | **Frequency:** Daily, end of workday

---

## 🚀 FAST EXECUTION

### Copy-Paste This Prompt:

```
Execute DAILY_DOCUMENTATION_AUDIT following docs/prompts/00_core/DAILY_DOCUMENTATION_AUDIT.md

Today's date: [INSERT DATE]

Recent changes:
- [LIST KEY CHANGES FROM TODAY]

Instructions:
1. Review git log from last 24 hours across all 3 repos
2. Execute 5-phase approach (Discovery → Critical → Workflow → AI → Visual)
3. Update all affected documentation from 12 domains
4. Create analysis, implementation plan, and walkthrough artifacts
5. Commit changes with proper message format
6. Report completion with stats

Focus on: [SPECIFIC AREA IF KNOWN, e.g., "namespace changes", "new workflow", "ALL"]
```

---

## 📋 THE 12 DOMAINS (CHECKLIST)

Quick scan - which need updates today?

- [ ] 1. Critical Docs (CHANGELOG, README, ONBOARDING)
- [ ] 2. Workflow Docs (.github/workflows/README.md, REUSABLE_WORKFLOWS.md)
- [ ] 3. System Prompts (00_core/\*.md)
- [ ] 4. AI Workflows (.agent/workflows/\*.md)
- [ ] 5. Visual Docs (docs/graphs/\*.mermaid)
- [ ] 6. Architecture (docs/architecture/\*.md)
- [ ] 7. Config Reference (CONFIGURATION_REFERENCE.md)
- [ ] 8. Operations (operations_manual.md, runbooks)
- [ ] 9. Testing (docs/testing/\*.md)
- [ ] 10. Examples (docs/examples/\*.yml)
- [ ] 11. Onboarding (CLIENT_ONBOARDING.md, guides)
- [ ] 12. Metadata (dates, versions, links)

---

## ⚡ 5-MINUTE TRIAGE

**Before starting full audit, do quick triage:**

```bash
# What changed today?
cd /Users/marek/Workspace/thisisblaze/blaze-actions
git log --since="1 day ago" --oneline --stat

cd /Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core
git log --since="1 day ago" --oneline --stat

cd /Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy
git log --since="1 day ago" --oneline --stat
```

**Decision tree:**

- **No changes?** → Light audit, verify links only (30 min)
- **Minor changes?** → Partial audit, update critical docs (1 hour)
- **Major changes?** → Full audit, all 12 domains (2 hours)

---

## 📂 ARTIFACT STRUCTURE

Create these 3 files each time:

```
<artifacts-dir>/
├── doc_analysis_YYYY-MM-DD.md       # What's impacted?
├── doc_implementation_plan_YYYY-MM-DD.md  # What to update?
└── doc_walkthrough_YYYY-MM-DD.md    # What was done?
```

---

## ✅ SUCCESS CHECKLIST

Before ending:

- [ ] Analysis artifact created
- [ ] Implementation plan created
- [ ] Walkthrough artifact created
- [ ] All Mermaid diagrams render
- [ ] All links work (no 404s)
- [ ] CHANGELOG updated
- [ ] Last Updated dates refreshed
- [ ] Committed with proper message
- [ ] Pushed to remote

---

## 🎯 PRIORITY RULES

**If time is limited, do in this order:**

1. **MUST DO** (15 min):
   - CHANGELOG entry
   - README accuracy
   - Broken link fixes

2. **SHOULD DO** (30 min):
   - Workflow documentation
   - System prompt updates
   - Configuration docs

3. **NICE TO HAVE** (45+ min):
   - New Mermaid diagrams
   - AI workflow updates
   - Example refreshes

---

## 💡 COMMON PATTERNS

### Pattern 1: New Feature Added

→ Update: Domains 1, 2, 7, 10 (Critical, Workflow, Config, Examples)

### Pattern 2: Workflow Modified

→ Update: Domains 1, 2, 4, 5 (Critical, Workflow, AI, Visual)

### Pattern 3: Breaking Change

→ Update: Domains 1, 2, 3, 11 (Critical, Workflow, Prompts, Onboarding)

### Pattern 4: Bug Fix

→ Update: Domains 1, 4, 8 (Critical, AI Workflows, Operations)

---

## 🔧 TOOLS & SHORTCUTS

### Check Broken Links

```bash
find docs -name "*.md" -exec grep -H "](.*)" {} \; | grep -v "http"
```

### Validate Mermaid

Visit: https://mermaid.live/

### Last Updated Search

```bash
grep -r "Last Updated" docs/ | grep -v "2026-01-20"
```

### Commit Template

```bash
git commit -m "docs: daily audit YYYY-MM-DD

- Updated CHANGELOG
- Refreshed N diagrams
- Fixed M broken links
- Added documentation for X

Domains: [numbers]
Files: N"
```

---

**Full Details:** See `DAILY_DOCUMENTATION_AUDIT.md` in same directory

**Last Updated:** 2026-01-20
