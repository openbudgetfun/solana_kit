// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

void main() {
  final controller = AbortController();
  final config = WebSocketChannelConfig(
    url: Uri.parse('wss://api.mainnet-beta.solana.com'),
    signal: controller.signal,
  );

  print('WebSocket URL: ${config.url}');
  print('Aborted before close: ${config.signal?.isAborted}');

  controller.abort('example complete');
  print('Aborted after close: ${config.signal?.isAborted}');
}
