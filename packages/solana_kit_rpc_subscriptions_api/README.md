# solana_kit_rpc_subscriptions_api

Subscription method type definitions and parameter builders for all Solana RPC subscription methods in the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc-subscriptions-api`](https://github.com/anza-xyz/kit/tree/main/packages/rpc-subscriptions-api) from the Solana TypeScript SDK.

## Installation

Add `solana_kit_rpc_subscriptions_api` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_rpc_subscriptions_api:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Usage

### Account notifications

Subscribe to be notified whenever the lamports or data of an account changes.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  const myAddress = Address('11111111111111111111111111111111');

  // Build the JSON-RPC params for accountSubscribe.
  final params = accountNotificationsParams(
    myAddress,
    AccountNotificationsConfig(
      commitment: Commitment.confirmed,
      encoding: 'base64',
    ),
  );

  print(params);
  // ['11111111111111111111111111111111', {'commitment': 'confirmed', 'encoding': 'base64'}]
}
```

### Signature notifications

Subscribe to be notified when a transaction with the given signature reaches a commitment level.

```dart
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  const sig = Signature(
    '5VERv8NMvzbJMEkV8xnrLkEaWRtSz9CosKDYjCJjBRnbJLgp8uirBgmQpjKhoR4tjF3ZpRzrFmBV6UjKdiSZkQUW',
  );

  // Build the JSON-RPC params for signatureSubscribe.
  final params = signatureNotificationsParams(
    sig,
    SignatureNotificationsConfig(
      commitment: Commitment.finalized,
      enableReceivedNotification: true,
    ),
  );

  print(params);
  // ['5VERv8N...', {'commitment': 'finalized', 'enableReceivedNotification': true}]
}
```

### Logs notifications

Subscribe to transaction logs, optionally filtering by address.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  // Subscribe to all non-vote transaction logs.
  final allParams = logsNotificationsParams(const LogsFilterAll());

  // Subscribe to all transaction logs (including votes).
  final allWithVotesParams = logsNotificationsParams(
    const LogsFilterAllWithVotes(),
  );

  // Subscribe to logs mentioning a specific address.
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
  final mentionsParams = logsNotificationsParams(
    LogsFilterMentions(tokenProgram),
    LogsNotificationsConfig(commitment: Commitment.confirmed),
  );
}
```

### Program notifications

Subscribe to changes in any account owned by a specific program.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

void main() {
  const tokenProgram = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  final params = programNotificationsParams(
    tokenProgram,
    ProgramNotificationsConfig(
      commitment: Commitment.confirmed,
      encoding: 'base64',
      filters: [
        {'dataSize': 165}, // Token account size.
      ],
    ),
  );
}
```

### Slot and root notifications

These subscription methods take no parameters.

```dart
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';

void main() {
  // Subscribe to slot changes.
  final slotParams = slotNotificationsParams(); // []

  // Subscribe to root changes (highest confirmed slot considered finalized).
  final rootParams = rootNotificationsParams(); // []
}
```

### Checking subscription method stability

Determine whether a subscription method name is stable or unstable.

```dart
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';

void main() {
  // Stable methods.
  print(isSolanaRpcSubscriptionMethodStable('accountSubscribe')); // true
  print(isSolanaRpcSubscriptionMethodStable('slotSubscribe')); // true

  // Unstable methods.
  print(isSolanaRpcSubscriptionMethodStable('blockSubscribe')); // false
  print(isSolanaRpcSubscriptionMethod('blockSubscribe')); // true

  // Convert notification names to subscribe/unsubscribe method names.
  print(notificationNameToSubscribeMethod('accountNotifications'));
  // 'accountSubscribe'
  print(notificationNameToUnsubscribeMethod('accountNotifications'));
  // 'accountUnsubscribe'
}
```

## API Reference

### Stable subscription methods

| Notification name        | Builder function                                    | Config class                   |
| ------------------------ | --------------------------------------------------- | ------------------------------ |
| `accountNotifications`   | `accountNotificationsParams(address, [config])`     | `AccountNotificationsConfig`   |
| `logsNotifications`      | `logsNotificationsParams(filter, [config])`         | `LogsNotificationsConfig`      |
| `programNotifications`   | `programNotificationsParams(programId, [config])`   | `ProgramNotificationsConfig`   |
| `rootNotifications`      | `rootNotificationsParams()`                         | --                             |
| `signatureNotifications` | `signatureNotificationsParams(signature, [config])` | `SignatureNotificationsConfig` |
| `slotNotifications`      | `slotNotificationsParams()`                         | --                             |

### Unstable subscription methods

| Notification name           | Description                                                                      |
| --------------------------- | -------------------------------------------------------------------------------- |
| `blockNotifications`        | Subscribe to new confirmed blocks.                                               |
| `slotsUpdatesNotifications` | Subscribe to slot update events (created, dead, optimistically confirmed, etc.). |
| `voteNotifications`         | Subscribe to new vote transactions.                                              |

### Logs filter classes

| Class                                 | Description                                           |
| ------------------------------------- | ----------------------------------------------------- |
| `LogsFilterAll`                       | Matches all non-vote transactions.                    |
| `LogsFilterAllWithVotes`              | Matches all transactions including vote transactions. |
| `LogsFilterMentions(Address address)` | Matches transactions mentioning a specific address.   |

### Method name utilities

| Function                                                 | Description                                                       |
| -------------------------------------------------------- | ----------------------------------------------------------------- |
| `isSolanaRpcSubscriptionMethodStable(String methodName)` | Returns `true` if the method is stable.                           |
| `isSolanaRpcSubscriptionMethod(String methodName)`       | Returns `true` if the method is stable or unstable.               |
| `notificationNameToSubscribeMethod(String name)`         | Converts e.g. `'accountNotifications'` to `'accountSubscribe'`.   |
| `notificationNameToUnsubscribeMethod(String name)`       | Converts e.g. `'accountNotifications'` to `'accountUnsubscribe'`. |

### Constants

| Constant                                      | Description                                                  |
| --------------------------------------------- | ------------------------------------------------------------ |
| `solanaRpcSubscriptionsMethodsStable`         | List of 6 stable subscription method names.                  |
| `solanaRpcSubscriptionsMethodsUnstable`       | List of all 9 subscription method names (stable + unstable). |
| `solanaRpcSubscriptionsNotificationsStable`   | List of 6 stable notification names.                         |
| `solanaRpcSubscriptionsNotificationsUnstable` | List of all 9 notification names (stable + unstable).        |
