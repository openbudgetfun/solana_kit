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
- Run `upstream:parity` to install the tracked `@solana/kit` release in a local cache, generate runtime fixtures, and compare selected Dart behaviors against upstream.
- Record intentional deviations and migration notes.
- Re-run benchmarks after major upstream alignment changes.

## Current Executable Parity Scope

The first harness focuses on stable, high-signal surfaces that are cheap to run in CI:

- address validation and coercion semantics
- address encoding and derivation helpers
- signature validation/coercion semantics
- transaction message compilation and wire serialization
- error-code parity for selected invalid inputs

The harness intentionally does **not** yet cover live RPC behavior, subscription transport timing, mobile-wallet platform adapters, Helius-specific extensions, or stricter Dart-only transaction-construction invariants such as requiring an explicit lifetime before compilation. Those remain tracked separately in the roadmap and issue set.

## Versioning Guidance

When upstream introduces breaking API behavior, prefer explicit compatibility notes and migration docs over silent behavior changes.
