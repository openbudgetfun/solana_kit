# Recurring delegation

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
