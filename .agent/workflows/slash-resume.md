---
description: Bootstraps a brand new AI session from a frozen Handoff state.
---

# Resume Session

Run this in a brand new pristine AI conversation to pick up work exactly where the previous excessively-long session left off.

## Steps

### 1. Read State

Read the contents of the `docs/HANDOFF.md` file from `blaze-template-deploy`. Do **not** read any other architecture diagrams or system prompts unless explicitly instructed to by the Handoff document.

### 2. ENV Comparison Report Quick Scan

Run these two greps on `blaze-template-deploy` to surface any open critical items before starting work:

```bash
grep -n "🔴" docs/reports/ENV_COMPARISON_AWS.md | grep -v "DONE"
grep -n "Last Updated" docs/reports/ENV_COMPARISON_AWS.md
```

If any unresolved 🔴 items are found, surface them in your acknowledgement.

### 3. Acknowledge & Execute

Output a brief summary confirming you understand the objective, any open 🔴 items from the ENV report, and the immediate next steps from the Handoff doc.
Immediately begin executing Step 1 from "The Immediate Next Steps" section of the document.
