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
    test('cancels while waiting for the first store value', () async {
      final store = _storeWith(
        const Stream<int>.empty(),
        const Stream<Object?>.empty(),
      );
      addTearDown(store.dispose);
      final subscription = bridgeStoreToAsyncIterable(store).listen((_) {});
      await Future<void>.delayed(Duration.zero);

      await subscription.cancel().timeout(const Duration(milliseconds: 100));
    });

    test('unsubscribes when the initial predicate throws', () async {
      final data = StreamController<int>.broadcast(sync: true);
      final store = _storeWith(data.stream, const Stream<Object?>.empty());
      addTearDown(data.close);
      addTearDown(store.dispose);
      store.connect();
      await Future<void>.delayed(Duration.zero);
      data.add(1);
      var predicateCalls = 0;
      final failure = StateError('invalid initial value');
      final stream = bridgeStoreToAsyncIterable(
        store,
        shouldYield: (_) {
          predicateCalls++;
          throw failure;
        },
      );

      await expectLater(stream, emitsError(same(failure)));
      data.add(2);
      expect(predicateCalls, 1);
    });

    test('delivers subsequent predicate failures to the stream', () async {
      final data = StreamController<int>.broadcast(sync: true);
      final store = _storeWith(data.stream, const Stream<Object?>.empty());
      addTearDown(data.close);
      addTearDown(store.dispose);
      final failure = StateError('invalid notification');
      final streamErrors = <Object>[];
      final zoneErrors = <Object>[];
      final done = Completer<void>();
      StreamSubscription<int>? subscription;

      runZonedGuarded(() {
        store.connect();
        subscription = bridgeStoreToAsyncIterable(
          store,
          shouldYield: (_) => throw failure,
        ).listen((_) {}, onError: streamErrors.add, onDone: done.complete);
      }, (error, _) => zoneErrors.add(error));
      await Future<void>.delayed(Duration.zero);
      data.add(1);
      await Future<void>.delayed(Duration.zero);

      expect(zoneErrors, isEmpty);
      expect(streamErrors, [same(failure)]);
      await done.future.timeout(const Duration(milliseconds: 100));
      await subscription?.cancel();
    });

    test('keeps only the newest update while the consumer is paused', () async {
      final data = StreamController<int>.broadcast(sync: true);
      final store = _storeWith(data.stream, const Stream<Object?>.empty());
      addTearDown(data.close);
      addTearDown(store.dispose);
      store.connect();
      await Future<void>.delayed(Duration.zero);
      var predicateCalls = 0;
      final values = <int>[];
      final subscription = bridgeStoreToAsyncIterable(
        store,
        shouldYield: (_) {
          predicateCalls++;
          return true;
        },
      ).listen(values.add);
      await Future<void>.delayed(Duration.zero);
      subscription.pause();
      data.add(1);
      await Future<void>.delayed(Duration.zero);
      data.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(values, isEmpty);

      subscription.resume();
      await Future<void>.delayed(Duration.zero);
      expect(values, [2]);
      await subscription.cancel();
      data.add(3);
      expect(predicateCalls, 2);
    });

    test(
      'an error takes precedence over a value buffered while paused',
      () async {
        final data = StreamController<int>.broadcast(sync: true);
        final errors = StreamController<Object?>.broadcast(sync: true);
        final store = _storeWith(data.stream, errors.stream);
        addTearDown(data.close);
        addTearDown(errors.close);
        addTearDown(store.dispose);
        store.connect();
        await Future<void>.delayed(Duration.zero);
        final failure = Exception('connection failed');
        final received = <Object>[];
        final done = Completer<void>();
        final subscription = bridgeStoreToAsyncIterable(store).listen(
          received.add,
          onError: received.add,
          onDone: done.complete,
        );
        await Future<void>.delayed(Duration.zero);
        subscription.pause();
        data.add(1);
        errors.add(failure);
        await Future<void>.delayed(Duration.zero);
        expect(received, isEmpty);

        subscription.resume();
        await done.future.timeout(const Duration(milliseconds: 100));
        expect(received, [same(failure)]);
        await subscription.cancel();
      },
    );

    test(
      'immediate token cancellation wins over the initial snapshot',
      () async {
        final data = StreamController<int>.broadcast(sync: true);
        final store = _storeWith(data.stream, const Stream<Object?>.empty());
        addTearDown(data.close);
        addTearDown(store.dispose);
        store.connect();
        await Future<void>.delayed(Duration.zero);
        data.add(1);
        final source = CancellationTokenSource();
        final values = <int>[];
        final done = Completer<void>();
        final subscription = bridgeStoreToAsyncIterable(
          store,
          cancellationToken: source.token,
        ).listen(values.add, onDone: done.complete);

        source.cancel();
        await done.future.timeout(const Duration(milliseconds: 100));
        expect(values, isEmpty);
        await subscription.cancel();
      },
    );

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
