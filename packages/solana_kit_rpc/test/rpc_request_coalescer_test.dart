import 'dart:async';

import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:test/test.dart';

void main() {
  group('RPC request coalescer', () {
    late RpcTransport coalescedTransport;
    late String? Function(Object?) hashFn;
    late int transportCallCount;
    late List<Completer<Object?>> transportCompleters;

    RpcTransport createMockTransport(Object? Function()? defaultResponse) {
      return (RpcTransportConfig config) {
        transportCallCount++;
        final completer = Completer<Object?>();
        transportCompleters.add(completer);
        if (defaultResponse != null) {
          completer.complete(defaultResponse());
        }
        return completer.future;
      };
    }

    setUp(() {
      transportCallCount = 0;
      transportCompleters = [];
    });

    group('when requests produce the same hash', () {
      setUp(() {
        hashFn = (_) => 'samehash';
      });

      test('multiple requests in the same tick produce a single transport '
          'request', () {
        final mockTransport = createMockTransport(() => null);
        coalescedTransport = getRpcTransportWithRequestCoalescing(
          mockTransport,
          hashFn,
        );

        // We intentionally fire-and-forget these requests to test coalescing
        // behavior without awaiting.
        // ignore: discarded_futures
        coalescedTransport(const RpcTransportConfig(payload: null));
        // We intentionally fire-and-forget these requests to test coalescing
        // behavior without awaiting.
        // ignore: discarded_futures
        coalescedTransport(const RpcTransportConfig(payload: null));

        expect(transportCallCount, 1);
      });

      test('multiple requests in different ticks each produce their own '
          'transport request', () async {
        final mockTransport = createMockTransport(() => null);
        coalescedTransport = getRpcTransportWithRequestCoalescing(
          mockTransport,
          hashFn,
        );

        // We intentionally fire-and-forget to test coalescing across ticks.
        unawaited(coalescedTransport(const RpcTransportConfig(payload: null)));
        // Wait for the microtask that clears the cache.
        await Future<void>.delayed(Duration.zero);

        // We intentionally fire-and-forget to test a new tick.
        unawaited(coalescedTransport(const RpcTransportConfig(payload: null)));
        expect(transportCallCount, 2);
      });

      test(
        'multiple requests in the same tick receive the same response',
        () async {
          final mockResponse = {'response': 'ok'};
          var callCount = 0;
          final mockTransport = createMockTransport(() {
            callCount++;
            return mockResponse;
          });
          coalescedTransport = getRpcTransportWithRequestCoalescing(
            mockTransport,
            hashFn,
          );

          final responseA = coalescedTransport(
            const RpcTransportConfig(payload: null),
          );
          final responseB = coalescedTransport(
            const RpcTransportConfig(payload: null),
          );

          final resultA = await responseA;
          final resultB = await responseB;

          expect(resultA, mockResponse);
          expect(resultB, mockResponse);
          expect(callCount, 1);
        },
      );

      test('multiple requests in the same tick receive the same error '
          'in the case of failure', () async {
        final mockError = Exception('bad');
        Future<Object?> errorTransport(RpcTransportConfig config) {
          transportCallCount++;
          return Future<Object?>.error(mockError);
        }

        coalescedTransport = getRpcTransportWithRequestCoalescing(
          errorTransport,
          hashFn,
        );

        final responseA = coalescedTransport(
          const RpcTransportConfig(payload: null),
        );
        final responseB = coalescedTransport(
          const RpcTransportConfig(payload: null),
        );

        await expectLater(responseA, throwsA(mockError));
        await expectLater(responseB, throwsA(mockError));
      });
    });

    group('when requests produce different hashes', () {
      setUp(() {
        var counter = 0;
        hashFn = (_) => 'hash-${counter++}';
      });

      test('multiple requests in the same tick produce one transport request '
          'each', () {
        final mockTransport = createMockTransport(() => null);
        coalescedTransport = getRpcTransportWithRequestCoalescing(
          mockTransport,
          hashFn,
        );

        // We intentionally fire-and-forget to test call count.
        // ignore: discarded_futures
        coalescedTransport(const RpcTransportConfig(payload: null));
        // We intentionally fire-and-forget to test call count.
        // ignore: discarded_futures
        coalescedTransport(const RpcTransportConfig(payload: null));

        expect(transportCallCount, 2);
      });

      test(
        'multiple requests in the same tick receive different responses',
        () async {
          final mockResponseA = {'response': 'okA'};
          final mockResponseB = {'response': 'okB'};
          var callCount = 0;
          final responses = [mockResponseA, mockResponseB];
          Future<Object?> diffTransport(RpcTransportConfig config) {
            transportCallCount++;
            return Future<Object?>.value(responses[callCount++]);
          }

          coalescedTransport = getRpcTransportWithRequestCoalescing(
            diffTransport,
            hashFn,
          );

          final responseA = coalescedTransport(
            const RpcTransportConfig(payload: null),
          );
          final responseB = coalescedTransport(
            const RpcTransportConfig(payload: null),
          );

          expect(await responseA, mockResponseA);
          expect(await responseB, mockResponseB);
        },
      );
    });

    group('when requests produce no hash', () {
      setUp(() {
        hashFn = (_) => null;
      });

      test('multiple requests in the same tick produce one transport request '
          'each', () {
        final mockTransport = createMockTransport(() => null);
        coalescedTransport = getRpcTransportWithRequestCoalescing(
          mockTransport,
          hashFn,
        );

        // We intentionally fire-and-forget to test call count.
        // ignore: discarded_futures
        coalescedTransport(const RpcTransportConfig(payload: null));
        // We intentionally fire-and-forget to test call count.
        // ignore: discarded_futures
        coalescedTransport(const RpcTransportConfig(payload: null));

        expect(transportCallCount, 2);
      });

      test(
        'multiple requests in the same tick receive different responses',
        () async {
          final mockResponseA = {'response': 'okA'};
          final mockResponseB = {'response': 'okB'};
          var callCount = 0;
          final responses = [mockResponseA, mockResponseB];
          Future<Object?> noHashTransport(RpcTransportConfig config) {
            transportCallCount++;
            return Future<Object?>.value(responses[callCount++]);
          }

          coalescedTransport = getRpcTransportWithRequestCoalescing(
            noHashTransport,
            hashFn,
          );

          final responseA = coalescedTransport(
            const RpcTransportConfig(payload: null),
          );
          final responseB = coalescedTransport(
            const RpcTransportConfig(payload: null),
          );

          expect(await responseA, mockResponseA);
          expect(await responseB, mockResponseB);
        },
      );
    });
  });
}
