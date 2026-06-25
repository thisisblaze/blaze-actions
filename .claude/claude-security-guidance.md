# Security guidance for blaze-actions (shared CI engine)
- Pin all third-party actions to a full commit SHA.
- Reusable workflows must not hardcode tenant names, profiles, or secrets.
- Every job sets an explicit least-privilege `permissions:` block.
- Never echo `secrets.*` into logs or step outputs.
- Tags are immutable: never delete or move a released tag.
