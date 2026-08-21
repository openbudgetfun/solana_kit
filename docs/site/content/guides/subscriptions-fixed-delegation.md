# Fixed delegation

<!-- {=docsSubscriptionsFixedDelegationSection} -->

A fixed delegation lets a delegatee pull up to a fixed token amount. Each successful transfer reduces the remaining allowance. Use `expiryTs: BigInt.zero` for no expiry.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

Future<void> main() async {
  const subscriptionAuthority = Address('11111111111111111111111111111112');
  const delegator = Address('11111111111111111111111111111113');
  const delegatee = Address('11111111111111111111111111111114');

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

  print(instruction.accounts!.length);
}
```

The delegator signs setup and revoke transactions. The delegatee signs transfer transactions built with `getTransferFixedInstruction`.

<!-- {/docsSubscriptionsFixedDelegationSection} -->
