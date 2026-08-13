import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('createStreamFromDataAndErrorStreams', () {
    test('emits data and forwards the first error from streams', () async {
      final dataController = StreamController<String>.broadcast(sync: true);
      final errorController = StreamController<Object?>.broadcast(sync: true);
      final stream = createStreamFromDataAndErrorStreams<String>(
        dataStream: dataController.stream,
        errorStream: errorController.stream,
      );
      final received = <String>[];
      final errorCompleter = Completer<Object>();
      final subscription = stream.listen(
        received.add,
        onError: (Object error) {
          if (!errorCompleter.isCompleted) errorCompleter.complete(error);
        },
      );

      dataController.add('hello');
      errorController.add(StateError('boom'));

      expect(received, ['hello']);
      expect(await errorCompleter.future, isA<StateError>());
      await subscription.cancel();
      await dataController.close();
      await errorController.close();
    });

    test('cancels data and error stream subscriptions on cancel', () async {
      var dataCancelCount = 0;
      var errorCancelCount = 0;
      final dataController = StreamController<String>.broadcast(
        onCancel: () => dataCancelCount++,
        sync: true,
      );
      final errorController = StreamController<Object?>.broadcast(
        onCancel: () => errorCancelCount++,
        sync: true,
      );
      final stream = createStreamFromDataAndErrorStreams<String>(
        dataStream: dataController.stream,
        errorStream: errorController.stream,
      );

      final subscription = stream.listen((_) {});
      await subscription.cancel();
      await Future<void>.delayed(Duration.zero);

      expect(dataCancelCount, 1);
      expect(errorCancelCount, 1);
      await dataController.close();
      await errorController.close();
    });

    test('closes and cancels both sources when the token fires', () async {
      var dataCancelCount = 0;
      var errorCancelCount = 0;
      final dataController = StreamController<String>.broadcast(
        onCancel: () => dataCancelCount++,
        sync: true,
      );
      final errorController = StreamController<Object?>.broadcast(
        onCancel: () => errorCancelCount++,
        sync: true,
      );
      final source = CancellationTokenSource();
      final events = <String>[];
      final errors = <Object>[];
      final done = Completer<void>();
      final stream = createStreamFromDataAndErrorStreams<String>(
        dataStream: dataController.stream,
        errorStream: errorController.stream,
        cancellationToken: source.token,
      );

      // ignore: cascade_invocations
      stream.listen(
        events.add,
        onError: errors.add,
        onDone: done.complete,
      );
      dataController.add('before');
      source.cancel();
      dataController.add('late');
      errorController.add(StateError('late'));
      await done.future;

      expect(events, ['before']);
      expect(errors, isEmpty);
      expect(dataCancelCount, 1);
      expect(errorCancelCount, 1);
      await dataController.close();
      await errorController.close();
    });

    test('an already-cancelled token produces a closed stream', () async {
      var dataListenCount = 0;
      var errorListenCount = 0;
      final dataController = StreamController<String>.broadcast(
        onListen: () => dataListenCount++,
        sync: true,
      );
      final errorController = StreamController<Object?>.broadcast(
        onListen: () => errorListenCount++,
        sync: true,
      );
      final source = CancellationTokenSource()..cancel();
      final events = <String>[];
      final errors = <Object>[];
      final stream = createStreamFromDataAndErrorStreams<String>(
        dataStream: dataController.stream,
        errorStream: errorController.stream,
        cancellationToken: source.token,
      );

      await stream.listen(events.add, onError: errors.add).asFuture<void>();
      dataController.add('late');
      errorController.add(StateError('late'));

      expect(events, isEmpty);
      expect(errors, isEmpty);
      expect(dataListenCount, 0);
      expect(errorListenCount, 0);
      await dataController.close();
      await errorController.close();
    });

    test('stops when the token is cancelled before the first listen', () async {
      final dataController = StreamController<String>.broadcast(sync: true);
      final errorController = StreamController<Object?>.broadcast(sync: true);
      final source = CancellationTokenSource();
      final stream = createStreamFromDataAndErrorStreams<String>(
        dataStream: dataController.stream,
        errorStream: errorController.stream,
        cancellationToken: source.token,
      );

      // Cancel after the stream is created but before anyone listens; the
      // first listen must observe the cancelled token and stop immediately.
      source.cancel();
      final events = <String>[];
      final errors = <Object>[];
      final done = Completer<void>();
      final subscription = stream.listen(
        events.add,
        onError: errors.add,
        onDone: done.complete,
      );
      await done.future;

      expect(events, isEmpty);
      expect(errors, isEmpty);
      await subscription.cancel();
      await dataController.close();
      await errorController.close();
    });

    test(
      'replays a received error to a listener attached during teardown',
      () async {
        final dataController = StreamController<String>.broadcast(sync: true);
        final errorController = StreamController<Object?>.broadcast(sync: true);
        final stream = createStreamFromDataAndErrorStreams<String>(
          dataStream: dataController.stream,
          errorStream: errorController.stream,
        );

        // The first listener observes the error, then cancels. `stop()` closes
        // the controller asynchronously, so a listener attached in that window
        // still triggers `onListen` and receives the replayed error.
        final boom = StateError('boom');
        final firstErrors = <Object>[];
        final first = stream.listen((_) {}, onError: firstErrors.add);
        errorController.add(boom);
        await pumpEventQueue();
        expect(firstErrors, [boom]);

        // Cancel the first listener; `stop()` closes the controller
        // asynchronously, so a listener attached in that window still triggers
        // `onListen` and receives the replayed error.
        final secondErrors = <Object>[];
        final cancelFuture = first.cancel();
        final second = stream.listen((_) {}, onError: secondErrors.add);
        await cancelFuture;
        await pumpEventQueue();
        expect(secondErrors, [boom]);

        await second.cancel();
        await dataController.close();
        await errorController.close();
      },
    );

    test('maps a null error event to a StateError', () async {
      final dataController = StreamController<String>.broadcast(sync: true);
      final errorController = StreamController<Object?>.broadcast(sync: true);
      final stream = createStreamFromDataAndErrorStreams<String>(
        dataStream: dataController.stream,
        errorStream: errorController.stream,
      );

      final errors = <Object>[];
      final subscription = stream.listen((_) {}, onError: errors.add);
      errorController.add(null);
      await pumpEventQueue();

      expect(errors.single, isA<StateError>());
      expect((errors.single as StateError).message, 'Unknown error');
      await subscription.cancel();
      await dataController.close();
      await errorController.close();
    });
  });
}
