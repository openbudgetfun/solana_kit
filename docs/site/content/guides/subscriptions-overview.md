# Subscriptions overview

<!-- {=docsSubscriptionsOverviewSection} -->

The Subscriptions Delegation Program lets users authorize future SPL Token or Token-2022 transfers with explicit limits. In Dart, use `solana_kit_subscriptions` for generated PDAs, account decoders, and instruction builders.

Each `(user, token mint)` pair gets a program-controlled **Subscription Authority**. The user's token account approves that authority once. The program then checks every requested pull against an active authorization record.

| Model | Use |
| --- | --- |
| Fixed delegation | Let a delegatee spend up to one total allowance, optionally with an expiry. |
| Recurring delegation | Let a delegatee spend up to a limit that resets each period. |
| Subscription plan | Let a merchant publish terms that subscribers accept and approved collectors charge. |

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
