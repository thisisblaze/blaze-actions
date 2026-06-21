#!/usr/bin/env bash
set -e

REPO="thisisblaze/blaze-actions"

# Apply protection to environment branches
for BRANCH in "main" "dev"; do
  echo "🛡️ Setting up strict branch protection rules for ${REPO}:${BRANCH}..."

  # Note: Required status checks are omitted here because tests (like YAML Syntax)
  # run conditionally based on paths modified, which can block PRs if strictly enforced without triggers.
  
  gh api \
    --method PUT \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/${REPO}/branches/${BRANCH}/protection" \
    --input - <<EOF
  {
    "required_status_checks": null,
    "enforce_admins": true,
    "required_pull_request_reviews": {
      "dismiss_stale_reviews": true,
      "require_code_owner_reviews": false,
      "required_approving_review_count": 1
    },
    "restrictions": null,
    "required_linear_history": true,
    "allow_force_pushes": false,
    "allow_deletions": false
  }
EOF

  echo "✅ Branch protection for '${BRANCH}' successfully configured!"
done
