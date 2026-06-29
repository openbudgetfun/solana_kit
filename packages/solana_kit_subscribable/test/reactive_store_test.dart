// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('createReactiveStoreFromStreams', () {
    test('updates state and preserves the first error from streams', () {
      final dataController = StreamController<int>.broadcast(sync: true);
      final errorController = StreamController<Object?>.broadcast(sync: true);
      final store = createReactiveStoreFromStreams<int>(
        dataStream: dataController.stream,
        errorStream: errorController.stream,
      );
      var notifications = 0;
      final unsubscribe = store.subscribe(() {
        notifications++;
      });

      dataController
        ..add(1)
        ..add(2);
      errorController
        ..add(StateError('boom'))
        ..add(ArgumentError('ignored'));

      expect(store.getState(), 2);
      expect(store.getError(), isA<StateError>());
      expect(notifications, 3);

      unsubscribe();
      store.dispose();
      dataController.close().ignore();
      errorController.close().ignore();
    });

    test('dispose cancels stream subscriptions', () async {
      var dataCancelCount = 0;
      var errorCancelCount = 0;
      final dataController = StreamController<int>.broadcast(
        onCancel: () => dataCancelCount++,
        sync: true,
      );
      final errorController = StreamController<Object?>.broadcast(
        onCancel: () => errorCancelCount++,
        sync: true,
      );
      final store = createReactiveStoreFromStreams<int>(
        dataStream: dataController.stream,
        errorStream: errorController.stream,
      );

      store.dispose();
      await Future<void>.delayed(Duration.zero);

      expect(dataCancelCount, 1);
      expect(errorCancelCount, 1);
      await dataController.close();
      await errorController.close();
    });
  });
}
