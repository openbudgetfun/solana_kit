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

## 0.0.0

Placeholder publication.
