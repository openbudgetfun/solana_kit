// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

/// The JSON-RPC ping payload sent to keep connections alive.
const Map<String, Object> pingPayload = {'jsonrpc': '2.0', 'method': 'ping'};

/// Wraps an [RpcSubscriptionsChannel] to send periodic ping messages.
///
/// Ping messages are sent at [intervalMs] intervals. The timer resets whenever
/// a message is sent or received. Pinging stops when the [abortSignal] fires,
/// the channel encounters an error, or a send fails with a connection closed
/// error.
///
/// Returns a new [RpcSubscriptionsChannel] that wraps the original [channel].
RpcSubscriptionsChannel getRpcSubscriptionsChannelWithAutoping({
  required CancellationToken abortSignal,
  required RpcSubscriptionsChannel channel,
  required int intervalMs,
}) {
  Timer? timer;
  final pingerAbortSource = CancellationTokenSource();

  void stopPinging() {
    timer?.cancel();
    timer = null;
  }

  void sendPing() {
    unawaited(
      channel.send(pingPayload).catchError((Object e) {
        if (isSolanaError(
          e,
          SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed,
        )) {
          pingerAbortSource.cancel();
        }
      }),
    );
  }

  void restartPingTimer() {
    stopPinging();
    timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      sendPing();
    });
  }

  // Stop pinging when the pinger abort source fires.
  pingerAbortSource.token.future.then((_) {
    stopPinging();
  }).ignore();

  // Stop pinging when the caller's cancellation token fires.
  abortSignal.future.then((_) {
    pingerAbortSource.cancel();
  }).ignore();

  final channelSubscriptions = <StreamSubscription<Object?>>[];

  void cancelChannelSubscriptions() {
    for (final subscription in channelSubscriptions) {
      unawaited(subscription.cancel());
    }
    channelSubscriptions.clear();
  }

  pingerAbortSource.token.future.then((_) {
    cancelChannelSubscriptions();
  }).ignore();

  // Stop pinging on channel errors.
  channelSubscriptions.add(
    channel.streams.errors.listen((_) {
      pingerAbortSource.cancel();
    }),
  );

  // Restart the ping timer on every received message.
  channelSubscriptions.add(
    channel.streams.notifications.listen((_) {
      if (!pingerAbortSource.token.isCancelled) {
        restartPingTimer();
      }
    }),
  );

  // Start the ping timer immediately (no browser-specific offline detection
  // since Dart does not run in a browser context in the same way as JS).
  restartPingTimer();

  return _AutopingChannel(
    channel: channel,
    pingerAbortSource: pingerAbortSource,
    restartPingTimer: restartPingTimer,
  );
}

class _AutopingChannel implements RpcSubscriptionsChannel {
  _AutopingChannel({
    required this.channel,
    required this.pingerAbortSource,
    required this.restartPingTimer,
  });

  final RpcSubscriptionsChannel channel;
  final CancellationTokenSource pingerAbortSource;
  final void Function() restartPingTimer;

  @override
  NotificationStreams get streams => channel.streams;

  @override
  Future<void> send(Object message) {
    if (!pingerAbortSource.token.isCancelled) {
      restartPingTimer();
    }
    return channel.send(message);
  }
}
