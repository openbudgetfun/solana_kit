# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_subscriptions [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_subscriptions/v0.1.0) (2026-08-12)

### 💥 Breaking Change

#### Add Subscriptions program client

Adds a generated Subscriptions program client pinned to `solana-foundation/subscriptions` `ts-client-v0.3.0`, including account, instruction, PDA, type, and error helpers.

Also exposes the canonical Subscriptions program address from `solana_kit_address_constants`.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

Future<void> main() async {
  const user = Address('11111111111111111111111111111112');
  const tokenMint = Address('So11111111111111111111111111111111111111112');

  final (authority, bump) = await findSubscriptionAuthorityPda(
    programAddress: subscriptionsProgramAddress,
    seeds: SubscriptionAuthoritySeeds(user: user, tokenMint: tokenMint),
  );

  print('authority=$authority bump=$bump');
}
```

Build typed instructions for fixed and recurring delegations.

```dart
final instruction = getCreateFixedDelegationInstruction(
  programAddress: subscriptionsProgramAddress,
  delegator: delegator,
  subscriptionAuthority: subscriptionAuthority,
  delegationAccount: delegationAccount,
  delegatee: delegatee,
  systemProgram: systemProgram,
  fixedDelegation: CreateFixedDelegationData(
    nonce: BigInt.from(1),
    amount: BigInt.from(1_000_000),
    expiryTs: BigInt.zero,
    expectedSubscriptionAuthorityInitId: BigInt.zero,
  ),
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #187](https://github.com/openbudgetfun/solana_kit/pull/187)

### 🚀 Feature

#### Subscriptions: regenerate from ts-client-v0.4.0-rc.2

Regenerates the Subscriptions generated code from upstream IDL `ts-client-v0.4.0-rc.2` (was `ts-client-v0.3.0`). Adds 3 new instructions:

- `revokeSubscriptionAuthority`
- `revokeAbandonedDelegation`
- `revokeAbandonedSubscription`

Adds 4 new errors: `transferHookTooManyAccounts`, `invalidSelfProgram`, `planEndTsCannotExtend`, `recurringDelegationStartOnLandingRequiresExpiry`.

Updates existing instructions with new required/optional accounts (`payer`, `receiver`, `subscriptionAuthority`, `eventAuthority`, `selfProgram`) and PDA-based `eventAuthority` defaults.

Also fixes three latent renderer bugs in `codama-renderers-dart`: empty struct constructors, PDA seed import merging, and BigInt import attribution.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #195](https://github.com/openbudgetfun/solana_kit/pull/195)

### 📖 Documentation

#### Point package README website badges at package docs

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## solana_kit_subscriptions [0.1.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_subscriptions/v0.1.1) (2026-08-18)

### 🚀 Feature

#### Regenerate solana_kit_subscriptions from the v0.5.0 IDL

Regenerated `solana_kit_subscriptions` from the `solana-foundation/subscriptions` `ts-client-v0.5.0` Codama IDL, bringing the generated Dart surface in sync with the pinned reference (`ts-client-v0.4.0-rc.2` → `ts-client-v0.5.0`).

Notable additions and changes:

- New `cancelSubscriptionNow` instruction (discriminator 17) with `CancelSubscriptionNowData` (`expectedCurrentPeriodStartTs`).
- `resumeSubscription` now takes a required `resumeData: ResumeData` struct (`expectedExpiresAtTs`).
- `UpdatePlanData` gained four required fields: `expectedCreatedAt`, `expectedEndTs`, `expectedPullers`, and `expectedMetadataUri`.
- `getCreatePlanInstruction` accepts an optional `payer` account.
- Generated program-level instruction identification and parsing helpers (`SubscriptionsInstruction` enum, `identifySubscriptionsInstruction`, `parseSubscriptionsInstruction`) and new error codes.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #204](https://github.com/openbudgetfun/solana_kit/pull/204)

## solana_kit_subscriptions [0.1.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_subscriptions/v0.1.2) (2026-08-19)

### Changed

- No package-specific changes were recorded; `solana_kit_subscriptions` was updated to 0.1.2.

## solana_kit_subscriptions [0.2.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_subscriptions/v0.2.0) (2026-08-30)

### 📖 Documentation

#### Unslop package docs and code comments

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## solana_kit_subscriptions [0.2.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_subscriptions/v0.2.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_subscriptions` was updated to 0.2.1.

## solana_kit_subscriptions [0.2.2](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_subscriptions/v0.2.2) (2026-09-06)

### Changed

- No package-specific changes were recorded; `solana_kit_subscriptions` was updated to 0.2.2.

## solana_kit_subscriptions [0.2.3](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_subscriptions/v0.2.3) (2026-09-12)

### Fixes

- **Document program errors and the generated program-client contract.** Add library doc comments synchronized from shared MDT sections to thirteen packages: program error matching (`isProgramError` + `TransactionMessageInput`) and the generated program-client API shape are now documented inline in each library and in the errors docs page; six barrels that had no library doc comment gain one; three one-line library headers are expanded. No code changes. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #248](https://github.com/openbudgetfun/solana_kit/pull/248)

## solana_kit_subscriptions [0.3.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_subscriptions/v0.3.0) (2026-09-21)

### Breaking changes

#### Raise the Dart and Flutter baseline

The workspace now builds against Dart 3.13.3 and Flutter 3.47.4, and every package declares that floor instead of the previous Dart 3.12 range. Consumers on older SDKs can no longer resolve these packages, so this release is breaking even though no Dart API changed.

The Flutter floor rises from 3.44 to 3.47 for `solana_kit_mobile_wallet_adapter`, `solana_kit_mobile_wallet_adapter_protocol`, and `solana_kit_wallet_adapter`, matching the floor `solana_kit_wallet_ui` already required. `solana_kit_lints` ships the raised floor to consumers, so it carries the same breaking bump. Every other package raises only the Dart SDK floor.

Raising the language version also switches `dart format` to the tall style, so 83 files across library, test, script, and Codama-generated trees are reflowed. The renderer pipes generated output through `dart format`, so regenerating stays consistent.

Align your own SDK constraint with the workspace:

```yaml
environment:
  sdk: ^3.13.0
  # Omit for pure Dart packages; required for the Flutter packages above.
  flutter: ">=3.47.0"
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [5f5fe01](https://github.com/openbudgetfun/solana_kit/commit/5f5fe01f3e2220ccfee54cc26e82c3face26589d) · _Last updated in:_ [19932db](https://github.com/openbudgetfun/solana_kit/commit/19932dba1979f1190b7501947b87eb8a4d4cc8d5)

## solana_kit_subscriptions [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_subscriptions/v0.4.0) (2026-10-12)

### Fixes

- **Monostyle style pass.** Blank-line breathing room around control flow and returns, group splits, and collapsed blank runs, applied by `monostyle fix` and kept where dprint puts them. No behavior change: the renderers' emitted code and every package's API are untouched. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #283](https://github.com/openbudgetfun/solana_kit/pull/283)

### Documentation

#### Publish a per-package upstream support table in each package README

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #285](https://github.com/openbudgetfun/solana_kit/pull/285) · _Related issues:_ [#223](https://github.com/openbudgetfun/solana_kit/issues/223), [#284](https://github.com/openbudgetfun/solana_kit/issues/284)

Every package that ports something outside `@solana/kit` now documents which upstream revision each of its releases was generated and verified against, so a reader can pick the Dart version that matches the upstream program version they target.

```markdown
| `solana_kit_system` version | `system`     | Released                |
| --------------------------- | ------------ | ----------------------- |
| _next release_              | `js@v0.15.0` | _unreleased_            |
| `0.7.2` – `0.8.0`           | `js@v0.14.1` | 2026-09-06 – 2026-09-21 |
| `0.7.0` – `0.7.1`           | `js@v0.14.0` | 2026-08-30              |
```

**One row per upstream revision, not per release.** Consecutive releases that were generated against the same upstream ref collapse into a single `0.7.2` – `0.8.0` range, so a package that shipped several patches against one upstream tag reports one row instead of burying the mapping in repetition. Packages whose releases moved with the umbrella `solana_kit` version (the lockstep group members) are keyed by that version and label the column accordingly.

The leading `_next release_` row shows the pin the working tree is currently generated against, so the mapping for unreleased work is visible before the release tooling assigns a version.

Tables are generated, not hand-written. `scripts/sync_package_upstream_support.dart` reads `config/reference-repos.json` at every `"<package>/v<version>"` release tag, collapses the ranges, and writes `config/package-upstream-support.json`; `scripts/generate_upstream_docs.dart` renders that into each README between `upstream-support` markers. Both run through `docs:update`, so the tables refresh alongside the other generated docs. The history is committed rather than derived at check time because CI checks out shallowly and would see no tags.

No package code changes; this is documentation only.

## 0.0.0

Placeholder publication.
