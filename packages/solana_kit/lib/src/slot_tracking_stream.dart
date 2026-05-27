import 'dart:async';

import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Maps an RPC or subscription value to a yielded item.
typedef SlotTrackingValueMapper<TValue, TItem> = TItem Function(TValue value);

/// Combines an initial RPC response with subscription updates, yielding only
/// responses whose slot is not older than the latest yielded response.
///
/// This is the Dart-native equivalent of upstream Solana Kit's async-generator
/// helper. It accepts a [Future] for the initial fetch and a [Stream] for live
/// notifications, starts listening to both immediately, maps their values to a
/// common item type, and drops stale responses that arrive out of order.
Stream<SolanaRpcResponse<TItem>>
createSlotTrackingStream<TRpcValue, TSubscriptionValue, TItem>({
  required Future<SolanaRpcResponse<TRpcValue>> rpcRequest,
  required Stream<SolanaRpcResponse<TSubscriptionValue>> rpcSubscription,
  required SlotTrackingValueMapper<TRpcValue, TItem> rpcValueMapper,
  required SlotTrackingValueMapper<TSubscriptionValue, TItem>
  rpcSubscriptionValueMapper,
}) {
  late final StreamController<SolanaRpcResponse<TItem>> controller;
  StreamSubscription<SolanaRpcResponse<TSubscriptionValue>>? subscription;
  var lastUpdateSlot = BigInt.from(-1);
  var rpcDone = false;
  var subscriptionDone = false;
  var isClosed = false;

  void maybeClose() {
    if (!isClosed && rpcDone && subscriptionDone) {
      isClosed = true;
      controller.close();
    }
  }

  void addIfCurrent<TValue>(
    SolanaRpcResponse<TValue> response,
    SlotTrackingValueMapper<TValue, TItem> mapper,
  ) {
    if (isClosed || response.context.slot < lastUpdateSlot) return;
    lastUpdateSlot = response.context.slot;
    controller.add(
      SolanaRpcResponse<TItem>(
        context: response.context,
        value: mapper(response.value),
      ),
    );
  }

  controller = StreamController<SolanaRpcResponse<TItem>>(
    onListen: () {
      subscription = rpcSubscription.listen(
        (response) => addIfCurrent(response, rpcSubscriptionValueMapper),
        onError: controller.addError,
        onDone: () {
          subscriptionDone = true;
          maybeClose();
        },
      );

      rpcRequest
          .then((response) => addIfCurrent(response, rpcValueMapper))
          .catchError(controller.addError)
          .whenComplete(() {
            rpcDone = true;
            maybeClose();
          });
    },
    onCancel: () async {
      isClosed = true;
      await subscription?.cancel();
    },
  );

  return controller.stream;
}

/// Alias matching the upstream helper name while returning a Dart [Stream].
Stream<SolanaRpcResponse<TItem>>
createAsyncGeneratorWithInitialValueAndSlotTracking<
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
  return createSlotTrackingStream(
    rpcRequest: rpcRequest,
    rpcSubscription: rpcSubscription,
    rpcValueMapper: rpcValueMapper,
    rpcSubscriptionValueMapper: rpcSubscriptionValueMapper,
  );
}
