// ignore_for_file: cascade_invocations, deprecated_member_use

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

  group('createReactiveStoreFromDataPublisher', () {
    test('updates state and notifies subscribers on data events', () {
      final publisher = createDataPublisher();
      final store = createReactiveStoreFromDataPublisher<int>(
        dataPublisher: publisher,
        dataChannelName: 'data',
        errorChannelName: 'error',
      );
      var notifications = 0;
      final unsubscribe = store.subscribe(() {
        notifications++;
      });

      expect(store.getState(), isNull);
      expect(store.getError(), isNull);

      publisher.publish('data', 1);
      publisher.publish('data', 2);

      expect(store.getState(), 2);
      expect(store.getError(), isNull);
      expect(notifications, 2);

      unsubscribe();
      unsubscribe();
      publisher.publish('data', 3);

      expect(store.getState(), 3);
      expect(notifications, 2);
    });

    test('preserves last state and first error on error events', () {
      final publisher = createDataPublisher();
      final store = createReactiveStoreFromDataPublisher<String>(
        dataPublisher: publisher,
        dataChannelName: 'data',
        errorChannelName: 'error',
      );
      var notifications = 0;
      store.subscribe(() {
        notifications++;
      });

      publisher.publish('data', 'ready');
      publisher.publish('error', StateError('boom'));
      publisher.publish('error', ArgumentError('ignored'));

      expect(store.getState(), 'ready');
      expect(store.getError(), isA<StateError>());
      expect(notifications, 2);
    });

    test('allows subscribers to unsubscribe during notification', () {
      final publisher = createDataPublisher();
      final store = createReactiveStoreFromDataPublisher<int>(
        dataPublisher: publisher,
        dataChannelName: 'data',
        errorChannelName: 'error',
      );
      late final UnsubscribeFn unsubscribe;
      var notifications = 0;
      unsubscribe = store.subscribe(() {
        notifications++;
        unsubscribe();
      });

      publisher.publish('data', 1);
      publisher.publish('data', 2);

      expect(store.getState(), 2);
      expect(notifications, 1);
    });

    test('dispose disconnects publisher subscriptions and subscribers', () {
      final publisher = createDataPublisher();
      final store = createReactiveStoreFromDataPublisher<int>(
        dataPublisher: publisher,
        dataChannelName: 'data',
        errorChannelName: 'error',
      );
      var notifications = 0;
      store.subscribe(() {
        notifications++;
      });

      store.dispose();
      store.dispose();
      final unsubscribeAfterDispose = store.subscribe(() {
        notifications++;
      });
      unsubscribeAfterDispose();
      publisher.publish('data', 1);
      publisher.publish('error', 'boom');

      expect(store.getState(), isNull);
      expect(store.getError(), isNull);
      expect(notifications, 0);
    });
  });
}
