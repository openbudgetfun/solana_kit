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
  });
}
