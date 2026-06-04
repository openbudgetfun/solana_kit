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
monochange run document
```

## Release workflow

Use dry runs before real release actions.

```bash
monochange run release --dry-run --diff
monochange run release-pr --dry-run
```

`monochange run release-pr` prepares version bumps, changelogs, release metadata, and opens or updates the configured monochange release PR. After the release PR merges to `main`, the current flow is to tag and publish locally from the reviewed release commit.

Before publishing package artifacts from the maintainer machine, verify readiness and dry-run the publish from the release commit:

```bash
monochange step publish-readiness --from HEAD --format json
monochange run publish --dry-run
```
