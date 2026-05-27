import 'dart:async';

import 'package:solana_kit/src/slot_tracking_stream.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

/// A reactive store that combines an initial RPC response with subscription
/// updates using slot-based freshness checks.
class SlotTrackingReactiveStore<T> {
  SlotTrackingReactiveStore._();

  final Set<ReactiveStoreSubscriber> _subscribers = {};
  var _lastUpdateSlot = BigInt.from(-1);
  SolanaRpcResponse<T>? _state;
  Object? _error;
  StreamSubscription<Object?>? _subscription;
  bool _isDisposed = false;
  bool _isDisconnected = false;

  /// The first error observed from the RPC request or subscription, if any.
  Object? getError() => _error;

  /// The latest non-stale state, or `null` before the first response arrives.
  SolanaRpcResponse<T>? getState() => _state;

  /// Registers [callback] for state and error changes.
  UnsubscribeFn subscribe(ReactiveStoreSubscriber callback) {
    if (_isDisposed) return () {};
    _subscribers.add(callback);

    var isSubscribed = true;
    return () {
      if (!isSubscribed) return;
      isSubscribed = false;
      _subscribers.remove(callback);
    };
  }

  /// Disconnects this store from future updates and clears subscribers.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _isDisconnected = true;
    _subscription?.cancel();
    _subscribers.clear();
  }

  void _addIfCurrent<TValue>(
    SolanaRpcResponse<TValue> response,
    SlotTrackingValueMapper<TValue, T> mapper,
  ) {
    if (_isDisposed || _isDisconnected) return;
    if (response.context.slot < _lastUpdateSlot) return;
    _lastUpdateSlot = response.context.slot;
    _state = SolanaRpcResponse<T>(
      context: response.context,
      value: mapper(response.value),
    );
    _notifySubscribers();
  }

  void _handleError(Object error) {
    if (_isDisposed || _isDisconnected || _error != null) return;
    _error = error;
    _isDisconnected = true;
    _subscription?.cancel();
    _notifySubscribers();
  }

  void _notifySubscribers() {
    for (final subscriber in List<ReactiveStoreSubscriber>.of(_subscribers)) {
      subscriber();
    }
  }
}

/// Creates a [SlotTrackingReactiveStore] that combines an initial RPC response
/// with ongoing subscription updates.
SlotTrackingReactiveStore<TItem>
createSlotTrackingReactiveStore<TRpcValue, TSubscriptionValue, TItem>({
  required Future<SolanaRpcResponse<TRpcValue>> rpcRequest,
  required Stream<SolanaRpcResponse<TSubscriptionValue>> rpcSubscription,
  required SlotTrackingValueMapper<TRpcValue, TItem> rpcValueMapper,
  required SlotTrackingValueMapper<TSubscriptionValue, TItem>
  rpcSubscriptionValueMapper,
}) {
  final store = SlotTrackingReactiveStore<TItem>._();
  // The store owns this subscription and cancels it from dispose/error paths.
  // ignore: cancel_subscriptions
  final subscription = rpcSubscription.listen(
    (response) => store._addIfCurrent(response, rpcSubscriptionValueMapper),
    onError: store._handleError,
  );
  store._subscription = subscription;

  rpcRequest
      .then((response) => store._addIfCurrent(response, rpcValueMapper))
      .catchError(store._handleError);

  return store;
}

/// Alias matching the upstream helper name while exposing a Dart reactive store.
SlotTrackingReactiveStore<TItem>
createReactiveStoreWithInitialValueAndSlotTracking<
  TRpcValue,
  TSubscriptionValue,
  TItem
>({
  required Future<SolanaRpcResponse<TRpcValue>> rpcRequest,
  required Stream<SolanaRpcResponse<TSubscriptionValue>> rpcSubscription,
  required SlotTrackingValueMapper<TRpcValue, TItem> rpcValueMapper,
  required SlotTrackingValueMapper<TSubscriptionValue, TItem>
  rpcSubscriptionValueMapper,
}) {
  return createSlotTrackingReactiveStore(
    rpcRequest: rpcRequest,
    rpcSubscription: rpcSubscription,
    rpcValueMapper: rpcValueMapper,
    rpcSubscriptionValueMapper: rpcSubscriptionValueMapper,
  );
}
