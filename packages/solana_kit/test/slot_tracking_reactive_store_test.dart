import 'dart:async';

import 'package:solana_kit/solana_kit.dart';
import 'package:test/test.dart';

void main() {
  group('createSlotTrackingReactiveStore', () {
    test(
      'starts empty and tracks the newest slot across both sources',
      () async {
        final rpcCompleter = Completer<SolanaRpcResponse<String>>();
        final subscription = StreamController<SolanaRpcResponse<int>>();
        final store = createSlotTrackingReactiveStore<String, int, String>(
          rpcRequest: rpcCompleter.future,
          rpcSubscription: subscription.stream,
          rpcValueMapper: (value) => 'rpc:$value',
          rpcSubscriptionValueMapper: (value) => 'sub:$value',
        );
        final states = <SolanaRpcResponse<String>?>[];
        final unsubscribe = store.subscribe(() => states.add(store.getState()));

        expect(store.getState(), isNull);
        expect(store.getError(), isNull);

        subscription.add(_response(2, 20));
        await _flushEvents();
        rpcCompleter.complete(_response(1, 'initial'));
        await _flushEvents();
        subscription.add(_response(2, 22));
        await _flushEvents();
        subscription.add(_response(1, 10));
        await _flushEvents();
        subscription.add(_response(3, 30));
        await _flushEvents();

        expect(states, [
          _response(2, 'sub:20'),
          _response(2, 'sub:22'),
          _response(3, 'sub:30'),
        ]);
        expect(store.getState(), _response(3, 'sub:30'));

        unsubscribe();
        unsubscribe();
        subscription.add(_response(4, 40));
        await _flushEvents();

        expect(states, hasLength(3));
        store.dispose();
      },
    );

    test(
      'captures the first error and disconnects from later updates',
      () async {
        final rpcCompleter = Completer<SolanaRpcResponse<String>>();
        final subscription = StreamController<SolanaRpcResponse<int>>();
        final store = createSlotTrackingReactiveStore<String, int, String>(
          rpcRequest: rpcCompleter.future,
          rpcSubscription: subscription.stream,
          rpcValueMapper: (value) => 'rpc:$value',
          rpcSubscriptionValueMapper: (value) => 'sub:$value',
        );
        var notifications = 0;
        store.subscribe(() => notifications++);

        subscription.add(_response(1, 10));
        await _flushEvents();
        subscription.addError(StateError('boom'));
        await _flushEvents();
        rpcCompleter.completeError(ArgumentError('ignored'));
        subscription.add(_response(2, 20));
        await _flushEvents();

        expect(notifications, 2);
        expect(store.getState(), _response(1, 'sub:10'));
        expect(store.getError(), isA<StateError>());

        store.dispose();
      },
    );

    test('dispose is idempotent and cancels subscription updates', () async {
      var canceled = false;
      final store = createSlotTrackingReactiveStore<String, int, String>(
        rpcRequest: Future.value(_response(1, 'initial')),
        rpcSubscription: Stream<SolanaRpcResponse<int>>.multi((controller) {
          controller.onCancel = () {
            canceled = true;
          };
        }),
        rpcValueMapper: (value) => 'rpc:$value',
        rpcSubscriptionValueMapper: (value) => 'sub:$value',
      );

      final disposeStore = store.dispose;
      disposeStore();
      disposeStore();
      await _flushEvents();

      var called = false;
      store.subscribe(() => called = true)();

      expect(canceled, isTrue);
      expect(called, isFalse);
      expect(store.getState(), isNull);
    });
  });

  group('createReactiveStoreWithInitialValueAndSlotTracking', () {
    test('aliases createSlotTrackingReactiveStore', () async {
      final store =
          createReactiveStoreWithInitialValueAndSlotTracking<
            String,
            int,
            String
          >(
            rpcRequest: Future.value(_response(1, 'initial')),
            rpcSubscription: const Stream<SolanaRpcResponse<int>>.empty(),
            rpcValueMapper: (value) => value,
            rpcSubscriptionValueMapper: (value) => '$value',
          );
      await _flushEvents();

      expect(store.getState(), _response(1, 'initial'));
      store.dispose();
    });
  });
}

Future<void> _flushEvents() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

SolanaRpcResponse<T> _response<T>(int slot, T value) {
  return SolanaRpcResponse<T>(
    context: RpcResponseContext(slot: BigInt.from(slot)),
    value: value,
  );
}
