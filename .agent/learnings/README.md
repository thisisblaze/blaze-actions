# 🤖 Auto-Learning System

This directory contains **automatically captured learnings** from AI agent work sessions.

## How It Works

### Automatic Triggers

The AI agent automatically captures knowledge when:

1. **Iterative Debugging** (≥3 attempts)

   - Multiple fix attempts needed
   - Pattern emerges through iterations
   - Example: Docker permission errors (4 iterations)

2. **Root Cause Analysis** (complexity ≥7)

   - Critical bugs discovered
   - Deep investigation required
   - Example: Terraform lock timestamp bug (11h outage)

3. **Pattern Recognition** (≥2 occurrences)

   - Same error appears multiple times
   - Reusable solution identified
   - Example: Always use sudo for Docker files

4. **Task Completion** (complexity ≥8)

   - Complex automation achieved
   - Novel integration created
   - Example: Sharp Lambda Layer CI/CD

5. **Novel Errors** (never seen before)
   - Completely new error type
   - No existing documentation
   - Example: YAML multi-line Python syntax

### What Gets Captured

Each learning includes:

- ✅ **Problem/Error** - Exact error message and context
- ✅ **Root Cause** - Why it happened, underlying issues
- ✅ **Fix Applied** - Code changes, commands, commits
- ✅ **Prevention** - How to avoid in future
- ✅ **Testing** - Verification procedures
- ✅ **Metrics** - Time, iterations, impact
- ✅ **AI Notes** - Pattern recognition, reusability score

### Directory Structure

```
.agent/learnings/
├── .template.md              # Template for new learnings
├── README.md                # This file
├── terraform/               # Terraform-specific learnings
│   └── 2026-01-13-critical-lock-timestamp-bug.md
├── docker/                  # Docker-related learnings
│   └── 2026-01-13-permission-errors-sudo.md
├── github-actions/          # GitHub Actions learnings
├── cloudfront/              # CloudFront learnings
├── aws/                     # General AWS learnings
└── general/                 # Uncategorized learnings
```

## Configuration

See `.agent/config.yml` for:

- Trigger settings
- Quality thresholds
- Content requirements
- Storage options

## Benefits

### For AI Agents

- **Faster problem resolution** - Check learnings first
- **Pattern matching** - Recognize similar issues
- **Confidence scoring** - Know which fixes work
- **Reusability** - Apply proven solutions

### For Humans

- **Knowledge base** - All fixes documented
- **Trend analysis** - See common issues
- **Onboarding** - Learn from past sessions
- **Audit trail** - Understand what changed

## Usage

### AI Agent Usage

```
1. Encounter error
2. Check .agent/learnings/{category}/
3. Find similar issue
4. Apply documented fix
5. If new: auto-capture learning
```

### Human Review

```bash
# List all learnings
ls -la .agent/learnings/*/*.md

# View specific learning
cat .agent/learnings/terraform/2026-01-13-critical-lock-timestamp-bug.md

# Search for pattern
grep -r "permission denied" .agent/learnings/

# List by recency
ls -lt .agent/learnings/*/*.md | head -10
```

## Quality Metrics

Each learning includes:

| Metric               | Description                    |
| -------------------- | ------------------------------ |
| **Complexity**       | 1-10 scale of issue difficulty |
| **Iterations**       | Number of attempts to fix      |
| **Time to diagnose** | How long to find root cause    |
| **Time to fix**      | How long to implement solution |
| **Reusability**      | 1-10 how likely to recur       |
| **Confidence**       | % certainty fix is correct     |

## Examples from Current Session

### Critical Learnings

- **[Terraform Lock Bug](terraform/2026-01-13-critical-lock-timestamp-bug.md)**

  - Complexity: 9/10
  - Impact: 11-hour outage
  - Reusability: 10/10
  - Fix: JSON parsing correction

- **[Docker Permissions](docker/2026-01-13-permission-errors-sudo.md)**
  - Complexity: 3/10
  - Iterations: 4
  - Reusability: 10/10
  - Fix: Always use sudo

## Integration

### With Workflows

Learnings -> Workflow Guides

```
Multiple related learnings
   ↓
Pattern emerges
   ↓
Auto-suggest workflow guide creation
   ↓
Human reviews and approves
   ↓
Workflow guide created in .agent/workflows/
```

### With Documentation

Auto-captured learnings complement:

- `.agent/workflows/` - Process guides
- `README.md` - Project documentation
- Code comments - Inline explanations

## Statistics (This Session)

| Metric               | Value               |
| -------------------- | ------------------- |
| **Auto-captures**    | 2                   |
| **Categories**       | terraform, docker   |
| **Total complexity** | 12/20               |
| **Avg reusability**  | 10/10               |
| **Impact prevented** | Future 11h+ outages |

## Future Enhancements

- [ ] Knowledge graph linking
- [ ] ML-based categorization
- [ ] Similarity detection
- [ ] Auto-workflow creation
- [ ] Trend analysis dashboard
- [ ] Cross-repo learning sharing

---

**Auto-learning system v1.0**  
**Enabled:** 2026-01-13  
**Status:** ✅ Active & Capturing
