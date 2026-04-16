# Architectural Decision Record: ECS Capacity Provider Reconciliation

> [!TIP]
> **Status: SCALED (Multi-Tenant V2)**. Agent workflow instructions adhere strictly to the Phase 1 Foundation / Phase 2 Tenant orchestrated layers.


## Context & The Problem
AWS has a strict limitation natively regarding **ECS Capacity Providers (CPs)**: You cannot delete or update an ECS Capacity Provider if any tasks are currently running on it, or if it is actively associated with the cluster. AWS returns a `ResourceInUseException`.

In Terraform, if the definition of a Capacity Provider changes (for instance, an AMI change, name change, or configuration tag drift), Terraform decides that the CP must be **replaced** (destroyed and re-created). 

Because of the AWS limitation, Terraform gets stuck trying to delete a Capacity Provider that AWS refuses to let go of because tasks are running. Eventually, Terraform times out after waiting for the `DeleteCapacityProvider` action to succeed, failing the CI/CD pipeline and causing state drift.

## The Workaround (The Destructive "Nuclear" Script)
To resolve the timeout issue, a strict pre-apply bash script (`pre_apply.sh` equivalent inside `01-provision-infra.yml`) was introduced. 

This script functions by unconditionally performing the following actions:
1. **Draining the Cluster:** Forcefully scales all active ECS Services down to `desired-count 0`, effectively taking down the application.
2. **Deregistering Instances:** Deregisters all EC2 backend instances from the Capacity Providers.
3. **Detaching CPs:** Programmatically detaches the custom Capacity Providers from the active ECS Cluster using the AWS CLI.
4. **Deleting CPs:** Triggers an async `delete-capacity-provider` operation and polls until AWS removes the resource.
5. **State Manipulation:** Runs `terraform state rm` on the Capacity Providers (and occasionally Lambda@Edge and WAF rules) to force Terraform to reconstruct them from a clean slate during `terraform apply`.

While this mathematically guarantees a successful, timeout-free `terraform apply`, it guarantees **application downtime** on every network execution, even if the Capacity Provider configuration did not actually change.

## The Mitigation (`force_destructive_reconcile`)
As of April 2026, the `01a-provision-network` workflow defaults to skipping this destructive script to preserve downtime-free idempotent runs for drift detection. 

The destructive routine is now guarded behind a boolean flag: `force_destructive_reconcile`.

- **`force_destructive_reconcile: false` (Default)**: Normal Terraform Apply. If nothing has changed, it is 100% safe to run and does not impact uptime. *(Note: If the EC2 autoscaling config HAS changed, Terraform may hang).*
- **`force_destructive_reconcile: true` (Opt-in)**: Triggers the destructive ECS drain. Should **only** be used when explicitly changing the network auto-scaling tier, AMI, or when a generic Terraform apply gets stuck on CP replacement.

## Best Practices
If `01a-provision-network` fails with an AWS timeout waiting to delete an ECS Capacity Provider, do not panic. The fix is to re-run the workflow with the `force_destructive_reconcile` checked in the GitHub Actions UI. This will intentionally incur a temporary outage, clear the stuck Capacity Providers out of band, and reconcile reality.
