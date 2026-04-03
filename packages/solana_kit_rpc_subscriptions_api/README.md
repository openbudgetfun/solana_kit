# solana_kit_rpc_subscriptions_api

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_subscriptions_api.svg)](https://pub.dev/packages/solana_kit_rpc_subscriptions_api)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_subscriptions_api/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Subscription method type definitions and parameter builders for all Solana RPC subscription methods in the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc-subscriptions-api`](https://github.com/anza-xyz/kit/tree/main/packages/rpc-subscriptions-api) from the Solana TypeScript SDK.

<!-- {=packageInstallSection:"solana_kit_rpc_subscriptions_api"} -->

## Installation

Install the package directly:

```bash
dart pub add solana_kit_rpc_subscriptions_api
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_rpc_subscriptions_api"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_subscriptions_api
- API reference: https://pub.dev/documentation/solana_kit_rpc_subscriptions_api/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_rpc_subscriptions_api
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_rpc_subscriptions_api

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

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
      encoding: AccountEncoding.base64,
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
      encoding: AccountEncoding.base64,
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

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_rpc_subscriptions_api"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_rpc_subscriptions_api`.

- Import path: `package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
