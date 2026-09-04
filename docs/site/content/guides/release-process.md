---
title: Release Process
description: End-to-end release guidance for preparing and publishing package releases.
---

## Release Goals

The release flow is automated with MonoChange and GitHub Actions. It separates version preparation from package publication so version bumps, changelogs, and package metadata can be reviewed in a release PR before anything is published to pub.dev or NPM.

## Step-by-Step Release Flow

### Step 1: Validate Workspace Health

Run the standard workspace checks before preparing a release:

```bash
lint:all
test:all
docs:check
```

Reason: release quality gates should fail fast before versions or changelogs change.

### Step 2: Prepare Release Changes

Releases are prepared locally. `monochange run release --commit --tag --push` prepares the pending changesets with MonoChange, updates package versions, refreshes changelogs and lockfiles, commits the release, and pushes the MonoChange release tags.

Review the generated package versions and release notes with a dry run before pushing the release.

Reason: package consumers should see accurate version numbers and user-facing release notes.

### Step 3: Publish Package Artifacts

After the release commit and tags are pushed (`monochange run release --commit --tag --push`), the primary `v*` tag triggers the `publish` workflow. The run verifies publish readiness, publishes the primary group's packages, dispatches an awaited child run per independently versioned release tag in dependency order, and then publishes GitHub release objects.

Reason: CI-owned publishing keeps the reviewed release commit, direct release tags, package artifacts, and GitHub releases tied to the same MonoChange release record, while respecting pub.dev's requirement that each package publishes from a tag matching its own version.

### Step 4: Validate Published Artifacts

- Verify package metadata on pub.dev.
- Confirm each published package resolves from a clean consumer project.
- Smoke test critical quick-start paths.

Reason: publishing success alone does not guarantee downstream usability.

## Operational Guidance

- Keep release cadence predictable.
- Batch breaking changes with migration notes.
- Document user-visible changes and minimum SDK changes clearly.
- Verify the umbrella package resolves after publishing dependent packages.
- Keep pub.dev Trusted Publishing configuration aligned with `.github/workflows/publish.yml`: per-package tag patterns (`v{{version}}` for primary group packages, `<name>/v{{version}}` for independently versioned packages), the `publisher` environment, and `workflow_dispatch` events allowed.
