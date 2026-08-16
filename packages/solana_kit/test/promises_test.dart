import 'dart:async';

import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart'
    hide isAbortError;
import 'package:test/test.dart';

void main() {
  group('promises', () {
    test('isAbortError recognizes AbortError', () {
      expect(isAbortError(const AbortError()), isTrue);
      expect(isAbortError(StateError('nope')), isFalse);
      expect(isAbortError(null), isFalse);
    });

    test('getAbortablePromise returns the future when no token', () async {
      expect(await getAbortablePromise(Future.value(42)), 42);
    });

    test('getAbortablePromise completes with the future result', () async {
      final source = CancellationTokenSource();
      final result = await getAbortablePromise(
        Future.value(42),
        cancellationToken: source.token,
      );
      expect(result, 42);
    });

    test('getAbortablePromise rejects when the token fires', () async {
      final source = CancellationTokenSource();
      final future = getAbortablePromise(
        Completer<int>().future,
        cancellationToken: source.token,
      );
      source.cancel(StateError('aborted'));
      await expectLater(future, throwsA(isA<StateError>()));
    });

    test('getAbortablePromise rethrows an Exception reason', () async {
      final source = CancellationTokenSource();
      final future = getAbortablePromise(
        Completer<int>().future,
        cancellationToken: source.token,
      );
      source.cancel(Exception('aborted'));
      await expectLater(future, throwsA(isA<Exception>()));
    });

    test('getAbortablePromise throws StateError for a non-error reason',
        () async {
      final source = CancellationTokenSource();
      final future = getAbortablePromise(
        Completer<int>().future,
        cancellationToken: source.token,
      );
      source.cancel('aborted');
      await expectLater(future, throwsA(isA<StateError>()));
    });

    test('safeRace completes with the first result', () async {
      final slow = Completer<int>();
      final fast = Future.value(1);
      final result = await safeRace([slow.future, fast]);
      expect(result, 1);
    });

    test('safeRace completes with the first error', () async {
      final slow = Completer<int>();
      final fast = Future<int>.error(StateError('boom'));
      await expectLater(
        safeRace([slow.future, fast]),
        throwsA(isA<StateError>()),
      );
    });
  });
}
