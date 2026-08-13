import 'dart:async';

import 'package:solana_kit/solana_kit.dart';
import 'package:test/test.dart';

void main() {
  group('createReactiveStoreWithInitialValueAndSlotTracking', () {
    test('starts idle and does not create sources before connect', () {
      final fixture = _Fixture();

      expect(fixture.store.getState().status, ReactiveStreamState.idle);
      expect(fixture.store.getState().data, isNull);
      expect(fixture.store.getState().error, isNull);
      expect(fixture.initial.storesCreated, 0);
      expect(fixture.stream.storesCreated, 0);

      fixture.store.dispose();
    });

    test(
      'connect starts both sources and creates fresh stores on reconnect',
      () async {
        final fixture = _Fixture();

        fixture.store.connect();
        final firstInitialSignal = fixture.initial.instances.single.signal;
        final firstStreamSignal = fixture.stream.instances.single.signal;

        expect(fixture.store.getState().status, ReactiveStreamState.loading);
        expect(firstInitialSignal.isCancelled, isFalse);
        expect(firstStreamSignal.isCancelled, isFalse);

        fixture.store.connect();
        await _flushEvents();

        expect(fixture.initial.storesCreated, 2);
        expect(fixture.stream.storesCreated, 2);
        expect(fixture.initial.instances, hasLength(2));
        expect(fixture.stream.instances, hasLength(2));
        expect(firstInitialSignal.isCancelled, isTrue);
        expect(firstStreamSignal.isCancelled, isTrue);

        fixture.store.dispose();
      },
    );

    test('loads and maps the initial value', () async {
      final fixture = _Fixture()..store.connect();

      fixture.initial.instances.single.complete(_response(10, 'first'));
      await _flushEvents();

      _expectLoaded(fixture.store, slot: 10, value: 'initial:first');
      fixture.store.dispose();
    });

    test(
      'loads stream values and accepts an update at the same slot',
      () async {
        final fixture = _Fixture()..store.connect();

        fixture.stream.instances.single.emit(_response(10, 1));
        await _flushEvents();
        _expectLoaded(fixture.store, slot: 10, value: 'stream:1');

        fixture.stream.instances.single.emit(_response(10, 2));
        await _flushEvents();
        _expectLoaded(fixture.store, slot: 10, value: 'stream:2');

        fixture.store.dispose();
      },
    );

    test(
      'ignores an older value without notifying after already loaded',
      () async {
        final fixture = _Fixture()..store.connect();
        fixture.initial.instances.single.complete(_response(20, 'new'));
        await _flushEvents();

        var notifications = 0;
        fixture.store.subscribe(() => notifications++);
        fixture.stream.instances.single.emit(_response(19, 1));
        await _flushEvents();

        _expectLoaded(fixture.store, slot: 20, value: 'initial:new');
        expect(notifications, 0);
        fixture.store.dispose();
      },
    );

    test(
      'keeps a newer stream value when the initial value arrives later',
      () async {
        final fixture = _Fixture()..store.connect();

        fixture.stream.instances.single.emit(_response(20, 2));
        await _flushEvents();
        fixture.initial.instances.single.complete(_response(10, 'stale'));
        await _flushEvents();

        _expectLoaded(fixture.store, slot: 20, value: 'stream:2');
        fixture.store.dispose();
      },
    );

    test('preserves data and error while reconnecting', () async {
      final fixture = _Fixture()..store.connect();
      fixture.initial.instances.single.complete(_response(100, 'current'));
      await _flushEvents();
      final failure = StateError('stream failed');
      fixture.stream.instances.single.emitError(failure);
      await _flushEvents();

      fixture.store.connect();
      final state = fixture.store.getState();

      expect(state.status, ReactiveStreamState.loading);
      expect(state.data?.context.slot, BigInt.from(100));
      expect(state.data?.value, 'initial:current');
      expect(state.error, same(failure));
      fixture.store.dispose();
    });

    test(
      'stale initial response settles a reconnect without regressing data',
      () async {
        final fixture = _Fixture()..store.connect();
        fixture.initial.instances[0].complete(_response(100, 'current'));
        await _flushEvents();
        fixture.stream.instances[0].emitError(StateError('old failure'));
        await _flushEvents();

        fixture.store.connect();
        expect(fixture.store.getState().error, isNotNull);
        var notifications = 0;
        fixture.store.subscribe(() => notifications++);
        fixture.initial.instances[1].complete(_response(99, 'stale'));
        await _flushEvents();

        _expectLoaded(fixture.store, slot: 100, value: 'initial:current');
        expect(notifications, 1);
        fixture.store.dispose();
      },
    );

    test(
      'stale stream response settles a reconnect without regressing data',
      () async {
        final fixture = _Fixture()..store.connect();
        fixture.stream.instances[0].emit(_response(100, 10));
        await _flushEvents();

        fixture.store.connect();
        fixture.stream.instances[1].emit(_response(99, 9));
        await _flushEvents();

        _expectLoaded(fixture.store, slot: 100, value: 'stream:10');
        fixture.store.dispose();
      },
    );

    test('keeps the maximum slot across reconnects', () async {
      final fixture = _Fixture()..store.connect();
      fixture.initial.instances[0].complete(_response(100, 'first'));
      await _flushEvents();

      fixture.store.connect();
      fixture.initial.instances[1].complete(_response(99, 'stale'));
      await _flushEvents();
      fixture.stream.instances[1].emit(_response(101, 11));
      await _flushEvents();

      _expectLoaded(fixture.store, slot: 101, value: 'stream:11');
      fixture.store.dispose();
    });

    test('captures only the first error in a connection window', () async {
      final fixture = _Fixture()..store.connect();
      final firstError = StateError('stream failed first');
      final secondError = ArgumentError('initial failed later');

      fixture.stream.instances.single.emitError(firstError);
      await _flushEvents();
      fixture.initial.instances.single.completeError(secondError);
      await _flushEvents();

      final state = fixture.store.getState();
      expect(state.status, ReactiveStreamState.error);
      expect(state.error, same(firstError));
      expect(state.data, isNull);
      fixture.store.dispose();
    });

    test('preserves loaded data when the first error occurs', () async {
      final fixture = _Fixture()..store.connect();
      fixture.stream.instances.single.emit(_response(10, 1));
      await _flushEvents();
      final failure = StateError('initial failed');
      fixture.initial.instances.single.completeError(failure);
      await _flushEvents();

      final state = fixture.store.getState();
      expect(state.status, ReactiveStreamState.error);
      expect(state.error, same(failure));
      expect(state.data?.value, 'stream:1');
      fixture.store.dispose();
    });

    test(
      'reset cancels the window and clears state and slot tracking',
      () async {
        final fixture = _Fixture()..store.connect();
        fixture.initial.instances[0].complete(_response(100, 'high'));
        await _flushEvents();
        final oldInitialSignal = fixture.initial.instances[0].signal;
        final oldStreamSignal = fixture.stream.instances[0].signal;

        fixture.store.reset();
        await _flushEvents();

        expect(fixture.store.getState().status, ReactiveStreamState.idle);
        expect(fixture.store.getState().data, isNull);
        expect(fixture.store.getState().error, isNull);
        expect(oldInitialSignal.isCancelled, isTrue);
        expect(oldStreamSignal.isCancelled, isTrue);

        fixture.store.connect();
        fixture.initial.instances[1].complete(_response(1, 'low'));
        await _flushEvents();
        _expectLoaded(fixture.store, slot: 1, value: 'initial:low');
        fixture.store.dispose();
      },
    );

    test(
      'caller cancellation propagates its reason and blocks late values',
      () async {
        final fixture = _Fixture();
        final caller = CancellationTokenSource();
        final reason = StateError('timed out');
        fixture.store.withSignal(caller.token)();
        final initialInstance = fixture.initial.instances.single;
        final streamInstance = fixture.stream.instances.single;

        caller.cancel(reason);
        await _flushEvents();

        final state = fixture.store.getState();
        expect(state.status, ReactiveStreamState.error);
        expect(state.error, same(reason));
        expect(initialInstance.signal.isCancelled, isTrue);
        expect(initialInstance.signal.reason, same(reason));
        expect(streamInstance.signal.isCancelled, isTrue);
        expect(streamInstance.signal.reason, same(reason));

        initialInstance.complete(_response(10, 'late'));
        streamInstance.emit(_response(11, 11));
        await _flushEvents();
        expect(fixture.store.getState().data, isNull);
        expect(fixture.store.getState().error, same(reason));
        fixture.store.dispose();
      },
    );

    test('an already cancelled caller does not start either source', () {
      final fixture = _Fixture();
      final caller = CancellationTokenSource();
      final reason = StateError('already cancelled');
      caller.cancel(reason);

      fixture.store.withSignal(caller.token)();

      expect(fixture.store.getState().status, ReactiveStreamState.error);
      expect(fixture.store.getState().error, same(reason));
      expect(fixture.initial.storesCreated, 0);
      expect(fixture.stream.storesCreated, 0);
      fixture.store.dispose();
    });

    test('unsubscribe is idempotent and stops notifications', () async {
      final fixture = _Fixture()..store.connect();
      var notifications = 0;
      final unsubscribe = fixture.store.subscribe(() => notifications++);

      unsubscribe();
      unsubscribe();
      fixture.initial.instances.single.complete(_response(10, 'value'));
      await _flushEvents();

      expect(notifications, 0);
      fixture.store.dispose();
    });

    test('surfaces a mapper failure as an error state', () async {
      final initial = _InitialValueSource();
      final stream = _StreamSource();
      final store = createReactiveStoreWithInitialValueAndSlotTracking(
        initialValueSource: initial,
        streamSource: stream,
        initialValueMapper: (value) => throw StateError('mapper boom'),
        streamValueMapper: (value) => 'stream:$value',
      );
      store.connect(); // ignore: cascade_invocations

      initial.instances.single.complete(_response(10, 'value'));
      await _flushEvents();

      expect(store.getState().status, ReactiveStreamState.error);
      expect(store.getState().error, isA<StateError>());
      store.dispose();
    });
  });
}

class _Fixture {
  _Fixture() : initial = _InitialValueSource(), stream = _StreamSource() {
    store = createReactiveStoreWithInitialValueAndSlotTracking(
      initialValueSource: initial,
      streamSource: stream,
      initialValueMapper: (value) => 'initial:$value',
      streamValueMapper: (value) => 'stream:$value',
    );
  }

  final _InitialValueSource initial;
  final _StreamSource stream;
  late final ReactiveStreamStore<SolanaRpcResponse<String>> store;
}

class _InitialValueSource
    implements ReactiveActionSource<SolanaRpcResponse<String>> {
  final List<_InitialValueInstance> instances = [];
  int storesCreated = 0;

  @override
  ReactiveActionStore<List<Object?>, SolanaRpcResponse<String>>
  reactiveStore() {
    storesCreated++;
    return createReactiveActionStore((signal, _) {
      final instance = _InitialValueInstance(signal);
      instances.add(instance);
      return instance.future;
    });
  }
}

class _InitialValueInstance {
  _InitialValueInstance(this.signal);

  final CancellationToken signal;
  final Completer<SolanaRpcResponse<String>> _completer = Completer();

  Future<SolanaRpcResponse<String>> get future => _completer.future;

  void complete(SolanaRpcResponse<String> response) {
    if (!_completer.isCompleted) _completer.complete(response);
  }

  void completeError(Object error) {
    if (!_completer.isCompleted) _completer.completeError(error);
  }
}

class _StreamSource implements ReactiveStreamSource<SolanaRpcResponse<int>> {
  final List<_StreamInstance> instances = [];
  int storesCreated = 0;

  @override
  ReactiveStreamStore<SolanaRpcResponse<int>> reactiveStore() {
    storesCreated++;
    return createReactiveStreamStore(
      createDataPublisher: (signal) async {
        final instance = _StreamInstance(signal);
        instances.add(instance);
        return ReactiveStreamConnection(
          dataStream: instance.data.stream,
          errorStream: instance.errors.stream,
        );
      },
    );
  }
}

class _StreamInstance {
  _StreamInstance(this.signal);

  final CancellationToken signal;
  final StreamController<SolanaRpcResponse<int>> data = StreamController();
  final StreamController<Object?> errors = StreamController();

  void emit(SolanaRpcResponse<int> response) => data.add(response);

  void emitError(Object error) => errors.add(error);
}

void _expectLoaded(
  ReactiveStreamStore<SolanaRpcResponse<String>> store, {
  required int slot,
  required String value,
}) {
  final state = store.getState();
  expect(state.status, ReactiveStreamState.loaded);
  expect(state.error, isNull);
  expect(state.data?.context.slot, BigInt.from(slot));
  expect(state.data?.value, value);
}

Future<void> _flushEvents() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

SolanaRpcResponse<T> _response<T>(int slot, T value) {
  return SolanaRpcResponse<T>(
    context: RpcResponseContext(slot: BigInt.from(slot)),
    value: value,
  );
}
