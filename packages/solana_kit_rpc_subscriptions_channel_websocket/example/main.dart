// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

void main() {
  final source = CancellationTokenSource();
  final config = WebSocketChannelConfig(
    url: Uri.parse('wss://api.mainnet-beta.solana.com'),
    signal: source.token,
  );

  print('WebSocket URL: ${config.url}');
  print('Cancelled before close: ${config.signal?.isCancelled}');

  source.cancel('example complete');
  print('Cancelled after close: ${config.signal?.isCancelled}');
}
