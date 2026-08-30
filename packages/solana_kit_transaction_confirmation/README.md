# solana_kit_transaction_confirmation

[![pub package](https://img.shields.io/pub/v/solana_kit_transaction_confirmation.svg)](https://pub.dev/packages/solana_kit_transaction_confirmation) [![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_transaction_confirmation/latest/) [![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_transaction_confirmation) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_transaction_confirmation)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_transaction_confirmation)

Confirm Solana transactions by racing signature notifications against block-height expiry, durable-nonce invalidation, or timeouts.

<!-- {=packageInstallSection:"solana_kit_transaction_confirmation"} -->

## Installation

Install the package directly:

```yaml
dependencies:
  "solana_kit_transaction_confirmation": ^0.9.0
```

If your app uses several Solana Kit packages together, you can also depend on the umbrella package instead:

```bash
dart pub add solana_kit
```

Inside this monorepo, Dart workspace resolution uses the local package automatically.

<!-- {/packageInstallSection} -->

<!-- {=packageDocumentationSection:"solana_kit_transaction_confirmation"} -->

## Documentation

- Package page: https://pub.dev/packages/solana_kit_transaction_confirmation
- API reference: https://pub.dev/documentation/solana_kit_transaction_confirmation/latest/
- Workspace docs: https://openbudgetfun.github.io/solana_kit/
- Package catalog entry: https://openbudgetfun.github.io/solana_kit/reference/package-catalog#solana_kit_transaction_confirmation
- Source code: https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_transaction_confirmation

For architecture notes, getting-started guides, and cross-package examples, start with the workspace docs site and then drill down into the package README and API reference.

<!-- {/packageDocumentationSection} -->

## Usage

### Send and confirm

The additive helper `sendAndConfirmTransaction` signs, sends, and polls for confirmation in one call. Pass an `Rpc` instance and a fully signed transaction.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
  // `signedTransaction` is a fully signed TransactionWithLifetime.
  // final signature = await sendAndConfirmTransaction(
  //   rpc: rpc,
  //   transaction: signedTransaction,
  // );
  // print('Confirmed signature: ${signature.value}');
  print(rpc);
}
```

### Wait for confirmation

If you already have a signature (for example, from a prior `sendTransaction` call), use `waitForTransactionConfirmation` to poll until the transaction reaches your target commitment level.

```dart
import 'package:solana_kit/solana_kit.dart';

Future<void> main() async {
  final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
  // `signature` and `transaction` come from a prior sendTransaction call.
  // await waitForTransactionConfirmation(
  //   rpc: rpc,
  //   signature: mySignature,
  //   transaction: myTransaction,
  // );
  print(rpc);
}
```

### Configuration

Both helpers accept an optional config object:

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final abortSource = CancellationTokenSource();
  final config = RpcTransactionConfirmationConfig(
    commitment: Commitment.confirmed,
    pollInterval: Duration(milliseconds: 400),
    searchTransactionHistory: false,
    abortSignal: abortSource.token,
  );
  print(config.commitment);
}
```

`SendAndConfirmTransactionConfig` extends `RpcTransactionConfirmationConfig` and adds `maxRetries` for the send step.

### Low-level strategy factories

For custom confirmation logic, the package exposes strategy factories you can compose yourself:

- `createBlockheightExceedencePromiseFactory` races the signature against block height.
- `createNonceInvalidationPromiseFactory` races the signature against durable nonce invalidation.
- `createRecentSignatureConfirmationPromise` polls `getSignatureStatuses`.
- `createTimeoutPromise` adds a wall-clock deadline.
- `raceStrategies` combines two or more strategies, resolving when the first succeeds and cancelling the rest.

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_transaction_confirmation"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_transaction_confirmation`.

- Import path: `package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
