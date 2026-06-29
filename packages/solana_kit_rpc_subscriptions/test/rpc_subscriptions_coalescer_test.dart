import 'dart:async';

import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('getRpcSubscriptionsTransportWithSubscriptionCoalescing', () {
    late _MockTransport mockInnerTransport;
    late RpcSubscriptionsTransport coalescedTransport;

    void receiveError([Object? err]) {
      for (final mock in mockInnerTransport.mockStreams) {
        mock.fireError(err);
      }
    }

    setUp(() {
      mockInnerTransport = _MockTransport();
      coalescedTransport =
          getRpcSubscriptionsTransportWithSubscriptionCoalescing(
            mockInnerTransport.transport,
          );
    });

    NotificationStreams streamsForExecute() {
      final mock = _MockNotificationStreams();
      mockInnerTransport.mockStreams.add(mock);
      return mock.streams;
    }

    test('returns the inner transport', () async {
      final config = RpcSubscriptionsTransportConfig(
        execute: (_) async => streamsForExecute(),
        request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
        signal: CancellationTokenSource().token,
      );

      final result = await coalescedTransport(config);
      // The result should be the NotificationStreams created by the mock.
      expect(result, same(mockInnerTransport.lastStreams));
    });

    test('passes the execute config to the inner transport', () {
      Future<NotificationStreams> execute(
        RpcSubscriptionsTransportExecuteConfig config,
      ) async {
        return streamsForExecute();
      }

      final config = RpcSubscriptionsTransportConfig(
        execute: execute,
        request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
        signal: CancellationTokenSource().token,
      );

      coalescedTransport(config).ignore();

      expect(mockInnerTransport.callCount, equals(1));
      expect(mockInnerTransport.lastConfig?.execute, same(execute));
    });

    test('passes the rpcRequest config to the inner transport', () {
      final config = RpcSubscriptionsTransportConfig(
        execute: (_) async => streamsForExecute(),
        request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
        signal: CancellationTokenSource().token,
      );

      coalescedTransport(config).ignore();

      expect(mockInnerTransport.lastConfig?.request.methodName, 'foo');
    });

    test('calls the inner transport once per subscriber whose hashes do not '
        'match, in the same runloop', () {
      Future<NotificationStreams> execute(
        RpcSubscriptionsTransportExecuteConfig config,
      ) async {
        return streamsForExecute();
      }

      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: execute,
          request: const RpcSubscriptionsRequest(
            methodName: 'methodA',
            params: [],
          ),
          signal: CancellationTokenSource().token,
        ),
      ).ignore();
      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: execute,
          request: const RpcSubscriptionsRequest(
            methodName: 'methodB',
            params: [],
          ),
          signal: CancellationTokenSource().token,
        ),
      ).ignore();

      expect(mockInnerTransport.callCount, equals(2));
    });

    test('calls the inner transport once per subscriber whose hashes do not '
        'match, in different runloops', () async {
      Future<NotificationStreams> execute(
        RpcSubscriptionsTransportExecuteConfig config,
      ) async {
        return streamsForExecute();
      }

      await coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: execute,
          request: const RpcSubscriptionsRequest(
            methodName: 'methodA',
            params: [],
          ),
          signal: CancellationTokenSource().token,
        ),
      );
      await coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: execute,
          request: const RpcSubscriptionsRequest(
            methodName: 'methodB',
            params: [],
          ),
          signal: CancellationTokenSource().token,
        ),
      );

      expect(mockInnerTransport.callCount, equals(2));
    });

    test('only calls the inner transport once, in the same runloop', () {
      final config = RpcSubscriptionsTransportConfig(
        execute: (_) async => streamsForExecute(),
        request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
        signal: CancellationTokenSource().token,
      );

      coalescedTransport(config).ignore();
      coalescedTransport(config).ignore();

      expect(mockInnerTransport.callCount, equals(1));
    });

    test(
      'only calls the inner transport once, in different runloops',
      () async {
        final config = RpcSubscriptionsTransportConfig(
          execute: (_) async => streamsForExecute(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: CancellationTokenSource().token,
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
          execute: (_) async => streamsForExecute(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: CancellationTokenSource().token,
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
          execute: (_) async => streamsForExecute(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: CancellationTokenSource().token,
        );

        final streamsA = await coalescedTransport(config);
        final streamsB = await coalescedTransport(config);

        expect(streamsA, same(streamsB));
      },
    );

    test('does not fire the inner cancellation token if fewer than all '
        'subscribers abort, in the same runloop', () async {
      final config = RpcSubscriptionsTransportConfig(
        execute: (_) async => streamsForExecute(),
        request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
        signal: CancellationTokenSource().token,
      );

      final sourceB = CancellationTokenSource();
      coalescedTransport(config).ignore();
      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: config.execute,
          request: config.request,
          signal: sourceB.token,
        ),
      ).ignore();

      sourceB.cancel();

      // Run all microtasks.
      await Future<void>.delayed(Duration.zero);

      expect(mockInnerTransport.lastConfig?.signal.isCancelled, isFalse);
    });

    test('fires the inner cancellation token if all subscribers abort, in the '
        'same runloop', () async {
      final sourceA = CancellationTokenSource();
      final sourceB = CancellationTokenSource();

      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: (_) async => streamsForExecute(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: sourceA.token,
        ),
      ).ignore();
      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: (_) async => streamsForExecute(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: sourceB.token,
        ),
      ).ignore();

      sourceA.cancel();
      sourceB.cancel();

      // Run all microtasks.
      await Future<void>.delayed(Duration.zero);

      expect(mockInnerTransport.lastConfig?.signal.isCancelled, isTrue);
    });

    test('fires the inner cancellation token if all subscribers abort, in '
        'different runloops', () async {
      final sourceA = CancellationTokenSource();
      final sourceB = CancellationTokenSource();

      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: (_) async => streamsForExecute(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: sourceA.token,
        ),
      ).ignore();

      await Future<void>.delayed(Duration.zero);

      coalescedTransport(
        RpcSubscriptionsTransportConfig(
          execute: (_) async => streamsForExecute(),
          request: const RpcSubscriptionsRequest(methodName: 'foo', params: []),
          signal: sourceB.token,
        ),
      ).ignore();

      await Future<void>.delayed(Duration.zero);

      sourceA.cancel();
      sourceB.cancel();

      // Run all microtasks.
      await Future<void>.delayed(Duration.zero);

      expect(mockInnerTransport.lastConfig?.signal.isCancelled, isTrue);
    });

    test(
      'does not fire the inner cancellation token if the subscriber count is '
      'non zero at the end of the runloop, despite having aborted all in the '
      'middle of it',
      () async {
        final sourceA = CancellationTokenSource();

        coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => streamsForExecute(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: sourceA.token,
          ),
        ).ignore();

        sourceA.cancel();

        coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => streamsForExecute(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: CancellationTokenSource().token,
          ),
        ).ignore();

        // Run all microtasks.
        await Future<void>.delayed(Duration.zero);

        expect(mockInnerTransport.lastConfig?.signal.isCancelled, isFalse);
      },
    );

    test(
      'does not re-coalesce new requests behind an errored transport',
      () async {
        coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => streamsForExecute(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: CancellationTokenSource().token,
          ),
        ).ignore();

        await Future<void>.delayed(Duration.zero);

        receiveError('o no');

        coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => streamsForExecute(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: CancellationTokenSource().token,
          ),
        ).ignore();

        expect(mockInnerTransport.callCount, equals(2));
      },
    );

    test(
      'does not cancel a newly-coalesced transport when an old errored one is '
      'aborted',
      () async {
        final sourceA = CancellationTokenSource();

        // PHASE 1: Create and fail a transport.
        await coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => streamsForExecute(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: sourceA.token,
          ),
        );

        receiveError('o no');
        mockInnerTransport.resetCallCount();

        // PHASE 2: Create a new transport.
        final streamsA = await coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => streamsForExecute(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: CancellationTokenSource().token,
          ),
        );

        // PHASE 3: Abort the original subscriber.
        sourceA.cancel();
        await Future<void>.delayed(Duration.zero);

        // PHASE 4: Create a new transport and expect it to coalesce.
        final streamsB = await coalescedTransport(
          RpcSubscriptionsTransportConfig(
            execute: (_) async => streamsForExecute(),
            request: const RpcSubscriptionsRequest(
              methodName: 'foo',
              params: [],
            ),
            signal: CancellationTokenSource().token,
          ),
        );

        expect(streamsA, same(streamsB));
        expect(mockInnerTransport.callCount, equals(1));
      },
    );
  });
}

class _MockNotificationStreams {
  _MockNotificationStreams()
    : _messagesController = StreamController<Object?>.broadcast(sync: true),
      _errorsController = StreamController<Object?>.broadcast(sync: true);

  final StreamController<Object?> _messagesController;
  final StreamController<Object?> _errorsController;

  late final NotificationStreams streams = NotificationStreams(
    notifications: _messagesController.stream,
    errors: _errorsController.stream,
  );

  void fireError([Object? err]) {
    if (!_errorsController.isClosed) _errorsController.add(err);
  }
}

class _MockTransport {
  int callCount = 0;
  RpcSubscriptionsTransportConfig? lastConfig;
  NotificationStreams? lastStreams;
  final List<_MockNotificationStreams> mockStreams = [];

  void resetCallCount() {
    callCount = 0;
  }

  Future<NotificationStreams> Function(RpcSubscriptionsTransportConfig config)
  get transport {
    return (RpcSubscriptionsTransportConfig config) {
      callCount++;
      lastConfig = config;

      final mock = _MockNotificationStreams();
      mockStreams.add(mock);
      lastStreams = mock.streams;

      return Future.value(mock.streams);
    };
  }
}
