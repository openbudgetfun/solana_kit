import 'dart:async';

import 'package:solana_kit/src/slot_tracking_stream.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

/// Creates a caller-driven reactive store that combines a one-shot initial
/// value with ongoing subscription updates.
///
/// Values from both sources are compared by slot. A value older than the most
/// recently accepted slot cannot replace the current data. Call [ReactiveStreamStore.connect]
/// to build fresh inner stores and start both sources for a connection window.
ReactiveStreamStore<SolanaRpcResponse<TItem>>
createReactiveStoreWithInitialValueAndSlotTracking<
  TInitialValue,
  TStreamValue,
  TItem
>({
  required ReactiveActionSource<SolanaRpcResponse<TInitialValue>>
  initialValueSource,
  required ReactiveStreamSource<SolanaRpcResponse<TStreamValue>> streamSource,
  required SlotTrackingValueMapper<TInitialValue, TItem> initialValueMapper,
  required SlotTrackingValueMapper<TStreamValue, TItem> streamValueMapper,
}) {
  var lastUpdateSlot = BigInt.from(-1);
  late ReactiveStreamStore<SolanaRpcResponse<TItem>> store;

  return store = createReactiveStreamStore<SolanaRpcResponse<TItem>>(
    createDataPublisher: (connectionSignal) async {
      // A reset clears the outer data. Start a new slot window in that case;
      // ordinary reconnects retain the maximum accepted slot.
      if (store.getState().data == null) {
        lastUpdateSlot = BigInt.from(-1);
      }

      final dataController = StreamController<SolanaRpcResponse<TItem>>();
      final errorController = StreamController<Object?>();
      final innerSource = CancellationTokenSource();
      final actionStore = initialValueSource.reactiveStore();
      final streamStore = streamSource.reactiveStore();

      var hasFailed = false;
      // The closures are reassigned below; `var` would infer `Null Function()`.
      // ignore: omit_local_variable_types
      void Function() unsubscribeAction = () {};
      // ignore: omit_local_variable_types
      void Function() unsubscribeStream = () {};

      void cleanUp() {
        unsubscribeAction();
        unsubscribeStream();
        actionStore.dispose();
        streamStore.dispose();
        if (!dataController.isClosed) {
          unawaited(dataController.close());
        }
        if (!errorController.isClosed) {
          unawaited(errorController.close());
        }
      }

      if (connectionSignal.isCancelled) {
        // The publisher runs synchronously with a fresh per-connection signal,
        // so this branch is defensive dead code.
        innerSource.cancel(connectionSignal.reason); // coverage:ignore-line
      } else {
        unawaited(
          connectionSignal.future.then(
            (_) => innerSource.cancel(connectionSignal.reason),
          ),
        );
      }

      void handleError(Object error) {
        if (hasFailed || innerSource.token.isCancelled) return;
        hasFailed = true;
        errorController.add(error);
        innerSource.cancel(error);
      }

      void handleSlottedValue<TValue>(
        SolanaRpcResponse<TValue> response,
        SlotTrackingValueMapper<TValue, TItem> mapper,
      ) {
        if (hasFailed || innerSource.token.isCancelled) return;

        final slot = response.context.slot;
        if (slot < lastUpdateSlot) {
          final outerState = store.getState();
          if (outerState.status == ReactiveStreamState.loading &&
              outerState.data != null) {
            // A stale response still proves that this refresh completed.
            // Settle loading without regressing the retained data.
            dataController.add(outerState.data!);
          }
          return;
        }

        try {
          final value = mapper(response.value);
          lastUpdateSlot = slot;
          dataController.add(
            SolanaRpcResponse<TItem>(
              context: response.context,
              value: value,
            ),
          );
        } on Object catch (error) {
          handleError(error);
        }
      }

      unsubscribeAction = actionStore.subscribe(() {
        final state = actionStore.getState();
        switch (state.status) {
          case ReactiveActionState.success:
            handleSlottedValue(state.result!, initialValueMapper);
          case ReactiveActionState.error:
            final error = state.error;
            if (error != null) handleError(error);
          case ReactiveActionState.idle:
          case ReactiveActionState.running:
            break;
        }
      });
      unsubscribeStream = streamStore.subscribe(() {
        final state = streamStore.getState();
        switch (state.status) {
          case ReactiveStreamState.loaded:
            handleSlottedValue(state.data!, streamValueMapper);
          case ReactiveStreamState.error:
            final error = state.error;
            if (error != null) handleError(error);
          case ReactiveStreamState.idle:
          case ReactiveStreamState.loading:
            break;
        }
      });

      if (!innerSource.token.isCancelled) {
        streamStore.withSignal(innerSource.token)();
        actionStore.withSignal(innerSource.token).dispatch(const []);
      }
      // Register cleanup after the inner stores have attached their cancellation
      // listeners so they observe the original reason before disposal.
      unawaited(innerSource.token.future.then((_) => cleanUp()));

      return ReactiveStreamConnection<SolanaRpcResponse<TItem>>(
        dataStream: dataController.stream,
        errorStream: errorController.stream,
      );
    },
  );
}
