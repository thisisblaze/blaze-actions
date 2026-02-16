---
description: Comprehensive documentation consistency analysis and update across all Blaze repositories
priority: critical
frequency: daily
execution_time: end_of_day
---

# DAILY DOCUMENTATION CONSISTENCY AUDIT

**Purpose:** Execute a systematic, comprehensive documentation audit and update across all Blaze repositories to ensure accuracy, consistency, and completeness.

**When to run:** End of each workday, after code changes have been committed.

---

## OBJECTIVE

Analyze recent code changes and ensure **ALL documentation** is updated to reflect:

- New features or changes
- Architecture updates
- Configuration changes
- Resource naming patterns
- Workflow modifications
- Breaking changes

**Golden Rule:** Code and documentation must **never drift apart**.

---

## SCOPE: THE 12 DOCUMENTATION DOMAINS

Analyze and update documentation across these 12 critical domains:

### 1. **Critical Documentation**

- `CHANGELOG.md` - Breaking changes, new features, fixes
- `README.md` - High-level overview, quick start, namespace config
- `CLIENT_ONBOARDING.md` - Setup guides, secret requirements

### 2. **Workflow Documentation**

- `.github/workflows/README.md` - Workflow catalog and usage
- `docs/REUSABLE_WORKFLOWS.md` - How to call workflows
- `.github/workflows/reusable-pre-destroy-cleanup.yml` - Cleanup logic
- Individual workflow headers and comments

### 3. **System Prompts (AI Governance)**

- `docs/prompts/00_core/REPOSITORY_SYSTEM_PROMPT.md`
- `docs/prompts/00_core/AGENT_PERSONA_SRE_DAEMON.md`
- Critical rules and constraints for AI

### 4. **AI Workflows**

- `.agent/workflows/*.md` - Debugging, troubleshooting guides
- Agent-facing operational documentation
- Examples and patterns

### 5. **Visual Documentation**

- `docs/graphs/*.mermaid` - Architecture diagrams
- Workflow dependency graphs
- Resource topology diagrams
- **Create new diagrams** when architecture changes

### 6. **Architecture Documentation**

- `docs/architecture/*.md` - System design documents
- Integration patterns
- Data flow diagrams

### 7. **Configuration Reference**

- `docs/CONFIGURATION_REFERENCE.md` - All config variables
- `docs/CONFIG_MANAGEMENT.md` - How config works
- Example configurations

### 8. **Operations Documentation**

- `docs/operations_manual.md` - Day-to-day operations
- `docs/runbooks/*.md` - Incident response (Cleanup failures, Zombie resources)
- `docs/security_runbook.md` - Security procedures

### 9. **Testing Documentation**

- `docs/testing/*.md` - Test strategies
- Integration test guides
- Validation procedures

### 10. **Examples**

- `docs/examples/*.yml` - Workflow examples
- Configuration examples
- Use case examples

### 11. **Onboarding Materials**

- Quick start guides
- Setup walkthroughs
- Prerequisites and requirements

### 12. **Metadata & References**

- Last updated dates
- Version numbers
- Cross-references and links

---

## EXECUTION FRAMEWORK: THE 5-PHASE APPROACH

Execute in this order for systematic coverage:

### **PHASE 0: DISCOVERY** (10-15 min)

1. **Identify Recent Changes**

   ```bash
   # What changed today?
   git log --since="1 day ago" --oneline --all

   # What files were modified?
   git diff HEAD@{1.day.ago}..HEAD --name-only

   # Grep for hardcoded values
   grep -r "PATTERN" .github/workflows/
   ```

2. **Repository Scan**
   - Scan all 3 repositories: `blaze-actions`, `blaze-terraform-infra-core`, `blaze-template-deploy`
   - Identify impacted domains from the 12 above
   - Note any new features, breaking changes, or architectural shifts

3. **Create Analysis Task**
   - Create `analysis_task.md` artifact
   - List all identified gaps
   - Prioritize by impact (critical → nice-to-have)

### **PHASE 1: CRITICAL DOCUMENTATION** (15-20 min)

**Priority:** MUST be done if ANY code changed

1. **CHANGELOG Updates**
   - Add entries for any merged changes
   - Mark breaking changes clearly
   - Include migration guides

2. **README Updates**
   - Reflect new features in "Features" section
   - Update examples if API changed
   - Check all links still work

3. **System Prompts**
   - Update AI rules if patterns changed
   - Add examples of correct usage
   - Document new constraints

**Deliverable:** CHANGELOG entry, README accuracy verified

### **PHASE 2: WORKFLOW & CONFIGURATION DOCS** (15-20 min)

1. **Workflow Documentation**
   - Update workflow READMEs if new workflows added
   - Document new inputs/outputs
   - Update reusable workflow guides

2. **Configuration Changes**
   - Document new config variables
   - Update CONFIGURATION_REFERENCE.md
   - Provide examples for new configs

**Deliverable:** Workflow docs match implementation

### **PHASE 3: AI WORKFLOWS & TROUBLESHOOTING** (15-20 min)

1. **Debug Guides**
   - Add new error patterns discovered today
   - Document solutions to issues encountered
   - Update troubleshooting tables

2. **Agent Workflows**
   - Ensure `.agent/workflows/*.md` reflect current patterns
   - Add new debugging sections
   - Update "Last Updated" dates

**Deliverable:** AI can troubleshoot today's issues tomorrow

### **PHASE 4: VISUAL DOCUMENTATION** (20-30 min)

1. **Mermaid Diagrams**
   - **Update existing** if architecture changed
   - **Create new** for new flows (namespace, deployment, etc.)
   - Ensure diagrams render in GitHub

2. **Graph Catalog**
   - Update `docs/graphs/README.md`
   - Document what each diagram shows
   - Add viewing instructions for new diagrams

**Deliverable:** Visual documentation matches reality

### **PHASE 5: TESTING & VALIDATION** (10-15 min)

1. **Verification**
   - Render all Mermaid diagrams (check for syntax errors)
   - Click all markdown links (no 404s)
   - Check code examples are runnable

2. **Cross-Repository Consistency**
   - Ensure naming conventions match
   - Version numbers consistent
   - Examples use correct patterns

**Deliverable:** Zero broken links, zero syntax errors

---

## OUTPUT STANDARDS

### **Artifacts to Create**

For each audit, create these artifacts in `<artifacts-dir>`:

1. **`doc_analysis_<date>.md`** - Impact analysis
   - What changed?
   - What documentation is affected?
   - Detailed file-by-file breakdown

2. **`doc_implementation_plan_<date>.md`** - Update plan
   - Exact changes to make
   - Before/after examples
   - Priority ordering
   - Time estimates

3. **`doc_walkthrough_<date>.md`** - Summary
   - What was updated
   - New diagrams created
   - Commit SHAs
   - Visual progress tracking

### **Documentation Standards**

All documentation must follow:

1. **Markdown Best Practices**
   - Headers for organization
   - Code blocks with language tags
   - Tables for structured data
   - Alerts for warnings/important info

2. **Mermaid Standards**
   - GitHub-compatible syntax
   - Quoted labels with special chars
   - `<br/>` for line breaks (not `\n`)
   - Consistent color scheme

3. **Cross-References**
   - Use relative paths for internal links
   - Use absolute paths for cross-repo links
   - Link to specific line ranges when helpful

4. **Metadata**
   - "Last Updated" dates
   - Version numbers
   - Authors/owners

---

## COMMIT STRATEGY

### **Single Atomic Commit Per Repository**

```bash
# Template commit message
git commit -m "<type>: <scope> - <summary>

<body>
- Bullet point of change 1
- Bullet point of change 2
- Bullet point of change 3

<footer>
Breaking Change: <if applicable>
Relates to: <issue/PR if applicable>"
```

### **Commit Types**

- `docs:` - Documentation only
- `docs(workflows):` - Workflow documentation
- `docs(diagrams):` - Visual documentation
- `docs(ai):` - AI workflow/prompt updates

### **Example**

```bash
git commit -m "docs: daily documentation audit 2026-01-20

- Update CHANGELOG with namespace breaking change
- Add namespace section to README
- Create 3 new Mermaid diagrams
- Update AI debugging guides
- Fix 12 broken links

Domains Updated: 1,2,3,4,5
Files Changed: 15
Impact: High"
```

---

## SUCCESS CRITERIA

A successful daily audit achieves:

✅ **Completeness**

- All 12 domains reviewed
- No undocumented changes from today
- All new features documented

✅ **Accuracy**

- Documentation matches code reality
- No outdated examples
- No broken links

✅ **Consistency**

- Naming conventions aligned cross-repo
- Version numbers match
- Style guide followed

✅ **Discoverability**

- New features easy to find
- Clear examples provided
- Visual aids for complex topics

✅ **Maintainability**

- Last updated dates refreshed
- Cross-references current
- Diagrams source-controlled

---

## ANTI-PATTERNS TO AVOID

❌ **Don't:**

- Update code without updating docs
- Leave TODOs in documentation
- Create diagrams that don't render
- Use absolute GitHub URLs (use relative paths)
- Forget to update "Last Updated" dates
- Skip CHANGELOG entries
- Leave broken links
- Use hardcoded values in examples

✅ **Do:**

- Treat documentation as code
- Test all examples
- Validate all diagrams
- Use consistent terminology
- Link to related docs
- Provide context, not just facts
- Show real examples, not placeholders

---

## TIME BUDGET

**Total Time:** 1.5 - 2 hours daily

| Phase                  | Time   | Cumulative |
| ---------------------- | ------ | ---------- |
| Phase 0: Discovery     | 15 min | 15 min     |
| Phase 1: Critical Docs | 20 min | 35 min     |
| Phase 2: Workflow Docs | 20 min | 55 min     |
| Phase 3: AI Workflows  | 20 min | 75 min     |
| Phase 4: Visual Docs   | 30 min | 105 min    |
| Phase 5: Testing       | 15 min | 120 min    |

---

## SAMPLE EXECUTION

**Example prompt to AI:**

> "Execute DAILY_DOCUMENTATION_AUDIT for 2026-01-20.
>
> Today's changes:
>
> - Added custom namespace support to workflows
> - Updated 3 workflow files
> - Changed resource naming pattern
>
> Follow the 5-phase approach. Create analysis, implementation plan, and walkthrough artifacts. Update all affected documentation domains. Commit when complete."

---

## AUTOMATION TRIGGERS

Run this audit when:

1. **Daily:** End of each workday (mandatory)
2. **On-demand:** After major feature implementation
3. **Pre-release:** Before tagging a new version
4. **Post-incident:** After fixing a critical issue
5. **Weekly deep-dive:** Every Friday (extended audit)

---

## METRICS TO TRACK

Monitor documentation health:

- **Coverage:** % of 12 domains updated this week
- **Freshness:** Average "Last Updated" age
- **Accuracy:** # of broken links found
- **Quality:** # of diagrams created vs outdated
- **Consistency:** # of cross-repo naming mismatches

---

## FINAL CHECKLIST

Before marking audit complete:

- [ ] All 12 documentation domains reviewed
- [ ] All recent code changes documented
- [ ] CHANGELOG updated with today's changes
- [ ] All Mermaid diagrams render correctly
- [ ] All markdown links work (no 404s)
- [ ] Examples tested and accurate
- [ ] Last Updated dates refreshed
- [ ] Commit message follows template
- [ ] Changes pushed to remote
- [ ] Artifacts created and saved

---

**This is a living document. Update this prompt as documentation practices evolve.**

**Last Updated:** 2026-02-16  
**Version:** 1.0  
**Maintainer:** Infrastructure Team
