import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_channel.dart';
import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_transport.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

/// Options for subscribing to RPC notifications.
class RpcSubscribeOptions {
  /// Creates [RpcSubscribeOptions].
  const RpcSubscribeOptions({required this.abortSignal});

  /// The abort signal to fire when you want to unsubscribe.
  final AbortSignal abortSignal;
}

/// A pending RPC subscription request.
///
/// Calling [subscribe] will trigger the subscription and return a [Stream]
/// that emits notifications.
class PendingRpcSubscriptionsRequest<TNotification> {
  /// Creates a new [PendingRpcSubscriptionsRequest].
  const PendingRpcSubscriptionsRequest({
    required RpcSubscriptionsTransport transport,
    required RpcSubscriptionsPlan<TNotification> plan,
  }) : _transport = transport,
       _plan = plan;

  final RpcSubscriptionsTransport _transport;
  final RpcSubscriptionsPlan<TNotification> _plan;

  /// Subscribes to the notification stream.
  ///
  /// Returns a [Stream] that emits notifications of type [TNotification].
  /// The subscription will be cancelled when the abort signal fires.
  Future<Stream<TNotification>> subscribe(RpcSubscribeOptions options) async {
    final notificationsDataPublisher = await _transport(
      RpcSubscriptionsTransportConfig(
        execute: _plan.execute,
        request: _plan.request,
        signal: options.abortSignal,
      ),
    );

    return createStreamFromDataPublisher<TNotification>(
      StreamFromDataPublisherConfig(
        dataChannelName: 'notification',
        dataPublisher: notificationsDataPublisher,
        errorChannelName: 'error',
      ),
    );
  }
}

/// Describes a subscription plan, including the request details and how to
/// execute the subscription on a channel.
class RpcSubscriptionsPlan<TNotification> {
  /// Creates a new [RpcSubscriptionsPlan].
  const RpcSubscriptionsPlan({required this.execute, required this.request});

  /// The execute function that performs the subscription on a channel.
  final Future<DataPublisher> Function(
    RpcSubscriptionsTransportExecuteConfig config,
  )
  execute;

  /// The RPC request for this subscription.
  final RpcSubscriptionsRequest request;
}

/// An RPC subscriptions API that maps notification names to subscription plan
/// creators.
///
/// Since Dart does not support JavaScript-style Proxy objects, this class
/// provides a [getPlan] method that takes a notification name and parameters
/// and returns an [RpcSubscriptionsPlan].
// ignore: one_member_abstracts
abstract class RpcSubscriptionsApi {
  /// Returns an [RpcSubscriptionsPlan] for the given [notificationName] and
  /// [params].
  ///
  /// Returns `null` if no plan is available for the given notification name.
  RpcSubscriptionsPlan<Object?>? getPlan(
    String notificationName,
    List<Object?> params,
  );
}

/// Configuration for creating an [RpcSubscriptions] instance.
class RpcSubscriptionsConfig {
  /// Creates a new [RpcSubscriptionsConfig].
  const RpcSubscriptionsConfig({required this.api, required this.transport});

  /// The subscriptions API.
  final RpcSubscriptionsApi api;

  /// The subscriptions transport.
  final RpcSubscriptionsTransport transport;
}

/// An RPC subscriptions client.
///
/// Since Dart does not support JavaScript-style Proxy objects, subscription
/// methods are called through the [request] method which takes a notification
/// name and optional parameters.
///
/// ```dart
/// final subscriptions = createSubscriptionRpc(
///   RpcSubscriptionsConfig(
///     api: myApi,
///     transport: myTransport,
///   ),
/// );
///
/// final pending = subscriptions.request('accountNotifications', ['address']);
/// final stream = await pending.subscribe(
///   RpcSubscribeOptions(abortSignal: controller.signal),
/// );
/// await for (final notification in stream) {
///   print('Got notification: $notification');
/// }
/// ```
class RpcSubscriptions {
  /// Creates a new [RpcSubscriptions].
  const RpcSubscriptions({required this.api, required this.transport});

  /// The subscriptions API.
  final RpcSubscriptionsApi api;

  /// The subscriptions transport.
  final RpcSubscriptionsTransport transport;

  /// Creates a [PendingRpcSubscriptionsRequest] for the given
  /// [notificationName] and [params].
  ///
  /// Throws a [SolanaError] with code
  /// [SolanaErrorCode.rpcSubscriptionsCannotCreateSubscriptionPlan] if no
  /// API plan is available for the given notification name.
  PendingRpcSubscriptionsRequest<Object?> request(
    String notificationName, [
    List<Object?> params = const [],
  ]) {
    final plan = api.getPlan(notificationName, params);
    if (plan == null) {
      throw SolanaError(
        SolanaErrorCode.rpcSubscriptionsCannotCreateSubscriptionPlan,
        {'notificationName': notificationName},
      );
    }
    return PendingRpcSubscriptionsRequest<Object?>(
      transport: transport,
      plan: plan,
    );
  }
}

/// Creates an [RpcSubscriptions] instance from the given [config].
RpcSubscriptions createSubscriptionRpc(RpcSubscriptionsConfig config) {
  return RpcSubscriptions(api: config.api, transport: config.transport);
}

/// Creates a Solana RPC subscriptions client with stable API methods.
///
/// This is a convenience factory that composes:
/// - A default Solana RPC subscriptions channel creator with BigInt JSON
///   serialization, autopinging, and channel pooling.
/// - A default transport with subscription coalescing.
///
/// Use [config] to customize channel behavior.
RpcSubscriptions createSolanaRpcSubscriptions(
  String clusterUrl, [
  DefaultRpcSubscriptionsChannelConfig? config,
]) {
  final effectiveConfig =
      config ?? DefaultRpcSubscriptionsChannelConfig(url: clusterUrl);

  final transport = createDefaultRpcSubscriptionsTransport(
    DefaultRpcSubscriptionsTransportConfig(
      createChannel: createDefaultSolanaRpcSubscriptionsChannelCreator(
        effectiveConfig,
      ),
    ),
  );

  return createSolanaRpcSubscriptionsFromTransport(transport);
}

/// Creates a Solana RPC subscriptions client with stable and unstable API
/// methods.
///
/// This is the same as [createSolanaRpcSubscriptions] but includes unstable
/// subscription methods like `blockNotifications`,
/// `slotsUpdatesNotifications`, and `voteNotifications`.
RpcSubscriptions createSolanaRpcSubscriptionsUnstable(
  String clusterUrl, [
  DefaultRpcSubscriptionsChannelConfig? config,
]) {
  // Same implementation as the stable version since in Dart we do not have
  // TS generic type constraints to limit the API surface.
  return createSolanaRpcSubscriptions(clusterUrl, config);
}

/// Creates a Solana RPC subscriptions client from the given [transport].
///
/// This is useful when you want to provide a custom transport or reuse an
/// existing one.
RpcSubscriptions createSolanaRpcSubscriptionsFromTransport(
  RpcSubscriptionsTransport transport,
) {
  return RpcSubscriptions(
    api: _PassthroughSubscriptionsApi(),
    transport: transport,
  );
}

/// A passthrough subscriptions API that creates plans from any notification
/// name and parameters without validation.
///
/// This is used by the default factory functions since the actual subscription
/// plan execution is handled by the transport/channel composition.
class _PassthroughSubscriptionsApi extends RpcSubscriptionsApi {
  @override
  RpcSubscriptionsPlan<Object?>? getPlan(
    String notificationName,
    List<Object?> params,
  ) {
    return RpcSubscriptionsPlan<Object?>(
      execute: (config) async {
        // The actual execution is delegated to the transport.
        return config.channel;
      },
      request: RpcSubscriptionsRequest(
        methodName: notificationName,
        params: params,
      ),
    );
  }
}
