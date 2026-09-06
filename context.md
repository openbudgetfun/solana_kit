## Summary

**PR #242 is merged** ✅ — squash commit `1859cd9e` on `main` of `openbudgetfun/solana_kit`.

### Initial status

- `state=OPEN`, `mergeable=MERGEABLE`, `mergeStateStatus=BEHIND`
- Required check **`test` was failing**; `lint` and all other jobs passed; `coverage` still pending

### Two failing checks investigated and fixed (pushed to the PR branch)

1. **`e78b7b22` — missing export**: root `test/markdown_snippets_test.dart` failed because the README's usage example and Key APIs table call `createPortalWorkflowClient`/`createPortalAttestationClient`, but `lib/solana_kit_dapp_publisher_cli.dart` didn't export `src/portal_workflow_client.dart` → two `undefined_function` analyzer errors. **Fix:** added the one-line export. Verified locally (snippet test, `dart analyze` clean, 260/260 package tests).

2. **`61c0bdfe` — manifest registration**: after merging main, PR #243's new `test/surfpool_compatibility_manifest_test.dart` required every workspace package to appear in `config/surfpool-compatibility.json`; the new package was missing. **Fix:** added it to the "hosted API contracts" lane (it's a hosted-HTTP portal client like Helius/Jupiter) with its test suite as evidence, and updated `docs/agents/surfpool-compatibility.md`. Full workspace `test:all` passes locally.

### Merge process

- Branch protection requires up-to-date branches → ran `gh pr update-branch` as main moved twice mid-review; each update re-triggered CI (~7 min).
- Final head `61c0bdfe`: required `test` and `lint` both **SUCCESS**. `mergeStateStatus=UNSTABLE` (only non-required `codecov/patch` and pending `coverage-flags` jobs) — doesn't block merging.
- Merged with the exact squash subject from the task. No PR content (title/description) was modified; no new changesets needed (the existing `.changeset/dapp-publisher-cli.md` covers the unpublished package).

Findings written to `context.md`; the investigation worktree was removed after the merge.
