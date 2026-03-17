---
description: Freezes the current AI session state to prevent context bloat and rate limits.
expected_output: A finalized handoff state, completed doc updates, and all uncommitted code pushed.
exclusions: Do NOT start new complex tasks during the handoff governance sequence.
---

# Handoff Session

Run this when a conversation has become too long and you need to preserve the Token Context limit. This workflow creates a `docs/HANDOFF.md` file that a brand new AI session can read to resume work instantly.

## Steps

### 1. State Capture

Analyze the current situation and write the precise current state to `docs/HANDOFF.md`.
The file MUST use the following format exactly:

```markdown
# Session Handoff State

**Date/Time**: [Current Time]

## 1. The Exact Objective

[What is the *single* immediate goal we are trying to achieve?]

## 2. Current Progress & Modified Files

- [File path 1]: [Brief summary of uncommitted changes]
- [File path 2]: [Brief summary of uncommitted changes]

## 3. Important Context

[List any specific rules, constraints, or environment details the new agent must know. E.g. "We are only working on Azure, do not touch AWS."]
[List any specific errors or blockers encountered so far]

**ENV Comparison Report Status** (`docs/reports/ENV_COMPARISON_AWS.md`):

- Open 🔴 action items: [list them from the Action Items table]
- WAF policy: CloudFront-only (stage/prod). ALBs are internal.
- NAT policy: GATEWAY when >5 services, NONE otherwise.
- Redis: prod-only. Prod Redis must be on private subnets (not public).

## 4. The Immediate Next Steps

1. [Actionable Step 1]
2. [Actionable Step 2]
```

### 2. Output Instructions

Tell the user:

> "Context successfully frozen to `docs/HANDOFF.md`. You may now close this conversation to avoid context bloat. In a new conversation, type `/slash-resume` to instantly pick up where we left off."
