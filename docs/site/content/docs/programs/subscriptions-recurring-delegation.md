# Recurring delegation

<!-- {=docsSubscriptionsRecurringDelegationSection} -->

A recurring delegation lets a delegatee pull up to a token limit that resets every period. The program rejects transfers that exceed the current period's remaining allowance.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

Future<void> main() async {
  const subscriptionAuthority = Address('11111111111111111111111111111112');
  const delegator = Address('11111111111111111111111111111113');
  const delegatee = Address('11111111111111111111111111111114');
  const delegationAccount = Address('11111111111111111111111111111115');

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

  print(instruction.accounts!.length);
}
```

Use `getTransferRecurringInstruction` for collection. It updates the recurring delegation account so the remaining allowance and billing window stay consistent on-chain.

<!-- {/docsSubscriptionsRecurringDelegationSection} -->
