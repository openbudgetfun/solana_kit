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
  required AbortSignal abortSignal,
  required RpcSubscriptionsChannel channel,
  required int intervalMs,
}) {
  Timer? timer;
  final pingerAbortController = AbortController();

  void stopPinging() {
    timer?.cancel();
    timer = null;
  }

  void sendPing() {
    channel.send(pingPayload).catchError((Object e) {
      if (isSolanaError(
        e,
        SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed,
      )) {
        pingerAbortController.abort();
      }
    });
  }

  void restartPingTimer() {
    stopPinging();
    timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      sendPing();
    });
  }

  // Stop pinging when the pinger abort controller fires.
  pingerAbortController.signal.future.then((_) {
    stopPinging();
  }).ignore();

  // Stop pinging when the caller's abort signal fires.
  abortSignal.future.then((_) {
    pingerAbortController.abort();
  }).ignore();

  // Stop pinging on channel errors.
  channel
    ..on('error', (_) {
      pingerAbortController.abort();
    })
    // Restart the ping timer on every received message.
    ..on('message', (_) {
      if (!pingerAbortController.signal.isAborted) {
        restartPingTimer();
      }
    });

  // Start the ping timer immediately (no browser-specific offline detection
  // since Dart does not run in a browser context in the same way as JS).
  restartPingTimer();

  return _AutopingChannel(
    channel: channel,
    pingerAbortController: pingerAbortController,
    restartPingTimer: restartPingTimer,
  );
}

class _AutopingChannel implements RpcSubscriptionsChannel {
  _AutopingChannel({
    required this.channel,
    required this.pingerAbortController,
    required this.restartPingTimer,
  });

  final RpcSubscriptionsChannel channel;
  final AbortController pingerAbortController;
  final void Function() restartPingTimer;

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    return channel.on(channelName, subscriber);
  }

  @override
  Future<void> send(Object message) {
    if (!pingerAbortController.signal.isAborted) {
      restartPingTimer();
    }
    return channel.send(message);
  }
}
