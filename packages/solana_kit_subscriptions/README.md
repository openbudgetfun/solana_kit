# solana_kit_subscriptions

[![pub package](https://img.shields.io/pub/v/solana_kit_subscriptions.svg)](https://pub.dev/packages/solana_kit_subscriptions)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_subscriptions/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_subscriptions)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_subscriptions)

Dart client for the Solana Subscriptions Delegation Program.

The package is generated from the upstream `solana-foundation/subscriptions` Codama IDL and exposes typed accounts, instructions, PDAs, errors, and codecs for subscription authorities, fixed delegations, recurring delegations, and subscription-plan flows.

## Upstream Compatibility

- Upstream repository: [`solana-foundation/subscriptions`](https://github.com/solana-foundation/subscriptions)
- Supported upstream baseline: `ts-client-v0.3.0`
- Program address: `De1egAFMkMWZSN5rYXRj9CAdheBamobVNubTsi9avR44`
- IDL source: generated upstream from Codama-annotated Pinocchio Rust code

## Installation

```bash
dart pub add solana_kit_subscriptions
```

Most apps also use packages such as `solana_kit`, `solana_kit_token`, and `solana_kit_associated_token_account` to create signers, derive token accounts, build transactions, and submit them to RPC.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_subscriptions
- API reference: https://pub.dev/documentation/solana_kit_subscriptions/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_subscriptions
- Upstream guide: https://solana.com/docs/payments/subscriptions/overview

## Concepts

The Subscriptions program lets a user approve one program-controlled **Subscription Authority** for a token account. That authority cannot pull funds by itself. Each pull must match an active authorization record:

| Model | Purpose |
| --- | --- |
| Fixed delegation | A delegatee can pull up to a fixed total amount, optionally until an expiry timestamp. |
| Recurring delegation | A delegatee can pull up to a period limit that resets after each billing window. |
| Subscription plan | A merchant publishes terms; subscribers accept them; the merchant or approved pullers collect each period. |

Amounts are always token base units. For a 6-decimal token, `1_000_000` represents `1` token.

## Usage

### Program address and PDAs

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

Future<void> main() async {
  const user = Address('11111111111111111111111111111112');
  const tokenMint = Address('So11111111111111111111111111111111111111112');

  final (subscriptionAuthority, bump) = await findSubscriptionAuthorityPda(
    programAddress: subscriptionsProgramAddress,
    seeds: SubscriptionAuthoritySeeds(user: user, tokenMint: tokenMint),
  );

  print('Subscription authority: $subscriptionAuthority, bump: $bump');
}
```

### Create a Subscription Authority instruction

Create the authority once per `(user, token mint)` pair after the user's associated token account exists.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

void main() {
  const owner = Address('11111111111111111111111111111112');
  const tokenMint = Address('So11111111111111111111111111111111111111112');
  const userAta = Address('11111111111111111111111111111113');
  const subscriptionAuthority = Address('11111111111111111111111111111114');
  const systemProgram = Address('11111111111111111111111111111111');
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  final instruction = getInitSubscriptionAuthorityInstruction(
    programAddress: subscriptionsProgramAddress,
    owner: owner,
    subscriptionAuthority: subscriptionAuthority,
    tokenMint: tokenMint,
    userAta: userAta,
    systemProgram: systemProgram,
    tokenProgram: tokenProgram,
  );

  print(instruction.accounts.length); // 6
}
```

### Fixed delegation

A fixed delegation gives a delegatee a one-time allowance. Successful transfers reduce the remaining allowance. Use `expiryTs: BigInt.zero` for no expiry.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

Future<void> main() async {
  const delegator = Address('11111111111111111111111111111112');
  const delegatee = Address('11111111111111111111111111111113');
  const subscriptionAuthority = Address('11111111111111111111111111111114');
  const systemProgram = Address('11111111111111111111111111111111');

  final (delegationAccount, _) = await findFixedDelegationPda(
    programAddress: subscriptionsProgramAddress,
    seeds: FixedDelegationSeeds(
      subscriptionAuthority: subscriptionAuthority,
      delegator: delegator,
      delegatee: delegatee,
      nonce: BigInt.from(1),
    ),
  );

  final instruction = getCreateFixedDelegationInstruction(
    programAddress: subscriptionsProgramAddress,
    delegator: delegator,
    subscriptionAuthority: subscriptionAuthority,
    delegationAccount: delegationAccount,
    delegatee: delegatee,
    systemProgram: systemProgram,
    fixedDelegation: CreateFixedDelegationData(
      amount: BigInt.from(1_000_000),
      expiryTs: BigInt.zero,
      expectedSubscriptionAuthorityInitId: BigInt.zero,
      nonce: BigInt.from(1),
    ),
  );

  print(instruction.data?.length);
}
```

### Recurring delegation

A recurring delegation gives a delegatee an allowance that resets every period.

```dart
final instruction = getCreateRecurringDelegationInstruction(
  programAddress: subscriptionsProgramAddress,
  delegator: delegator,
  subscriptionAuthority: subscriptionAuthority,
  delegationAccount: delegationAccount,
  delegatee: delegatee,
  systemProgram: systemProgram,
  recurringDelegation: CreateRecurringDelegationData(
    amountPerPeriod: BigInt.from(5_000_000),
    periodLengthS: BigInt.from(30 * 24 * 60 * 60),
    startTs: BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000),
    expiryTs: BigInt.zero,
    expectedSubscriptionAuthorityInitId: BigInt.zero,
    nonce: BigInt.from(7),
  ),
);
```

### Subscription plans

Merchants use plans for reusable billing terms. A subscriber accepts the current plan terms, creating a subscription delegation PDA. Existing subscribers keep the terms they accepted when the merchant later updates mutable plan fields.

```dart
final instruction = getCreatePlanInstruction(
  programAddress: subscriptionsProgramAddress,
  merchant: merchant,
  planPda: planPda,
  tokenMint: tokenMint,
  systemProgram: systemProgram,
  tokenProgram: tokenProgram,
  planData: PlanData(
    planId: BigInt.from(1),
    mint: tokenMint,
    terms: PlanTerms(
      amount: BigInt.from(5_000_000),
      periodHours: BigInt.from(24 * 30),
      createdAt: BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000),
    ),
    endTs: BigInt.zero,
    destinations: const [
      Address('11111111111111111111111111111111'),
      Address('11111111111111111111111111111111'),
      Address('11111111111111111111111111111111'),
      Address('11111111111111111111111111111111'),
    ],
    pullers: const [
      Address('11111111111111111111111111111111'),
      Address('11111111111111111111111111111111'),
      Address('11111111111111111111111111111111'),
      Address('11111111111111111111111111111111'),
    ],
    metadataUri: 'https://example.com/plan.json',
  ),
);
```

### Decode accounts

Generated account decoders parse fetched account data into typed account models.

```dart
final account = decodePlan(encodedAccount);
print(account.data.terms.amount);
```

### Close a Subscription Authority

Close the Subscription Authority only after closing fixed, recurring, and subscription delegation PDAs that depend on it. The close instruction revokes the program-owned token delegate approval and returns rent to the recorded payer or provided receiver.

```dart
final instruction = getCloseSubscriptionAuthorityInstruction(
  programAddress: subscriptionsProgramAddress,
  user: owner,
  subscriptionAuthority: subscriptionAuthority,
);
```

## Key APIs

- `subscriptionsProgramAddress`
- `findSubscriptionAuthorityPda`
- `findFixedDelegationPda`
- `findRecurringDelegationPda`
- `findPlanPda`
- `findSubscriptionDelegationPda`
- `getInitSubscriptionAuthorityInstruction`
- `getCreateFixedDelegationInstruction`
- `getCreateRecurringDelegationInstruction`
- `getCreatePlanInstruction`
- `getSubscribeInstruction`
- `getTransferFixedInstruction`
- `getTransferRecurringInstruction`
- `getTransferSubscriptionInstruction`
- `getCancelSubscriptionInstruction`
- `getResumeSubscriptionInstruction`
- `getCloseSubscriptionAuthorityInstruction`
- `decodeSubscriptionAuthority`, `decodeFixedDelegation`, `decodeRecurringDelegation`, `decodePlan`, `decodeSubscriptionDelegation`

## Testing and coverage

The package includes parity-style generated surface tests for account codecs, instruction builders/parsers, PDA derivation, error lookup, and value-object paths. The package is tracked by the `solana_kit_subscriptions` Codecov flag.
