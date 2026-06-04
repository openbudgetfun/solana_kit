# Create a Subscription Authority

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
