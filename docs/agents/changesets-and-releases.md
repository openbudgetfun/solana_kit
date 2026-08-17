# Changesets and releases

## Changesets

- Never delete files in `.changeset/`; they are release inputs.
- Any PR that changes files under `packages/*` must include a `.changeset/*.md` file.
- Use monochange package ids from `monochange.toml` in changeset frontmatter.
- For changes that affect the lockstep Dart group, listing affected package ids is enough; monochange propagates the selected bump through `group.main`.
- Changesets describe **completed** changes only. They are release inputs that ship to users, so never use them as planning documents for in-progress work (no "remaining", "in progress", or TODO sections). The rare exception is documenting deprecations or future work that belongs to a future release; if a PR lands partially, split the work so each changeset only describes what actually shipped.

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
monochange step publish-packages --dry-run --all --format json
```

Pushes to `main` run `.github/workflows/release-pr.yml`, which prepares version bumps, changelogs, lockfiles, docs, and a MonoChange release commit on `monochange/release/main`, then opens or updates the automated release PR.

After that release PR merges to `main`, the same workflow detects the merged release commit, creates the MonoChange tags, extracts the direct `v*` tag from the `main` release target, and dispatches `.github/workflows/publish.yml` with that tag. The publish workflow checks out the tag, verifies readiness, publishes changed packages with `monochange step publish-packages`, and then publishes GitHub release objects.

For local verification from a release commit, run:

```bash
monochange step release-record --from HEAD --format json
monochange step publish-readiness --from HEAD --format json
monochange step publish-packages --dry-run --format json
```
