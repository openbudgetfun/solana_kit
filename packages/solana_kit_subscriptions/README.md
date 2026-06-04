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

## Concepts and usage

<!-- {=docsSubscriptionsOverviewSection} -->

The Subscriptions Delegation Program lets users authorize future SPL Token or Token-2022 transfers with explicit limits. In Dart, use `solana_kit_subscriptions` for generated PDAs, account decoders, and instruction builders.

Each `(user, token mint)` pair gets a program-controlled **Subscription Authority**. The user's token account approves that authority once. The program then checks every requested pull against an active authorization record.

| Model                | Use                                                                                  |
| -------------------- | ------------------------------------------------------------------------------------ |
| Fixed delegation     | Let a delegatee spend up to one total allowance, optionally with an expiry.          |
| Recurring delegation | Let a delegatee spend up to a limit that resets each period.                         |
| Subscription plan    | Let a merchant publish terms that subscribers accept and approved collectors charge. |

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

Amounts are token base units. For a 6-decimal token, `1_000_000` means `1` token.

<!-- {/docsSubscriptionsOverviewSection} -->

<!-- {=docsSubscriptionsAuthoritySection} -->

Create a Subscription Authority once per `(user, token mint)` pair. The user's associated token account must exist first. Build the instruction with `getInitSubscriptionAuthorityInstruction`, add it to a transaction, and sign with the owner.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

Future<void> main() async {
  const owner = Address('11111111111111111111111111111112');
  const tokenMint = Address('So11111111111111111111111111111111111111112');
  const userAta = Address('11111111111111111111111111111113');
  const systemProgram = Address('11111111111111111111111111111111');
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  final (subscriptionAuthority, _) = await findSubscriptionAuthorityPda(
    programAddress: subscriptionsProgramAddress,
    seeds: SubscriptionAuthoritySeeds(user: owner, tokenMint: tokenMint),
  );

  final instruction = getInitSubscriptionAuthorityInstruction(
    programAddress: subscriptionsProgramAddress,
    owner: owner,
    subscriptionAuthority: subscriptionAuthority,
    tokenMint: tokenMint,
    userAta: userAta,
    systemProgram: systemProgram,
    tokenProgram: tokenProgram,
  );

  print(instruction.accounts.length);
}
```

Fetch and decode `SubscriptionAuthority` before creating it when your app may have initialized the authority already.

<!-- {/docsSubscriptionsAuthoritySection} -->

<!-- {=docsSubscriptionsFixedDelegationSection} -->

A fixed delegation lets a delegatee pull up to a fixed token amount. Each successful transfer reduces the remaining allowance. Use `expiryTs: BigInt.zero` for no expiry.

```dart
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
  systemProgram: systemProgramAddress,
  fixedDelegation: CreateFixedDelegationData(
    nonce: BigInt.from(1),
    amount: BigInt.from(1_000_000),
    expiryTs: BigInt.zero,
    expectedSubscriptionAuthorityInitId: BigInt.zero,
  ),
);
```

The delegator signs setup and revoke transactions. The delegatee signs transfer transactions built with `getTransferFixedInstruction`.

<!-- {/docsSubscriptionsFixedDelegationSection} -->

<!-- {=docsSubscriptionsRecurringDelegationSection} -->

A recurring delegation lets a delegatee pull up to a token limit that resets every period. The program rejects transfers that exceed the current period's remaining allowance.

```dart
final instruction = getCreateRecurringDelegationInstruction(
  programAddress: subscriptionsProgramAddress,
  delegator: delegator,
  subscriptionAuthority: subscriptionAuthority,
  delegationAccount: delegationAccount,
  delegatee: delegatee,
  systemProgram: systemProgramAddress,
  recurringDelegation: CreateRecurringDelegationData(
    nonce: BigInt.from(7),
    amountPerPeriod: BigInt.from(5_000_000),
    periodLengthS: BigInt.from(30 * 24 * 60 * 60),
    startTs: BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000),
    expiryTs: BigInt.zero,
    expectedSubscriptionAuthorityInitId: BigInt.zero,
  ),
);
```

Use `getTransferRecurringInstruction` for collection. It updates the recurring delegation account so the remaining allowance and billing window stay consistent on-chain.

<!-- {/docsSubscriptionsRecurringDelegationSection} -->

<!-- {=docsSubscriptionsPlanSection} -->

Subscription plans let a merchant publish reusable terms. A subscriber accepts a plan with `getSubscribeInstruction`, which creates a subscription delegation account tied to the accepted terms.

```dart
const emptyAddress = Address('11111111111111111111111111111111');

final createPlanInstruction = getCreatePlanInstruction(
  programAddress: subscriptionsProgramAddress,
  merchant: merchant,
  planPda: planPda,
  tokenMint: tokenMint,
  systemProgram: systemProgramAddress,
  tokenProgram: tokenProgramAddress,
  planData: PlanData(
    planId: BigInt.from(1),
    mint: tokenMint,
    terms: PlanTerms(
      amount: BigInt.from(5_000_000),
      periodHours: BigInt.from(24 * 30),
      createdAt: BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000),
    ),
    endTs: BigInt.zero,
    destinations: const [emptyAddress, emptyAddress, emptyAddress, emptyAddress],
    pullers: const [emptyAddress, emptyAddress, emptyAddress, emptyAddress],
    metadataUri: 'https://example.com/subscription-plan.json',
  ),
);
```

After the plan exists, derive the subscription delegation PDA and call `getSubscribeInstruction`. Use `getTransferSubscriptionInstruction` for billing, `getCancelSubscriptionInstruction` for subscriber cancellation, and `getResumeSubscriptionInstruction` to resume a paused subscription.

<!-- {/docsSubscriptionsPlanSection} -->

### Decode accounts

Generated account decoders parse fetched account data into typed account models.

```dart
final account = decodePlan(encodedAccount);
print(account.data.terms.amount);
```

<!-- {=docsSubscriptionsCloseAuthoritySection} -->

Close the Subscription Authority after all fixed, recurring, and subscription delegations that depend on it have been closed or revoked. Closing returns the authority account rent and removes the program authority for that `(user, token mint)` pair.

```dart
final instruction = getCloseSubscriptionAuthorityInstruction(
  programAddress: subscriptionsProgramAddress,
  user: user,
  subscriptionAuthority: subscriptionAuthority,
);
```

The user signs the transaction. If your app stores derived addresses, recompute the PDA before closing so the instruction targets the canonical authority for the user and mint.

<!-- {/docsSubscriptionsCloseAuthoritySection} -->

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
