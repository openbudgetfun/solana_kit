# Changesets and releases

## Changesets

- Never delete files in `.changeset/`; they are release inputs.
- Any PR that changes files under `packages/*` must include a `.changeset/*.md` file.
- Use monochange package ids from `monochange.toml` in changeset frontmatter.
- For changes that affect the lockstep Dart group, listing affected package ids is enough; monochange propagates the selected bump through `group.main`.

```md
---
"solana_kit_rpc": minor
"solana_kit_transactions": minor
---

# Add new RPC and transaction helpers

Describe the user-visible change.
```

Valid release bump values are `patch`, `minor`, `major`, and `test`.

Create changesets with the configured monochange workflow:

```bash
mc document
```

## Release workflow

Use dry runs before real release actions.

```bash
mc release --dry-run --diff
mc release-pr --dry-run
```

`mc release-pr` prepares version bumps, changelogs, release metadata, and opens or updates the configured monochange release PR. After the release PR merges to `main`, GitHub Actions tags the release commit and publishes GitHub release notes from the embedded monochange release record.

Publishing package artifacts is a separate trusted-publishing workflow:

```bash
mc step:publish-readiness --from HEAD --format json
mc publish --dry-run
mc publish
```
