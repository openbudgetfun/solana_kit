// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

ReactiveStreamStore<int> _storeWith(Stream<int> data, Stream<Object?> errors) {
  return createReactiveStreamStore<int>(
    createDataPublisher: (_) async => ReactiveStreamConnection<int>(
      dataStream: data,
      errorStream: errors,
    ),
  );
}

void main() {
  group('bridgeStoreToAsyncIterable', () {
    test('yields loaded values from the store', () async {
      final dataController = StreamController<int>.broadcast(sync: true);
      final store = _storeWith(
        dataController.stream,
        const Stream<Object?>.empty(),
      );
      store.connect();
      await Future<void>.delayed(Duration.zero);
      final stream = bridgeStoreToAsyncIterable(store);
      final values = <int>[];
      final sub = stream.listen(values.add);
      dataController.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      dataController.add(2);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      unawaited(sub.cancel());
      await dataController.close();
      store.dispose();
      expect(values, containsAll([1, 2]));
    });

    test('applies the shouldYield predicate', () async {
      final dataController = StreamController<int>.broadcast(sync: true);
      final store = _storeWith(
        dataController.stream,
        const Stream<Object?>.empty(),
      );
      store.connect();
      await Future<void>.delayed(Duration.zero);
      final stream = bridgeStoreToAsyncIterable(
        store,
        shouldYield: (value) => value.isEven,
      );
      final values = <int>[];
      final sub = stream.listen(values.add);
      dataController
        ..add(1)
        ..add(2);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      unawaited(sub.cancel());
      await dataController.close();
      store.dispose();
      expect(values, contains(2));
      expect(values, isNot(contains(1)));
    });

    test('throws the store error', () async {
      final errorController = StreamController<Object?>.broadcast(sync: true);
      final store = _storeWith(
        const Stream<int>.empty(),
        errorController.stream,
      );
      store.connect();
      await Future<void>.delayed(Duration.zero);
      final stream = bridgeStoreToAsyncIterable(store);
      final errors = <Object>[];
      final sub = stream.listen((_) {}, onError: errors.add);
      errorController.add(StateError('boom'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      unawaited(sub.cancel());
      await errorController.close();
      store.dispose();
      expect(errors, hasLength(1));
      expect(errors.single, isA<StateError>());
    });

    test('rethrows an Exception store error', () async {
      final errorController = StreamController<Object?>.broadcast(sync: true);
      final store = _storeWith(
        const Stream<int>.empty(),
        errorController.stream,
      );
      store.connect();
      await Future<void>.delayed(Duration.zero);
      final stream = bridgeStoreToAsyncIterable(store);
      final errors = <Object>[];
      final sub = stream.listen((_) {}, onError: errors.add);
      errorController.add(Exception('boom'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      unawaited(sub.cancel());
      await errorController.close();
      store.dispose();
      expect(errors, hasLength(1));
      expect(errors.single, isA<Exception>());
    });

    test('wraps a non-Error non-Exception store error in StateError', () async {
      final errorController = StreamController<Object?>.broadcast(sync: true);
      final store = _storeWith(
        const Stream<int>.empty(),
        errorController.stream,
      );
      store.connect();
      await Future<void>.delayed(Duration.zero);
      final stream = bridgeStoreToAsyncIterable(store);
      final errors = <Object>[];
      final sub = stream.listen((_) {}, onError: errors.add);
      errorController.add('boom');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      unawaited(sub.cancel());
      await errorController.close();
      store.dispose();
      expect(errors, hasLength(1));
      expect(errors.single, isA<StateError>());
    });

    test('ends cleanly when the cancellation token fires', () async {
      final dataController = StreamController<int>.broadcast(sync: true);
      final store = _storeWith(
        dataController.stream,
        const Stream<Object?>.empty(),
      );
      store.connect();
      await Future<void>.delayed(Duration.zero);
      final source = CancellationTokenSource();
      final stream = bridgeStoreToAsyncIterable(
        store,
        cancellationToken: source.token,
      );
      final values = <int>[];
      final sub = stream.listen(values.add);
      dataController.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      source.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(values, contains(1));
      unawaited(sub.cancel());
      await dataController.close();
      store.dispose();
    });
  });
}
