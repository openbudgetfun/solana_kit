import 'dart:async';

import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('getRpcSubscriptionsTransportWithSubscriptionCoalescing', () {
    late _MockTransport mockInnerTransport;
    late RpcSubscriptionsTransport coalescedTransport;

    void receiveError([Object? err]) {
      for (final mockOn in mockInnerTransport.mockOns) {
        mockOn.fireError(err);
      }
    }

    setUp(() {
      mockInnerTransport = _MockTransport();
      coalescedTransport =
          getRpcSubscriptionsTransportWithSubscriptionCoalescing(
            mockInnerTransport.transport,
          );
    });

    test('returns the inner transport', () async {
      final config = RpcSubscriptionsTransportConfig(
        execute: (_) async => createDataPublisher(),
        request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
        signal: AbortController().signal,
      );

      final result = await coalescedTransport(config);
      // The result should be the WrappedDataPublisher created by the mock.
      expect(result, same(mockInnerTransport.lastWrappedPublisher));
    });

    test('passes the execute config to the inner transport', () {
      Future<DataPublisher> execute(
        RpcSubscriptionsTransportExecuteConfig config,
      ) async {
        return createDataPublisher();
      }

      final config = RpcSubscriptionsTransportConfig(
        execute: execute,
        request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
        signal: AbortController().signal,
      );

      coalescedTransport(config).ignore();

      expect(mockInnerTransport.callCount, equals(1));
      expect(mockInnerTransport.lastConfig?.execute, same(execute));
    });

    test('passes the rpcRequest config to the inner transport', () {
      final config = RpcSubscriptionsTransportConfig(
        execute: (_) async => createDataPublisher(),
        request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
        signal: AbortController().signal,
      );

      coalescedTransport(config).ignore();

      expect(mockInnerTransport.lastConfig?.request.methodName, 'foo');
    });

    test('calls the inner transport once per subscriber whose hashes do not '
        'match, in the same runloop', () {
      Future<DataPublisher> execute(
        RpcSubscriptionsTransportExecuteConfig config,
      ) async {
        return createDataPublisher();
      }

      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: execute,
          request: const RpcSubscriptionsRequest(
            methodName: 'methodA',
            params: [],
          ),
          signal: AbortController().signal,
        ),
      ).ignore();
      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: execute,
          request: const RpcSubscriptionsRequest(
            methodName: 'methodB',
            params: [],
          ),
          signal: AbortController().signal,
        ),
      ).ignore();

      expect(mockInnerTransport.callCount, equals(2));
    });

    test('calls the inner transport once per subscriber whose hashes do not '
        'match, in different runloops', () async {
      Future<DataPublisher> execute(
        RpcSubscriptionsTransportExecuteConfig config,
      ) async {
        return createDataPublisher();
      }

      await coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: execute,
          request: const RpcSubscriptionsRequest(
            methodName: 'methodA',
            params: [],
          ),
          signal: AbortController().signal,
        ),
      );
      await coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: execute,
          request: const RpcSubscriptionsRequest(
            methodName: 'methodB',
            params: [],
          ),
          signal: AbortController().signal,
        ),
      );

      expect(mockInnerTransport.callCount, equals(2));
    });

    test('only calls the inner transport once, in the same runloop', () {
      final config = RpcSubscriptionsTransportConfig(
        execute: (_) async => createDataPublisher(),
        request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
        signal: AbortController().signal,
      );

      coalescedTransport(config).ignore();
      coalescedTransport(config).ignore();

      expect(mockInnerTransport.callCount, equals(1));
    });

    test(
      'only calls the inner transport once, in different runloops',
      () async {
        final config = RpcSubscriptionsTransportConfig(
          execute: (_) async => createDataPublisher(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: AbortController().signal,
        );

        await coalescedTransport(config);
        await coalescedTransport(config);

        expect(mockInnerTransport.callCount, equals(1));
      },
    );

    test(
      'delivers the same value to each subscriber, in the same runloop',
      () async {
        final config = RpcSubscriptionsTransportConfig(
          execute: (_) async => createDataPublisher(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: AbortController().signal,
        );

        final results = await Future.wait([
          coalescedTransport(config),
          coalescedTransport(config),
        ]);

        expect(results[0], same(results[1]));
      },
    );

    test(
      'delivers the same value to each subscriber, in different runloops',
      () async {
        final config = RpcSubscriptionsTransportConfig(
          execute: (_) async => createDataPublisher(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: AbortController().signal,
        );

        final publisherA = await coalescedTransport(config);
        final publisherB = await coalescedTransport(config);

        expect(publisherA, same(publisherB));
      },
    );

    test('does not fire the inner abort signal if fewer than all subscribers '
        'abort, in the same runloop', () async {
      final config = RpcSubscriptionsTransportConfig(
        execute: (_) async => createDataPublisher(),
        request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
        signal: AbortController().signal,
      );

      final abortControllerB = AbortController();
      coalescedTransport(config).ignore();
      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: config.execute,
          request: config.request,
          signal: abortControllerB.signal,
        ),
      ).ignore();

      abortControllerB.abort();

      // Run all microtasks.
      await Future<void>.delayed(Duration.zero);

      expect(mockInnerTransport.lastConfig?.signal.isAborted, isFalse);
    });

    test('fires the inner abort signal if all subscribers abort, in the same '
        'runloop', () async {
      final abortControllerA = AbortController();
      final abortControllerB = AbortController();

      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: (_) async => createDataPublisher(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: abortControllerA.signal,
        ),
      ).ignore();
      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: (_) async => createDataPublisher(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: abortControllerB.signal,
        ),
      ).ignore();

      abortControllerA.abort();
      abortControllerB.abort();

      // Run all microtasks.
      await Future<void>.delayed(Duration.zero);

      expect(mockInnerTransport.lastConfig?.signal.isAborted, isTrue);
    });

    test('fires the inner abort signal if all subscribers abort, in different '
        'runloops', () async {
      final abortControllerA = AbortController();
      final abortControllerB = AbortController();

      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: (_) async => createDataPublisher(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: abortControllerA.signal,
        ),
      ).ignore();

      await Future<void>.delayed(Duration.zero);

      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: (_) async => createDataPublisher(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: abortControllerB.signal,
        ),
      ).ignore();

      await Future<void>.delayed(Duration.zero);

      abortControllerA.abort();
      abortControllerB.abort();

      // Run all microtasks.
      await Future<void>.delayed(Duration.zero);

      expect(mockInnerTransport.lastConfig?.signal.isAborted, isTrue);
    });

    test('does not fire the inner abort signal if the subscriber count is non '
        'zero at the end of the runloop, despite having aborted all in the '
        'middle of it', () async {
      final abortControllerA = AbortController();

      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: (_) async => createDataPublisher(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: abortControllerA.signal,
        ),
      ).ignore();

      abortControllerA.abort();

      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: (_) async => createDataPublisher(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: AbortController().signal,
        ),
      ).ignore();

      // Run all microtasks.
      await Future<void>.delayed(Duration.zero);

      expect(mockInnerTransport.lastConfig?.signal.isAborted, isFalse);
    });

    test(
      'does not re-coalesce new requests behind an errored transport',
      () async {
        coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => createDataPublisher(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: AbortController().signal,
          ),
        ).ignore();

        await Future<void>.delayed(Duration.zero);

        receiveError('o no');

        coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => createDataPublisher(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: AbortController().signal,
          ),
        ).ignore();

        expect(mockInnerTransport.callCount, equals(2));
      },
    );

    test(
      'does not cancel a newly-coalesced transport when an old errored one is '
      'aborted',
      () async {
        final abortControllerA = AbortController();

        // PHASE 1: Create and fail a transport.
        await coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => createDataPublisher(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: abortControllerA.signal,
          ),
        );

        receiveError('o no');
        mockInnerTransport.resetCallCount();

        // PHASE 2: Create a new transport.
        final publisherA = await coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => createDataPublisher(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: AbortController().signal,
          ),
        );

        // PHASE 3: Abort the original subscriber.
        abortControllerA.abort();
        await Future<void>.delayed(Duration.zero);

        // PHASE 4: Create a new transport and expect it to coalesce.
        final publisherB = await coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => createDataPublisher(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: AbortController().signal,
          ),
        );

        expect(publisherA, same(publisherB));
        expect(mockInnerTransport.callCount, equals(1));
      },
    );
  });
}

class _MockOn {
  final List<void Function(Object?)> errorListeners = [];

  void fireError([Object? err]) {
    for (final listener in errorListeners) {
      listener(err);
    }
  }
}

class _MockTransport {
  int callCount = 0;
  RpcSubscriptionsTransportConfig? lastConfig;
  WritableDataPublisher? lastDataPublisher;
  _WrappedDataPublisher? lastWrappedPublisher;
  final List<_MockOn> mockOns = [];

  void resetCallCount() {
    callCount = 0;
  }

  Future<DataPublisher> Function(RpcSubscriptionsTransportConfig config)
  get transport {
    return (RpcSubscriptionsTransportConfig config) {
      callCount++;
      lastConfig = config;

      final dataPublisher = createDataPublisher();
      lastDataPublisher = dataPublisher;

      final mockOn = _MockOn();
      mockOns.add(mockOn);

      // Register error listener for the coalescer.
      final wrappedPublisher = _WrappedDataPublisher(dataPublisher, mockOn);
      lastWrappedPublisher = wrappedPublisher;

      return Future.value(wrappedPublisher);
    };
  }
}

class _WrappedDataPublisher implements DataPublisher {
  _WrappedDataPublisher(this._inner, this._mockOn);

  final WritableDataPublisher _inner;
  final _MockOn _mockOn;

  @override
  UnsubscribeFn on(String channelName, Subscriber<Object?> subscriber) {
    if (channelName == 'error') {
      _mockOn.errorListeners.add(subscriber);
      return () {
        _mockOn.errorListeners.remove(subscriber);
      };
    }
    return _inner.on(channelName, subscriber);
  }
}
