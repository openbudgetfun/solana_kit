# solana_kit_transaction_confirmation

Transaction confirmation tracking for the Solana Kit Dart SDK -- provides multiple strategies to confirm or detect expiry of Solana transactions.

This is the Dart port of [`@solana/transaction-confirmation`](https://github.com/anza-xyz/kit/tree/main/packages/transaction-confirmation) from the Solana TypeScript SDK.

## Installation

Add `solana_kit_transaction_confirmation` to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_transaction_confirmation:
```

Or, if you are using the umbrella package:

```yaml
dependencies:
  solana_kit:
```

## Usage

### Strategy overview

This package provides five confirmation strategies that can be composed together:

1. **Recent Signature Confirmation** -- Watches for a signature to reach a target commitment level.
2. **Block Height Exceedence** -- Detects when the network has progressed past the last valid block height for a transaction.
3. **Nonce Invalidation** -- Detects when a durable nonce has been advanced, meaning the transaction has expired.
4. **Timeout** -- A simple timeout-based fallback.
5. **Strategy Racing** -- Races multiple strategies against each other, resolving with the first to complete.

### Confirming a recent transaction (block height strategy)

The recommended approach for confirming blockhash-based transactions is to race the signature confirmation against block height exceedence.

```dart
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';

Future<void> confirmTransaction(String signature) async {
  final controller = AbortController();

  // Create the signature confirmation factory.
  // This watches the RPC for signature status updates.
  final getRecentSignatureConfirmation =
      createRecentSignatureConfirmationPromiseFactory(
        RecentSignatureConfirmationConfig(
          getSignatureStatuses: (sigs, {required abortSignal}) async {
            // Call your RPC's getSignatureStatuses method.
            // Return a list of SignatureStatus? (null if not found).
            return [];
          },
          onSignatureNotification: (sig, {
            required abortSignal,
            required commitment,
            required onNotification,
          }) async {
            // Subscribe to signatureNotifications via WebSocket.
            // Call onNotification(err: null) when the signature is confirmed.
          },
        ),
      );

  // Create the block height exceedence factory.
  // This monitors the network's block height and rejects when it exceeds
  // the transaction's lastValidBlockHeight.
  final getBlockHeightExceedence =
      createBlockHeightExceedencePromiseFactory(
        BlockHeightExceedenceConfig(
          getEpochInfo: ({required abortSignal, commitment}) async {
            // Call your RPC's getEpochInfo method.
            return EpochInfo(
              absoluteSlot: BigInt.from(100),
              blockHeight: BigInt.from(90),
            );
          },
          onSlotNotification: ({
            required abortSignal,
            required onNotification,
          }) async {
            // Subscribe to slotNotifications via WebSocket.
          },
        ),
      );

  // Wait for confirmation, racing against block height expiry.
  await waitForRecentTransactionConfirmation(
    abortSignal: controller.signal,
    commitment: Commitment.confirmed,
    getBlockHeightExceedencePromise: getBlockHeightExceedence,
    getRecentSignatureConfirmationPromise: getRecentSignatureConfirmation,
    lastValidBlockHeight: BigInt.from(200),
    signature: signature,
  );

  print('Transaction confirmed!');
}
```

### Confirming a durable nonce transaction

For transactions using durable nonces, race signature confirmation against nonce invalidation.

```dart
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';

Future<void> confirmNonceTransaction({
  required String signature,
  required String nonceAccountAddress,
  required String nonceValue,
  required GetRecentSignatureConfirmationPromise getRecentSignatureConfirmation,
}) async {
  final controller = AbortController();

  // Create the nonce invalidation factory.
  // This monitors a nonce account and rejects when its value changes,
  // indicating the transaction has expired.
  final getNonceInvalidation =
      createNonceInvalidationPromiseFactory(
        NonceInvalidationConfig(
          getNonceAccount: (address, {
            required abortSignal,
            required commitment,
          }) async {
            // Fetch and parse the nonce account data.
            return NonceAccountInfo(nonceValue: 'current-nonce-value');
          },
          onAccountNotification: (address, {
            required abortSignal,
            required commitment,
            required onNotification,
          }) async {
            // Subscribe to accountNotifications for the nonce account.
          },
        ),
      );

  // Wait for confirmation, racing against nonce invalidation.
  await waitForDurableNonceTransactionConfirmation(
    abortSignal: controller.signal,
    commitment: Commitment.confirmed,
    getNonceInvalidationPromise: getNonceInvalidation,
    getRecentSignatureConfirmationPromise: getRecentSignatureConfirmation,
    nonceAccountAddress: nonceAccountAddress,
    nonceValue: nonceValue,
    signature: signature,
  );

  print('Durable nonce transaction confirmed!');
}
```

### Comparing commitment levels

The `commitmentComparator` function (re-exported from `solana_kit_rpc_types`) enables comparing commitment levels.

```dart
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';

void main() {
  // commitmentComparator returns:
  //   < 0 if c1 is lower than c2
  //   0 if c1 equals c2
  //   > 0 if c1 is higher than c2

  print(commitmentComparator(Commitment.finalized, Commitment.confirmed) > 0);
  // true -- finalized is higher than confirmed

  print(commitmentComparator(Commitment.processed, Commitment.confirmed) < 0);
  // true -- processed is lower than confirmed

  print(commitmentComparator(Commitment.confirmed, Commitment.confirmed) == 0);
  // true -- same level
}
```

### Racing custom strategies

The `raceStrategies` function races a signature confirmation promise against a list of other strategy futures. The first to resolve or reject determines the outcome.

```dart
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';

Future<void> confirmWithCustomStrategy({
  required String signature,
  required GetRecentSignatureConfirmationPromise confirmationFactory,
}) async {
  final controller = AbortController();

  // Race signature confirmation against both a timeout and a custom strategy.
  await raceStrategies(
    signature,
    BaseTransactionConfirmationStrategyConfig(
      abortSignal: controller.signal,
      commitment: Commitment.confirmed,
      getRecentSignatureConfirmationPromise: confirmationFactory,
    ),
    ({required AbortSignal abortSignal}) => [
      getTimeoutPromise(
        abortSignal: abortSignal,
        commitment: Commitment.confirmed,
      ),
    ],
  );

  print('Transaction confirmed before timeout!');
}
```

### Timeout strategy

The `getTimeoutPromise` function provides a simple timeout-based fallback. It uses 30 seconds for `processed` commitment and 60 seconds otherwise.

```dart
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';

Future<void> main() async {
  final controller = AbortController();

  try {
    await getTimeoutPromise(
      abortSignal: controller.signal,
      commitment: Commitment.confirmed,
    );
  } on TimeoutException {
    print('Transaction timed out after 60 seconds');
  }
}
```

## API Reference

### Waiter functions

| Function                                                  | Description                                                    |
| --------------------------------------------------------- | -------------------------------------------------------------- |
| `waitForRecentTransactionConfirmation({...})`             | Races signature confirmation against block height exceedence.  |
| `waitForDurableNonceTransactionConfirmation({...})`       | Races signature confirmation against nonce invalidation.       |
| `waitForRecentTransactionConfirmationUntilTimeout({...})` | _(Deprecated)_ Races signature confirmation against a timeout. |

### Factory functions

| Function                                                  | Description                                                                      |
| --------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `createRecentSignatureConfirmationPromiseFactory(config)` | Creates a function that resolves when a signature reaches a target commitment.   |
| `createBlockHeightExceedencePromiseFactory(config)`       | Creates a function that rejects when block height exceeds the last valid height. |
| `createNonceInvalidationPromiseFactory(config)`           | Creates a function that rejects when a durable nonce has been advanced.          |

### Strategy functions

| Function                                           | Description                                                         |
| -------------------------------------------------- | ------------------------------------------------------------------- |
| `raceStrategies(signature, config, getStrategies)` | Races a signature confirmation against specific strategies.         |
| `getTimeoutPromise({abortSignal, commitment})`     | Returns a future that rejects after 30s (processed) or 60s (other). |

### Comparators

| Function                       | Description                                                            |
| ------------------------------ | ---------------------------------------------------------------------- |
| `commitmentComparator(c1, c2)` | Compares two `Commitment` levels. Returns negative, zero, or positive. |

### Configuration classes

| Class                                       | Description                                                                                              |
| ------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `RecentSignatureConfirmationConfig`         | Config: `getSignatureStatuses`, `onSignatureNotification`.                                               |
| `BlockHeightExceedenceConfig`               | Config: `getEpochInfo`, `onSlotNotification`.                                                            |
| `NonceInvalidationConfig`                   | Config: `getNonceAccount`, `onAccountNotification`.                                                      |
| `BaseTransactionConfirmationStrategyConfig` | Base config for `raceStrategies`: `commitment`, `getRecentSignatureConfirmationPromise`, `abortSignal?`. |

### Type aliases

| Type                                    | Description                                                                                                                                                       |
| --------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `GetRecentSignatureConfirmationPromise` | Function type for signature confirmation: `Future<void> Function({required AbortSignal abortSignal, required Commitment commitment, required String signature})`. |

### Data classes

| Class              | Description                                                     |
| ------------------ | --------------------------------------------------------------- |
| `SignatureStatus`  | Status of a transaction signature: `confirmationStatus`, `err`. |
| `EpochInfo`        | Epoch info: `absoluteSlot`, `blockHeight`.                      |
| `SlotNotification` | A slot notification: `slot`.                                    |
| `NonceAccountInfo` | Nonce account info: `nonceValue`.                               |
