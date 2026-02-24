---
description: Bootstraps the AI with targeted architectural context mapping (Token Frugal)
---

# Targeted Context Initialization

Run this with an argument (e.g. `/slash-init-context aws` or `/slash-init-context azure`) to load only the specific files necessary for that domain.

## Steps

### 1. Identify Target Cloud

If the user did not specify a cloud provider, ask them which one they are working on (aws, gcp, azure).

### 2. Targeted Load

Based on the exact provider only load the following:

- **AWS**: `view_file docs/graphs/aws_resource_topology.mermaid`
- **GCP**: `view_file_outline` or check `docs/graphs/` for the GCP equivalent.
- **Azure**: `view_file_outline` or check `docs/graphs/` for the Azure equivalent.

### 3. Frugal Reading

- Do **NOT** read the full `docs/prompts/00_core/REPOSITORY_SYSTEM_PROMPT.md` automatically here (it should be loaded in `/engage` or the user rules).
- Do **NOT** read `docs/reference/NETWORK_STACK_RESOURCES.md` completely. Instead use `grep_search` on it to find the specific Resource Naming convention for the service you are about to build.

### 4. Output Summary

Confirm which specific cloud context has been loaded, and remind the user of the "No Hardcoding" dynamic namespace rule.
