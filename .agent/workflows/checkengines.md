---
description: 🔧 Check engines — run a full diagnostic sweep across all 3 repos (docs, prompts, graphs, modules, security, hygiene, parity, workflows)
expected_output: A comprehensive 10-engine sweep read-out identifying health warnings.
exclusions: Do NOT apply fixes directly; this is a diagnostic-only sweep.
---

# Check Engines — Full Diagnostic Sweep

Run this mid-session or weekly. It scans all 3 repos, flags issues, and tells you which workflow to run to fix them.
**This is read-only — it reports but does NOT auto-fix or commit.**

## Execution

The logic for the 10-engine sweep has been natively upgraded into a hyper-fast Pure Python orchestrator. 

Execute the native Python orchestrator:

```bash
python3 /Users/marek/Workspace/thisisblaze/blaze-actions/.github/scripts/checkengines/run_sweep.py
```

## Final Output: Dashboard Report

Read the stdout from the python execution and report the dashboard results to the user exactly as formatted by the script.

**RECOMMENDED ACTIONS mapping based on failures:**
If you see failures, suggest these workflows:
- → `/09-maintain-docs` (Engine 1, 6)
- → `/11-maintain-prompts-ai` (Engine 2, 8)
- → `/13-deep-cicd-maintenance` (Engine 1, 2, 8; for active deep sync of docs, prompts, and timestamps)
- → `/slash-weekly-graph` (Engine 3)
- → `/08-audit` (Engine 5)
- → `/cross-environment-consistency` (Engine 7)
- → `/12-stress-test-report` or run stress test (Engine 9)

Do NOT attempt to auto-fix the issues unless explicitly instructed by the user. If all engines are green, quote: "Things are only impossible until they're not." - Captain Jean-Luc Picard 🖖
