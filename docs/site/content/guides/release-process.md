---
title: Release Process
description: End-to-end release guidance and why each stage exists.
---

## Why the Release Pipeline Is Structured

The release flow separates versioning from publication so teams can validate artifacts before package publish.

## Step-by-Step Release Flow

### Step 1: Validate Workspace Health

Run:

```bash
lint:all
test:all
docs:check
```

Reason: release quality gates should fail fast.

### Step 2: Run Dry-Run Release

- trigger `release.yml` with dry-run.

Reason: validates changelog/version logic before state changes.

### Step 3: Execute Release from `main`

- trigger non-dry-run release.

Reason: keeps canonical release history linear and auditable.

### Step 4: Publish in Managed Phases

- run `publish.yml` with intended phase option.

Reason: phased publish reduces blast radius for package clusters.

### Step 5: Validate Published Artifacts

- verify package metadata on pub.dev.
- smoke test critical quick-start paths.

Reason: publishing success alone does not guarantee usability.

## Operational Guidance

- keep release cadence predictable.
- batch breaking changes with migration notes.
- document justified exceptions in release notes.
