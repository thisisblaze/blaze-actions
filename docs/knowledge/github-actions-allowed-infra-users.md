# How to Implement `ALLOWED_INFRA_USERS` in a New Repository

This guide explains how to enforce execution restrictions on critical GitHub Actions workflows (like provisioning, nuking, or deployments) to a specific list of authorized infrastructure users. This pattern aligns with the standard Blaze infrastructure access control mechanism.

## 1. Create the Configuration File

Create a `vars/blaze-env.json` file in the root of your repository (if it doesn't already exist). This file serves as the single source of truth for your authorized users.

```json
{
  "common": {
    "ALLOWED_INFRA_USERS": "your-github-username, another-admin-username"
  }
}
```
> [!NOTE]
> Ensure the usernames exactly match the users' GitHub handles and are comma-separated.

## 2. Update the Target Workflow(s)

Edit the critical workflows (e.g., `.github/workflows/01-provision-infra.yml`) where you want to enforce access control. 

Add the **Load Access List** and **Check Access** steps immediately after checking out the repository code. This ensures the workflow halts before any cloud provider credentials or Terraform configurations are initialized.

```yaml
jobs:
  provision:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v6

      # --- 1. LOAD THE ALLOWED USERS LIST ---
      - name: Load Access List
        id: load-access
        run: |
          if [[ -f "vars/blaze-env.json" ]]; then
            ALLOWED=$(jq -r '.common.ALLOWED_INFRA_USERS // empty' vars/blaze-env.json)
            echo "allowed=$ALLOWED" >> "$GITHUB_OUTPUT"
          else
            echo "⚠️ vars/blaze-env.json not found. Skipping access control."
            echo "allowed=" >> "$GITHUB_OUTPUT"
          fi

      # --- 2. ENFORCE ACCESS CONTROL ---
      - name: Check Access
        if: steps.load-access.outputs.allowed != ''
        # Uses the established Blaze composite action
        uses: thisisblaze/blaze-actions/.github/actions/check-access@v2.1.74
        with:
          allowed_users: ${{ steps.load-access.outputs.allowed }}
          actor: ${{ github.actor }}
          
      # --- Rest of your workflow (e.g. AWS configuration, Terraform init) ---
```

> [!WARNING]
> In order for the reusable action to work, your repository settings must allow access to actions from other repositories within your organization, or `thisisblaze/blaze-actions` must be accessible to it.

### 💡 Alternative: Inline Check (No external dependencies)

If your new repository cannot access the `thisisblaze/blaze-actions` repository (e.g., due to cross-organization boundaries or private repo restrictions), use this inline bash alternative for the second step instead:

```yaml
      # --- 2. ENFORCE ACCESS CONTROL (INLINE) ---
      - name: Check Access (Inline)
        if: steps.load-access.outputs.allowed != ''
        run: |
          ALLOWED_USERS="${{ steps.load-access.outputs.allowed }}"
          ACTOR="${{ github.actor }}"
          
          echo "🔒 Access Control Check"
          echo "   Actor: $ACTOR"
          echo "   Allowed: $ALLOWED_USERS"

          # Add commas to boundaries for exact matching
          if [[ ",$ALLOWED_USERS," == *",$ACTOR,"* ]]; then
            echo "✅ Access GRANTED for $ACTOR."
          else
            echo "❌ Access DENIED for $ACTOR."
            echo "   You are not in the ALLOWED_INFRA_USERS list."
            exit 1
          fi
```

## 3. Verify the Implementation

1. **Commit and Push:** Push these changes to your repository.
2. **Positive Test:** Trigger the workflow using an authorized account to ensure it proceeds successfully.
3. **Negative Test:** Temporarily remove your username from `vars/blaze-env.json` (or test with an unauthorized account) and trigger the workflow. Verify that the job immediately fails with an `Access DENIED` message in the GitHub Actions logs.
