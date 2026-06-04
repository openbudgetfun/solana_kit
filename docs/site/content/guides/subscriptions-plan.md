# Subscription plans

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
