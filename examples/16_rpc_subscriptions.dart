// ignore_for_file: avoid_print
/// Example 16: Subscribe to slot notifications via WebSocket (devnet).
///
/// Demonstrates [createSolanaRpcSubscriptions], [CancellationTokenSource], and
/// how to receive a stream of notifications and cleanly unsubscribe.
///
/// ⚠️  This example opens a live WebSocket to the Solana devnet and waits for
///     3 slot notifications before disconnecting.  Requires internet access.
///
/// Run:
///   dart examples/16_rpc_subscriptions.dart
library;

import 'dart:async';

import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';

Future<void> main() async {
  // ── 1. Create a subscription client ──────────────────────────────────────
  // createSolanaRpcSubscriptions builds a WebSocket-backed subscriptions
  // client with default configuration (autopinging, channel pooling, etc.).
  final rpcSubscriptions = createSolanaRpcSubscriptions(
    'wss://api.devnet.solana.com',
  );

  // ── 2. Create a cancellation token source ─────────────────────────────────
  // The cancellation token is passed to `subscribe()` and triggers clean
  // teardown.
  final controller = CancellationTokenSource();

  print('Subscribing to slotNotifications on devnet …');

  // ── 3. Build a pending slot notification request ──────────────────────────
  final pending = rpcSubscriptions.slotNotifications();

  // ── 4. Subscribe and stream notifications ────────────────────────────────
  final stream = await pending.subscribe(
    RpcSubscribeOptions(abortSignal: controller.token),
  );

  // ── 5. Listen for 3 notifications then unsubscribe ───────────────────────
  var count = 0;
  late StreamSubscription<Object?> subscription;

  final completer = Completer<void>();

  subscription = stream.listen(
    (notification) {
      count++;
      print('Slot notification #$count: $notification');
      if (count >= 3) {
        controller.cancel('received enough notifications');
        subscription.cancel();
        completer.complete();
      }
    },
    onError: (Object error) {
      print('Stream error: $error');
      if (!completer.isCompleted) completer.completeError(error);
    },
    onDone: () {
      print('Stream closed.');
      if (!completer.isCompleted) completer.complete();
    },
  );

  await completer.future;
  print('Done after $count slot notifications.');
}
