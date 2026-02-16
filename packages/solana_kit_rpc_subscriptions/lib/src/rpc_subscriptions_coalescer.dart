import 'dart:async';

import 'package:solana_kit_fast_stable_stringify/solana_kit_fast_stable_stringify.dart';
import 'package:solana_kit_rpc_subscriptions/src/rpc_subscriptions_transport.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

class _CacheEntry {
  _CacheEntry({
    required this.abortController,
    required this.dataPublisherFuture,
  });

  final AbortController abortController;
  final Future<DataPublisher> dataPublisherFuture;
  int numSubscribers = 0;
}

/// Wraps an [RpcSubscriptionsTransport] to coalesce identical subscriptions.
///
/// When multiple callers subscribe to the same method with the same params,
/// only one subscription is created on the server. All callers share the same
/// [DataPublisher]. When the last caller unsubscribes (by aborting their
/// signal), the server subscription is cancelled.
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
      final abortController = AbortController();
      final dataPublisherFuture = transport(
        RpcSubscriptionsTransportConfig(
          execute: config.execute,
          request: config.request,
          signal: abortController.signal,
        ),
      );

      // Listen for errors on the data publisher to invalidate the cache.
      dataPublisherFuture
          .then((dataPublisher) {
            dataPublisher.on('error', (_) {
              cache.remove(subscriptionConfigurationHash);
              abortController.abort();
            });
          })
          .catchError((_) {
            // Ignore errors from the transport itself.
          });

      cachedEntry = _CacheEntry(
        abortController: abortController,
        dataPublisherFuture: dataPublisherFuture,
      );
      cache[subscriptionConfigurationHash] = cachedEntry;
    }

    cachedEntry.numSubscribers++;

    // Listen for the caller's abort signal.
    final entry = cachedEntry;

    void handleAbort() {
      entry.numSubscribers--;
      if (entry.numSubscribers == 0) {
        // Use a microtask to allow re-subscription in the same turn.
        scheduleMicrotask(() {
          if (entry.numSubscribers == 0 &&
              cache[subscriptionConfigurationHash] == entry) {
            cache.remove(subscriptionConfigurationHash);
            entry.abortController.abort();
          }
        });
      }
    }

    if (signal.isAborted) {
      handleAbort();
    } else {
      signal.future.then((_) => handleAbort()).ignore();
    }

    return entry.dataPublisherFuture;
  };
}
