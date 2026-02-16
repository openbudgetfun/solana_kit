/// Subscription client for the Solana Kit Dart SDK.
///
/// This package is the composition layer that ties together the RPC
/// subscriptions API, WebSocket channel, subscribable pattern, JSON
/// serialization, and error handling packages.
///
/// The primary entry points are the `createSolanaRpcSubscriptions` and
/// `createSolanaRpcSubscriptionsFromTransport` factory functions.
///
/// The package also exposes the building blocks for custom compositions:
///
/// - Autopinging: keep-alive pinging
/// - Channel pooling: reuse channels across subscriptions
/// - Subscription coalescing: deduplicate identical subscriptions
/// - JSON serialization: standard and BigInt-safe variants
library;

export 'src/rpc_default_config.dart';
export 'src/rpc_integer_overflow_error.dart';
export 'src/rpc_subscriptions.dart';
export 'src/rpc_subscriptions_autopinger.dart';
export 'src/rpc_subscriptions_channel.dart';
export 'src/rpc_subscriptions_channel_pool.dart';
export 'src/rpc_subscriptions_channel_pool_internal.dart';
export 'src/rpc_subscriptions_clusters.dart';
export 'src/rpc_subscriptions_coalescer.dart';
export 'src/rpc_subscriptions_json.dart';
export 'src/rpc_subscriptions_json_bigint.dart';
export 'src/rpc_subscriptions_transport.dart';
