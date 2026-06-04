# Fixed delegation

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
