# Changesets and releases

## Changesets

- Never delete files in `.changeset/`; they are release inputs.
- Any PR that changes files under `packages/*` must include a `.changeset/*.md` file.
- Use monochange package ids from `monochange.toml` in changeset frontmatter.
- For changes that affect the lockstep Dart group, listing affected package ids is enough; monochange propagates the selected bump through `group.main`.
- Dependents of `group.main` packages (packages outside the group that depend on a member) inherit the group's release severity through `bump_propagation`, clamped at `major` (pre-stable shifting applies for `0.x` versions). The legacy `parent_bump = "patch"` floor applies only where no declaration matches.
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

Releases are driven locally: `monochange run release --commit --tag --push` prepares version bumps, changelogs, lockfiles, docs, and a MonoChange release commit, then pushes the MonoChange release tags (the primary `v*` tag for `group.main` and scoped `<id>/v*` tags for independently versioned targets).

The primary `v*` tag push triggers `.github/workflows/publish.yml`. That run verifies readiness, publishes the primary group's packages, dispatches an awaited `workflow_dispatch` child run for every other tagged release target in dependency order, and then publishes GitHub release objects. pub.dev Trusted Publishing requires each package to publish from a tag matching its own version, which is why each version group publishes from its own release tag.

For local verification from a release commit, run:

```bash
monochange step release-record --from HEAD --format json
monochange step publish-readiness --from HEAD --format json
monochange step publish-packages --dry-run --format json
```
