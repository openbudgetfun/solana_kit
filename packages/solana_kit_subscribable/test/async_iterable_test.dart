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
  });
}
