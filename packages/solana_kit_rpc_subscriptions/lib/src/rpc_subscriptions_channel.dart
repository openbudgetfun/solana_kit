import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_autopinger.dart';
import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_channel_pool.dart';
import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_json.dart';
import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_json_bigint.dart';
import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_transport.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';

/// Configuration for creating a default RPC subscriptions channel creator.
class DefaultRpcSubscriptionsChannelConfig {
  /// Creates a [DefaultRpcSubscriptionsChannelConfig].
  const DefaultRpcSubscriptionsChannelConfig({
    required this.url,
    this.intervalMs = 5000,
    this.maxSubscriptionsPerChannel = 100,
    this.minChannels = 1,
    this.sendBufferHighWatermark = 131072,
  });

  /// The WebSocket server URL. Must use the `ws` or `wss` protocols.
  final String url;

  /// The number of milliseconds to wait since the last message sent or
  /// received over the channel before sending a ping message to keep the
  /// channel open.
  ///
  /// Defaults to 5000 (5 seconds).
  final int intervalMs;

  /// The number of subscribers that may share a channel before a new channel
  /// must be created.
  ///
  /// It is important that you set this to the maximum number of subscriptions
  /// that your RPC provider recommends making over a single connection; the
  /// default is set deliberately low, so as to comply with the restrictive
  /// limits of the public mainnet RPC node.
  ///
  /// Defaults to 100.
  final int maxSubscriptionsPerChannel;

  /// The number of channels to create before reusing a channel for a new
  /// subscription.
  ///
  /// Defaults to 1.
  final int minChannels;

  /// The number of bytes of data to admit into the WebSocket buffer before
  /// buffering data on the client.
  ///
  /// Defaults to 131072 (128KB).
  final int sendBufferHighWatermark;
}

/// Creates a default Solana RPC subscriptions channel creator.
///
/// Uses BigInt-safe JSON serialization, autopinging, and channel pooling.
///
/// This is the recommended channel creator for Solana RPC subscriptions since
/// Solana RPC servers accept and return integers larger than JavaScript's
/// `Number.MAX_SAFE_INTEGER`.
RpcSubscriptionsChannelCreator
createDefaultSolanaRpcSubscriptionsChannelCreator(
  DefaultRpcSubscriptionsChannelConfig config,
) {
  return _createDefaultRpcSubscriptionsChannelCreatorImpl(
    config,
    getRpcSubscriptionsChannelWithBigIntJsonSerialization,
  );
}

/// Creates a default RPC subscriptions channel creator with standard JSON
/// serialization.
///
/// Uses standard JSON serialization (no BigInt support), autopinging, and
/// channel pooling.
RpcSubscriptionsChannelCreator createDefaultRpcSubscriptionsChannelCreator(
  DefaultRpcSubscriptionsChannelConfig config,
) {
  return _createDefaultRpcSubscriptionsChannelCreatorImpl(
    config,
    getRpcSubscriptionsChannelWithJsonSerialization,
  );
}

RpcSubscriptionsChannelCreator _createDefaultRpcSubscriptionsChannelCreatorImpl(
  DefaultRpcSubscriptionsChannelConfig config,
  RpcSubscriptionsChannel Function(RpcSubscriptionsChannel) jsonSerializer,
) {
  // Validate the URL scheme.
  if (!RegExp('^wss?:', caseSensitive: false).hasMatch(config.url)) {
    final protocolMatch = RegExp('^([^:]+):').firstMatch(config.url);
    throw ArgumentError(
      protocolMatch != null
          ? "Failed to construct WebSocket: The URL's scheme must be either "
                "'ws' or 'wss'. '${protocolMatch.group(1)}:' is not allowed."
          : "Failed to construct WebSocket: The URL '${config.url}' is "
                'invalid.',
    );
  }

  Future<RpcSubscriptionsChannel> baseChannelCreator({
    required AbortSignal abortSignal,
  }) async {
    final channel = await createWebSocketChannel(
      WebSocketChannelConfig(
        url: Uri.parse(config.url),
        sendBufferHighWatermark: config.sendBufferHighWatermark,
        signal: abortSignal,
      ),
    );

    final serializedChannel = jsonSerializer(channel);

    return getRpcSubscriptionsChannelWithAutoping(
      abortSignal: abortSignal,
      channel: serializedChannel,
      intervalMs: config.intervalMs,
    );
  }

  return getChannelPoolingChannelCreator(
    baseChannelCreator,
    maxSubscriptionsPerChannel: config.maxSubscriptionsPerChannel,
    minChannels: config.minChannels,
  );
}
