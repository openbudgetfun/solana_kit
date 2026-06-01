---
title: Release Process
description: End-to-end release guidance for preparing and publishing package releases.
---

## Release Goals

The current release flow is run locally by a maintainer. It separates version preparation from package publication so version bumps, changelogs, and package metadata can be reviewed before anything is published to pub.dev.

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

From a local checkout, create a release branch or PR that applies the pending changesets, updates package versions, and refreshes changelogs. Review the generated package versions and release notes before merging.

Reason: package consumers should see accurate version numbers and user-facing release notes.

### Step 3: Publish Package Artifacts

After the release changes are merged and tagged, publish the changed packages from the release commit on the maintainer machine. Always run a publish dry run first, then publish in dependency order or in small batches when many packages changed.

Reason: phased publishing reduces blast radius and makes it easier to recover if registry limits or package metadata problems appear.

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
- Move publication to Trusted Publishing once registry setup is ready.
