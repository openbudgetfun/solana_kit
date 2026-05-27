import 'dart:async';

import 'package:solana_kit/solana_kit.dart';
import 'package:test/test.dart';

void main() {
  group('createSlotTrackingStream', () {
    test(
      'yields initial RPC value and subscription updates in slot order',
      () async {
        final subscription = StreamController<SolanaRpcResponse<int>>();
        final rpcCompleter = Completer<SolanaRpcResponse<String>>();
        final stream = createSlotTrackingStream<String, int, String>(
          rpcRequest: rpcCompleter.future,
          rpcSubscription: subscription.stream,
          rpcValueMapper: (value) => 'rpc:$value',
          rpcSubscriptionValueMapper: (value) => 'sub:$value',
        );
        final values = <SolanaRpcResponse<String>>[];
        final done = stream.listen(values.add).asFuture<void>();

        subscription.add(_response(2, 20));
        rpcCompleter.complete(_response(1, 'initial'));
        subscription.add(_response(3, 30));
        await subscription.close();
        await done;

        expect(values, [_response(2, 'sub:20'), _response(3, 'sub:30')]);
      },
    );

    test(
      'yields queued RPC value when it arrives before listening pull',
      () async {
        final stream = createSlotTrackingStream<String, int, String>(
          rpcRequest: Future.value(_response(5, 'initial')),
          rpcSubscription: const Stream<SolanaRpcResponse<int>>.empty(),
          rpcValueMapper: (value) => 'rpc:$value',
          rpcSubscriptionValueMapper: (value) => 'sub:$value',
        );

        expect(await stream.toList(), [_response(5, 'rpc:initial')]);
      },
    );

    test('forwards RPC errors', () async {
      final rpcCompleter = Completer<SolanaRpcResponse<String>>();
      final stream = createSlotTrackingStream<String, int, String>(
        rpcRequest: rpcCompleter.future,
        rpcSubscription: const Stream<SolanaRpcResponse<int>>.empty(),
        rpcValueMapper: (value) => value,
        rpcSubscriptionValueMapper: (value) => '$value',
      );

      final values = stream.toList();
      rpcCompleter.completeError(StateError('boom'));

      expect(values, throwsA(isA<StateError>()));
    });

    test('canceling stream cancels subscription', () async {
      var canceled = false;
      final subscription = Stream<SolanaRpcResponse<int>>.periodic(
        Duration.zero,
        (_) => _response(1, 1),
      ).listen(null);
      await subscription.cancel();
      final stream = createSlotTrackingStream<String, int, String>(
        rpcRequest: Future.value(_response(1, 'initial')),
        rpcSubscription: Stream<SolanaRpcResponse<int>>.multi((controller) {
          controller.onCancel = () {
            canceled = true;
          };
        }),
        rpcValueMapper: (value) => value,
        rpcSubscriptionValueMapper: (value) => '$value',
      );

      final streamSubscription = stream.listen(null);
      await streamSubscription.cancel();

      expect(canceled, isTrue);
    });
  });

  group('createAsyncGeneratorWithInitialValueAndSlotTracking', () {
    test('aliases createSlotTrackingStream', () async {
      final stream =
          createAsyncGeneratorWithInitialValueAndSlotTracking<
            String,
            int,
            String
          >(
            rpcRequest: Future.value(_response(1, 'initial')),
            rpcSubscription: const Stream<SolanaRpcResponse<int>>.empty(),
            rpcValueMapper: (value) => value,
            rpcSubscriptionValueMapper: (value) => '$value',
          );

      expect(await stream.toList(), [_response(1, 'initial')]);
    });
  });
}

SolanaRpcResponse<T> _response<T>(int slot, T value) {
  return SolanaRpcResponse<T>(
    context: RpcResponseContext(slot: BigInt.from(slot)),
    value: value,
  );
}
