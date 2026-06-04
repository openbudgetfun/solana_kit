# Close a Subscription Authority

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
