#!/usr/bin/env python3
import sys
import os

# Add scripts dir to path to import engines
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from engines import engine1_docs
from engines import engine4_modules
from engines import engine5_security
from engines import engine6_hygiene
from engines import engine8_workflows

# Detect execution environment
is_ci = os.environ.get("GITHUB_ACTIONS") == "true"

if is_ci:
    # Running inside GitHub Actions (repositories checkout side-by-side)
    base_dir = os.environ.get("GITHUB_WORKSPACE", ".")
    REPOS = {
        "deploy": os.path.join(base_dir, "blaze-template-deploy"),
        "actions": os.path.join(base_dir, "blaze-actions"),
        "infra": os.path.join(base_dir, "blaze-terraform-infra-core")
    }
else:
    # Running locally on developer laptop
    REPOS = {
        "deploy": "/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy",
        "actions": "/Users/marek/Workspace/thisisblaze/blaze-actions",
        "infra": "/Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core"
    }

print("🔧 CHECKENGINES REPORT — RUNNING FULL DIAGNOSTIC SWEEP...")

results = {}

print("-> Running Engine 1: Docs Freshness...")
results['docs'] = engine1_docs.run(REPOS)

print("-> Running Engine 4: Module Versions...")
results['modules'] = engine4_modules.run(REPOS)

print("-> Running Engine 5: Security Patterns...")
results['security'] = engine5_security.run(REPOS)

print("-> Running Engine 6: Hygiene Check...")
results['hygiene'] = engine6_hygiene.run(REPOS)

print("-> Running Engine 8: Workflow Parity...")
results['workflows'] = engine8_workflows.run(REPOS)

print("\n--- DASHBOARD ---")
print(f"ENGINE 1 — DOCS FRESHNESS:        {'✅ OK' if results['docs'] == 0 else '⚠️ ISSUES'}")
print(f"ENGINE 4 — MODULE VERSIONS:       {'✅ MATH PARITY' if results['modules'] == 0 else '🔴 SPLIT BRAIN DRIFT'}")
print(f"ENGINE 5 — SECURITY PATTERNS:     {'✅ OK' if results['security'] == 0 else '🔴 BANNED PATTERN'}")
print(f"ENGINE 6 — HYGIENE:               {'✅ OK' if results['hygiene'] == 0 else '⚠️ ISSUES'}")
print(f"ENGINE 8 — WORKFLOW PARITY:       {'✅ IN SYNC' if results['workflows'] == 0 else '🔴 OUT OF SYNC'}")
print("\nEnsure you check graph drift and stress tests overnight status manually!")

# Exit with error if any hard failures (Security, Modules, Workflows)
if results['security'] > 0 or results['modules'] > 0 or results['workflows'] > 0:
    sys.exit(1)
sys.exit(0)
