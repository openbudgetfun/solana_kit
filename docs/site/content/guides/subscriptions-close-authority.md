# Close a Subscription Authority

<!-- {=docsSubscriptionsCloseAuthoritySection} -->

Close the Subscription Authority after all fixed, recurring, and subscription delegations that depend on it have been closed or revoked. Closing returns the authority account rent and removes the program authority for that `(user, token mint)` pair.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

void main() {
  const user = Address('11111111111111111111111111111112');
  const subscriptionAuthority = Address('11111111111111111111111111111113');

  final instruction = getCloseSubscriptionAuthorityInstruction(
    programAddress: subscriptionsProgramAddress,
    user: user,
    subscriptionAuthority: subscriptionAuthority,
  );

  print(instruction.accounts!.length);
}
```

The user signs the transaction. If your app stores derived addresses, recompute the PDA before closing so the instruction targets the canonical authority for the user and mint.

<!-- {/docsSubscriptionsCloseAuthoritySection} -->
