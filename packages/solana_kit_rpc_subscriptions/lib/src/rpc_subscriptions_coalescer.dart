import 'dart:async';

import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';
import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_transport.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

class _CacheEntry {
  _CacheEntry({
    required this.abortSource,
    required this.streamsFuture,
  });

  final CancellationTokenSource abortSource;
  final Future<NotificationStreams> streamsFuture;
  int numSubscribers = 0;
}

/// Wraps an [RpcSubscriptionsTransport] to coalesce identical subscriptions.
///
/// When multiple callers subscribe to the same method with the same params,
/// only one subscription is created on the server. All callers share the same
/// [NotificationStreams]. When the last caller unsubscribes (by cancelling their
/// token), the server subscription is cancelled.
///
/// The determination of whether a subscription is the same as another is based
/// on a hash of the method name and parameters using
/// [fastStableStringify].
RpcSubscriptionsTransport
getRpcSubscriptionsTransportWithSubscriptionCoalescing(
  RpcSubscriptionsTransport transport,
) {
  final cache = <String, _CacheEntry>{};

  return (RpcSubscriptionsTransportConfig config) {
    final request = config.request;
    final signal = config.signal;

    final subscriptionConfigurationHash =
        fastStableStringify([request.methodName, request.params]) ?? '';

    var cachedEntry = cache[subscriptionConfigurationHash];
    if (cachedEntry == null) {
      final abortSource = CancellationTokenSource();
      final streamsFuture = transport(
        RpcSubscriptionsTransportConfig(
          execute: config.execute,
          request: config.request,
          signal: abortSource.token,
        ),
      );
      final newEntry = _CacheEntry(
        abortSource: abortSource,
        streamsFuture: streamsFuture,
      );
      cachedEntry = newEntry;
      cache[subscriptionConfigurationHash] = newEntry;

      void invalidateCache() {
        if (cache[subscriptionConfigurationHash] == newEntry) {
          cache.remove(subscriptionConfigurationHash);
        }
        abortSource.cancel();
      }

      // Listen for errors on the streams to invalidate the cache.
      streamsFuture
          .then<void>(
            (streams) {
              final errorSubscription = streams.errors.listen(
                (_) => invalidateCache(),
                onError: (Object error, StackTrace stackTrace) {
                  invalidateCache();
                },
              );
              abortSource.token.future.then((_) {
                unawaited(errorSubscription.cancel());
              }).ignore();
            },
            onError: (Object error, StackTrace stackTrace) {
              invalidateCache();
            },
          )
          .ignore();
    }

    cachedEntry.numSubscribers++;

    // Listen for the caller's cancellation token.
    final entry = cachedEntry;

    void handleAbort() {
      entry.numSubscribers--;
      if (entry.numSubscribers == 0) {
        // Use a microtask to allow re-subscription in the same turn.
        scheduleMicrotask(() {
          if (entry.numSubscribers == 0 &&
              cache[subscriptionConfigurationHash] == entry) {
            cache.remove(subscriptionConfigurationHash);
            entry.abortSource.cancel();
          }
        });
      }
    }

    if (signal.isCancelled) {
      handleAbort();
    } else {
      signal.future.then((_) => handleAbort()).ignore();
    }

    return entry.streamsFuture;
  };
}
