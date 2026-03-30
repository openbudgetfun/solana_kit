# Dart-First Solana Kit Roadmap

_Date: 2026-03-30_

## North Star

Make Solana Kit a **Dart/Flutter product with a strict compatibility core**:

- preserve behavioral and wire-format compatibility with `@solana/kit`
- prefer Dart-first APIs, docs, and defaults for application developers
- make Flutter a real first-class integration story
- treat Android-only Mobile Wallet Adapter support as an ecosystem constraint, not a product omission

## Decisions Locked In

- **Identity:** Dart/Flutter product with strict compatibility core.
- **API strategy:** layered surfaces.
  - parity/core layer
  - Dart-first ergonomic layer
  - Flutter integration layer
- **Compatibility strategy:** preserve upstream quirks in compatibility paths, but add stricter Dart-first behavior where safety/usability warrants it.
- **Flutter strategy:** real Android-first support, explicit iOS stub/no-op because Solana MWA does not currently provide an iOS wallet-handoff ecosystem.
- **Testing strategy:** prioritize parity confidence, security/transport correctness, and app-facing behavior over vanity line coverage.
- **Documentation strategy:** teach the preferred Dart path first; document parity and escape hatches second.

## Phase 0 — Baseline policy, docs, and issue structure

### Outcomes

- security and platform constraints are documented clearly
- roadmap is broken into executable issues
- old overlapping issues can later be closed as superseded or addressed

### Files

- `SECURITY.md`
- `readme.md`
- `docs/site/content/guides/mobile-wallet-adapter.md`
- `docs/plans/2026-03-30-dart-first-roadmap.md`

### Tests / validation

- `docs:check`
- `fix:all`

### Docs changes

- explain Android-only MWA support clearly
- explain why iOS is a stub/no-op
- document security posture and reporting expectations

## Phase 1 — Security and transport hardening

### Outcomes

- baseline security policy is enforceable
- transport hardening is shared consistently
- risky compatibility behavior is documented and isolated

### Issue A: Security baseline and CI dependency auditing

#### Primary files

- `SECURITY.md`
- `.github/workflows/ci.yml`
- `docs/site/content/contributing.md`
- `docs/site/content/core/errors-and-diagnostics.md`
- `docs/site/content/guides/mobile-wallet-adapter.md`

#### Changes

- add dependency audit checks to CI
- document production guidance for insecure transport flags
- document key-material lifecycle constraints and logging guidance

#### Tests

- CI job validation
- doc drift checks

### Issue B: Harden transport and WebSocket implementations

#### Primary files

- `packages/solana_kit_rpc_transport_http/lib/src/http_transport.dart`
- `packages/solana_kit_rpc_subscriptions_channel_websocket/lib/src/websocket_channel.dart`
- `packages/solana_kit_helius/lib/src/websockets/helius_websocket.dart`
- `packages/solana_kit_rpc_subscriptions/lib/src/rpc_subscriptions.dart`
- relevant transport/websocket tests in each package

#### Changes

- unify URL validation and connection lifecycle expectations
- reduce duplicated WebSocket behavior between shared transport and Helius transport
- add stronger lifecycle/error-path coverage
- evaluate optional certificate pinning hooks or transport extension points

#### Tests

- connection failure paths
- abort/close semantics
- unexpected payload/error propagation
- Helius-specific subscription lifecycle tests

### Issue C: Split strict-vs-compat decoding behavior

#### Primary files

- `packages/solana_kit_codecs_strings/lib/src/utf8.dart`
- `packages/solana_kit_codecs_strings/README.md`
- `docs/site/content/core/codecs.md`
- new tests under `packages/solana_kit_codecs_strings/test/`

#### Changes

- keep TS-compatible null-stripping behavior available
- introduce a strict Dart-first decoder/codec path that rejects or reports null-byte content
- document when to use compatibility vs strict mode

#### Tests

- strict rejection cases
- compatibility preservation cases
- docs/examples covering both modes

## Phase 2 — Dart-first ergonomic API layer

### Outcomes

- app-facing code stops leaking raw map/dynamic patterns where a typed layer exists
- subscription APIs are as discoverable as request APIs
- account and transaction flows become easier to use from Dart and Flutter apps

### Issue D: Typed account client and hot RPC response wrappers

#### Primary files

- `packages/solana_kit_accounts/lib/src/fetch_account.dart`
- `packages/solana_kit_rpc/lib/src/rpc_methods.dart`
- `packages/solana_kit_rpc_api/lib/src/get_account_info.dart`
- `packages/solana_kit_rpc_api/lib/src/get_latest_blockhash.dart`
- `packages/solana_kit_rpc_api/lib/src/get_signature_statuses.dart`
- `packages/solana_kit_rpc_types/lib/src/`
- `packages/solana_kit/lib/solana_kit.dart`
- docs under `docs/site/content/getting-started/` and `docs/site/content/core/`

#### Changes

- refactor account helpers to use typed RPC entry points
- add typed wrappers/models for hot response shapes used in examples and app flows
- reduce direct `Map<String, dynamic>` peeling in helper APIs
- teach wrapped response usage in docs/examples

#### Tests

- account helper regression tests
- params/response mapping tests
- behavior parity tests for wrapped vs raw flows

### Issue E: Typed subscriptions API and stream ergonomics

#### Primary files

- `packages/solana_kit_rpc_subscriptions/lib/src/rpc_subscriptions.dart`
- `packages/solana_kit_rpc_subscriptions_api/lib/src/*.dart`
- `packages/solana_kit_subscribable/lib/src/data_publisher.dart`
- docs in `docs/site/content/core/rpc-and-subscriptions.md`
- new tests in `packages/solana_kit_rpc_subscriptions/test/`

#### Changes

- add typed subscription methods alongside string-based request escape hatches
- prefer typed method discovery in docs
- improve stream ergonomics and reduce magic-string usage at the application boundary
- evaluate whether `DataPublisher` should remain internal plumbing rather than the primary public mental model

#### Tests

- typed subscription method coverage
- stream cancellation and coalescing behavior
- parity with current request-based API

### Issue F: Transaction/account app-boundary deepening

#### Primary files

- `packages/solana_kit_transaction_messages/lib/src/`
- `packages/solana_kit_transactions/lib/src/`
- `packages/solana_kit_signers/lib/src/`
- `packages/solana_kit_accounts/lib/src/`
- `packages/solana_kit_instruction_plans/lib/src/`

#### Changes

- deepen app-facing execution boundaries around planning/signing/sending
- preserve existing low-level surfaces while improving default composition paths
- keep fluent immutable APIs as the preferred Dart path

#### Tests

- end-to-end transaction assembly/signing flows
- signer ordering and failure-path tests
- higher-level boundary tests over internal implementation tests

## Phase 3 — Make Flutter real

### Outcomes

- Flutter developers get first-class examples and architecture guidance
- Android-only MWA support is explicit and ergonomic
- shared app code has clear unsupported-platform strategies for iOS

### Issue G: Flutter integration examples and app architecture

#### Primary files

- `packages/solana_kit_mobile_wallet_adapter/example/`
- new example app/docs locations as needed
- `docs/site/content/guides/mobile-wallet-adapter.md`
- new docs such as:
  - `docs/site/content/guides/build-flutter-wallet-client.md`
  - `docs/site/content/guides/build-flutter-transaction-flow.md`

#### Changes

- create richer example applications, not just manual protocol demos
- show state management/service boundaries for wallet session state, transaction submission, and platform support gating
- include Android-first UX and iOS fallback UX
- document when to use protocol-only vs Flutter plugin layers

#### Tests

- widget/service tests for example app state boundaries
- manual device validation checklist for Android wallet handoff
- doc snippet coverage where practical

### Issue H: Evaluate optional Flutter integration package

#### Primary files

- possible new package such as `packages/solana_kit_flutter/`
- or strengthened example/support layer if a package is premature
- docs in `docs/site/content/guides/`

#### Changes

- decide whether to ship a reusable Flutter integration layer or keep it as examples first
- if shipped, keep it optional and framework-friendly
- avoid leaking Flutter concerns into core parity packages

#### Tests

- package-level unit/widget tests if introduced
- example-based validation if examples-first

## Phase 4 — Parity and testing confidence

### Outcomes

- compatibility claims are backed by executable parity checks
- coverage is enforced by risk-weighted package thresholds
- shared fixtures reduce drift and repetitive setup

### Issue I: Upstream parity harness against `@solana/kit`

#### Primary files

- `.repos/kit` usage via scripts/tests
- `scripts/check-upstream-compatibility.sh`
- new parity test locations under selected packages
- docs in `docs/site/content/reference/upstream-compatibility.md`

#### Changes

- move from metadata-only compatibility checks to behavior checks
- add fixture-driven parity tests for wire formats, validation semantics, and known quirks
- document exact parity scope and intentional divergence points

#### Tests

- address/signature/blockhash validation parity
- codec parity
- transaction/message compilation parity
- compatibility-path behavior tests

### Issue J: Shared fixtures and risk-based coverage gates

#### Primary files

- `packages/solana_kit_test_matchers/lib/src/`
- new shared fixture helpers under appropriate test support locations
- `.github/workflows/ci.yml`
- `devenv.nix`
- docs in `docs/site/content/contributing.md`

#### Changes

- expand shared test builders/fixtures for RPC, accounts, signers, transactions, and Helius
- enforce package-level coverage floors by risk tier
- report coverage expectations in contributing docs

#### Tests

- fixture self-tests
- CI threshold checks
- representative adoption in low-coverage packages

## Phase 5 — MDT and documentation as product infrastructure

### Outcomes

- docs teach the preferred Dart path first
- parity and security constraints are visible everywhere they matter
- documentation blocks become more reusable and more opinionated

### Issue K: Expand MDT blocks for preferred APIs, parity notes, and security notes

#### Primary files

- `template.t.md`
- `mdt.toml`
- `scripts/sync-dart-doc-comments.py`
- root `readme.md`
- `docs/site/content/core/*.md`
- package READMEs where later changes are worth a changeset

#### Changes

- add reusable blocks for:
  - preferred Dart path
  - compatibility/path caveats
  - security notes
  - Android-only MWA support notes
  - parity status callouts
- strengthen doc snippet coverage for new guidance

#### Tests

- `docs:check`
- `test:doc-snippets`
- targeted doc example validation

## Suggested execution order

1. Phase 0
2. Phase 1 Issue A
3. Phase 1 Issue B
4. Phase 2 Issue D
5. Phase 2 Issue E
6. Phase 4 Issue I
7. Phase 4 Issue J
8. Phase 5 Issue K
9. Phase 3 Issue G
10. Phase 3 Issue H
11. Phase 2 Issue F
12. revisit overlapping legacy issues and close/supersede them

## Legacy issue review candidates

These appear related and should be revisited after the new roadmap issues land:

- #83 — higher-level account client
- #84 — Helius contract/session testing
- #87 — coverage floor
- #88 — shared fixtures
- #89 — upstream compatibility drift tracking

## Definition of done for the roadmap

The roadmap is complete when:

- Dart-first docs no longer teach raw dynamic access as the primary path
- compatibility claims are backed by behavioral parity tests
- transport and MWA security expectations are documented and tested
- Flutter developers have real Android-first examples and explicit iOS fallback guidance
- package-level coverage thresholds are enforced in CI
- old overlapping issues can be closed with confidence
