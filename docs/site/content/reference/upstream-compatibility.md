---
title: Upstream Compatibility
description: How this workspace tracks @solana/kit compatibility.
---

<!-- {=docsUpstreamCompatibilitySection} -->

## Upstream Compatibility

- Latest supported `@solana/kit` version: `6.5.0`
- This Dart port tracks upstream APIs and behavior through `v6.5.0`.

<!-- {/docsUpstreamCompatibilitySection} -->

## Validation Workflow

- Keep `.repos/kit` updated (`clone:repos`).
- Run `upstream:check` to verify tracked compatibility metadata remains internally consistent.
- Compare API behavior against upstream fixtures/examples.
- Record intentional deviations and migration notes.
- Re-run benchmarks after major upstream alignment changes.

## Versioning Guidance

When upstream introduces breaking API behavior, prefer explicit compatibility notes and migration docs over silent behavior changes.
