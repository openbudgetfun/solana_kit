import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_coalescer.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

/// A function that creates an [RpcSubscriptionsChannel].
///
/// The created channel should be torn down when the [CancellationToken] fires.
typedef RpcSubscriptionsChannelCreator =
    Future<RpcSubscriptionsChannel> Function({
      required CancellationToken abortSignal,
    });

/// Configuration for executing a subscription on a channel.
class RpcSubscriptionsTransportExecuteConfig {
  /// Creates a new [RpcSubscriptionsTransportExecuteConfig].
  const RpcSubscriptionsTransportExecuteConfig({
    required this.channel,
    required this.signal,
  });

  /// The channel to execute the subscription on.
  final RpcSubscriptionsChannel channel;

  /// Cancellation token for aborting the subscription.
  final CancellationToken signal;
}

/// An RPC subscriptions request containing a method name and optional
/// parameters.
class RpcSubscriptionsRequest {
  /// Creates a new [RpcSubscriptionsRequest].
  const RpcSubscriptionsRequest({required this.methodName, this.params});

  /// The name of the RPC subscription method.
  final String methodName;

  /// The parameters for the subscription.
  final Object? params;
}

/// Configuration passed to an [RpcSubscriptionsTransport].
class RpcSubscriptionsTransportConfig {
  /// Creates a new [RpcSubscriptionsTransportConfig].
  const RpcSubscriptionsTransportConfig({
    required this.execute,
    required this.request,
    required this.signal,
  });

  /// Function that executes the subscription on a created channel.
  final Future<NotificationStreams> Function(
    RpcSubscriptionsTransportExecuteConfig config,
  )
  execute;

  /// The RPC request containing method name and params.
  final RpcSubscriptionsRequest request;

  /// Cancellation token for aborting the subscription.
  final CancellationToken signal;
}

/// A function that acts as an RPC subscriptions transport.
///
/// Given a configuration containing a request, an execute function, and a
/// cancellation token, it returns a [Future] that resolves to a
/// [NotificationStreams] which publishes subscription notifications.
typedef RpcSubscriptionsTransport =
    Future<NotificationStreams> Function(
      RpcSubscriptionsTransportConfig config,
    );

/// Creates an [RpcSubscriptionsTransport] from a channel creator.
///
/// The returned transport, when called, will:
/// 1. Create a channel using [createChannel] with the cancellation token.
/// 2. Call the `execute` function from the config with the channel and token.
/// 3. Return the resulting [NotificationStreams].
RpcSubscriptionsTransport createRpcSubscriptionsTransportFromChannelCreator(
  RpcSubscriptionsChannelCreator createChannel,
) {
  return (RpcSubscriptionsTransportConfig config) async {
    final channel = await createChannel(abortSignal: config.signal);
    return config.execute(
      RpcSubscriptionsTransportExecuteConfig(
        channel: channel,
        signal: config.signal,
      ),
    );
  };
}

/// Configuration for [createDefaultRpcSubscriptionsTransport].
class DefaultRpcSubscriptionsTransportConfig {
  /// Creates a new [DefaultRpcSubscriptionsTransportConfig].
  const DefaultRpcSubscriptionsTransportConfig({required this.createChannel});

  /// The channel creator to use.
  final RpcSubscriptionsChannelCreator createChannel;
}

/// Creates an [RpcSubscriptionsTransport] with default behaviors.
///
/// The default behaviors include:
/// - Logic that coalesces multiple subscriptions for the same notifications
///   with the same arguments into a single subscription.
RpcSubscriptionsTransport createDefaultRpcSubscriptionsTransport(
  DefaultRpcSubscriptionsTransportConfig config,
) {
  return getRpcSubscriptionsTransportWithSubscriptionCoalescing(
    createRpcSubscriptionsTransportFromChannelCreator(config.createChannel),
  );
}
