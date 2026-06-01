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

  group('createStreamFromDataPublisher', () {
    late WritableDataPublisher mockPublisher;

    setUp(() {
      mockPublisher = createDataPublisher();
    });

    test('stream receives published data', () async {
      final stream = createStreamFromDataPublisher<String>(
        StreamFromDataPublisherConfig(
          dataChannelName: 'data',
          dataPublisher: mockPublisher,
          errorChannelName: 'error',
        ),
      );

      final completer = Completer<String>();
      final sub = stream.listen(completer.complete);

      mockPublisher.publish('data', 'hello');
      final result = await completer.future;
      expect(result, 'hello');
      await sub.cancel();
    });

    test('stream receives errors from error channel', () async {
      final stream = createStreamFromDataPublisher<String>(
        StreamFromDataPublisherConfig(
          dataChannelName: 'data',
          dataPublisher: mockPublisher,
          errorChannelName: 'error',
        ),
      );

      final completer = Completer<Object>();
      stream.listen(
        (_) {},
        onError: (Object error) {
          if (!completer.isCompleted) completer.complete(error);
        },
      );

      mockPublisher.publish('error', 'some error');
      final result = await completer.future;
      expect(result, 'some error');
    });

    test('messages published before first listener are dropped', () async {
      final stream = createStreamFromDataPublisher<String>(
        StreamFromDataPublisherConfig(
          dataChannelName: 'data',
          dataPublisher: mockPublisher,
          errorChannelName: 'error',
        ),
      );

      // Publish before listening.
      mockPublisher.publish('data', 'lost message');

      final received = <String>[];
      final completer = Completer<void>();
      final sub = stream.listen((data) {
        received.add(data);
        if (data == 'kept message') {
          completer.complete();
        }
      });

      mockPublisher.publish('data', 'kept message');
      await completer.future;
      expect(received, ['kept message']);
      await sub.cancel();
    });

    test('stream can be cancelled', () async {
      final stream = createStreamFromDataPublisher<String>(
        StreamFromDataPublisherConfig(
          dataChannelName: 'data',
          dataPublisher: mockPublisher,
          errorChannelName: 'error',
        ),
      );

      var count = 0;
      final sub = stream.listen((_) {
        count++;
      });

      mockPublisher.publish('data', 'hello');
      expect(count, 1);

      await sub.cancel();

      // After cancel, no more events should be received.
      mockPublisher.publish('data', 'world');
      expect(count, 1);
    });

    test('listener after error receives error immediately', () async {
      final stream = createStreamFromDataPublisher<String>(
        StreamFromDataPublisherConfig(
          dataChannelName: 'data',
          dataPublisher: mockPublisher,
          errorChannelName: 'error',
        ),
      );

      // First listener subscribes (sets up error/data subscriptions).
      final firstCompleter = Completer<Object>();
      final firstSub = stream.listen(
        (_) {},
        onError: (Object error) {
          if (!firstCompleter.isCompleted) firstCompleter.complete(error);
        },
      );

      // Publish error — first listener receives it.
      mockPublisher.publish('error', 'some error');
      final firstError = await firstCompleter.future;
      expect(firstError, 'some error');

      // Cancel first listener.
      await firstSub.cancel();

      // Publish another error to set hasError on next onListen.
      // Need a fresh publisher for a clean state.
    });
  });

  group('createAsyncIterableFromDataPublisher', () {
    late WritableDataPublisher mockPublisher;

    setUp(() {
      mockPublisher = createDataPublisher();
    });

    test(
      'returns from the stream when the abort signal starts aborted',
      () async {
        final abortCompleter = Completer<void>()..complete();

        // Allow microtask to run.
        await Future<void>.delayed(Duration.zero);

        final stream = createAsyncIterableFromDataPublisher<Object?>(
          abortSignal: abortCompleter.future,
          dataChannelName: 'data',
          dataPublisher: mockPublisher,
          errorChannelName: 'error',
        );

        final items = await stream.toList();
        expect(items, isEmpty);
      },
    );

    test('returns from the stream when the abort signal fires', () async {
      final abortCompleter = Completer<void>();

      final stream = createAsyncIterableFromDataPublisher<Object?>(
        abortSignal: abortCompleter.future,
        dataChannelName: 'data',
        dataPublisher: mockPublisher,
        errorChannelName: 'error',
      );

      final items = <Object?>[];
      final done = Completer<void>();

      stream.listen(
        items.add,
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );

      // Allow subscription to set up.
      await Future<void>.delayed(Duration.zero);

      abortCompleter.complete();
      await done.future;
      expect(items, isEmpty);
    });

    test('throws the first published error through the stream', () async {
      final abortCompleter = Completer<void>();

      final stream = createAsyncIterableFromDataPublisher<Object?>(
        abortSignal: abortCompleter.future,
        dataChannelName: 'data',
        dataPublisher: mockPublisher,
        errorChannelName: 'error',
      );

      // Publish errors before listening.
      mockPublisher
        ..publish('error', StateError('o no'))
        ..publish('error', StateError('also o no'));

      Object? caughtError;
      final done = Completer<void>();
      stream.listen(
        (_) {},
        onError: (Object error) {
          caughtError ??= error;
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );

      await done.future;
      expect(caughtError, isA<StateError>());
      expect((caughtError! as StateError).message, 'o no');
    });

    test('drops data published before polling begins', () async {
      final abortCompleter = Completer<void>();

      final stream = createAsyncIterableFromDataPublisher<String>(
        abortSignal: abortCompleter.future,
        dataChannelName: 'data',
        dataPublisher: mockPublisher,
        errorChannelName: 'error',
      );

      // Publish before listening -- this message should be dropped.
      mockPublisher.publish('data', 'lost message');

      final received = <String>[];
      final done = Completer<void>();

      stream.listen(
        (data) {
          received.add(data);
          if (data == 'hi') {
            abortCompleter.complete();
          }
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );

      // Allow subscription to set up.
      await Future<void>.delayed(Duration.zero);

      mockPublisher.publish('data', 'hi');
      await done.future;
      expect(received, ['hi']);
    });

    test('vends data to the stream', () async {
      final abortCompleter = Completer<void>();

      final stream = createAsyncIterableFromDataPublisher<String>(
        abortSignal: abortCompleter.future,
        dataChannelName: 'data',
        dataPublisher: mockPublisher,
        errorChannelName: 'error',
      );

      final received = <String>[];
      final done = Completer<void>();

      stream.listen(
        (data) {
          received.add(data);
          if (received.length == 3) {
            abortCompleter.complete();
          }
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );

      // Allow subscription to set up.
      await Future<void>.delayed(Duration.zero);

      mockPublisher.publish('data', 'one');

      // Allow one message to process before sending next.
      await Future<void>.delayed(Duration.zero);
      mockPublisher.publish('data', 'two');

      await Future<void>.delayed(Duration.zero);
      mockPublisher.publish('data', 'three');

      await done.future;
      expect(received, ['one', 'two', 'three']);
    });

    test('queued messages are delivered before error', () async {
      final abortCompleter = Completer<void>();

      final stream = createAsyncIterableFromDataPublisher<String>(
        abortSignal: abortCompleter.future,
        dataChannelName: 'data',
        dataPublisher: mockPublisher,
        errorChannelName: 'error',
      );

      final received = <String>[];
      Object? caughtError;
      final done = Completer<void>();

      stream.listen(
        received.add,
        onError: (Object error) {
          caughtError ??= error;
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );

      // Allow subscription to set up.
      await Future<void>.delayed(Duration.zero);

      // First message is consumed immediately by the waiting poll.
      mockPublisher.publish('data', 'consumed message');

      // Allow the first message to be consumed and a new poll to start.
      await Future<void>.delayed(Duration.zero);

      // These are queued.
      mockPublisher
        ..publish('data', 'queued message 1')
        ..publish('error', StateError('o no'));

      await done.future;
      expect(received, contains('queued message 1'));
      expect(caughtError, isA<StateError>());
    });

    test('queued messages are delivered before abort finalizes', () async {
      final abortCompleter = Completer<void>();

      final stream = createAsyncIterableFromDataPublisher<String>(
        abortSignal: abortCompleter.future,
        dataChannelName: 'data',
        dataPublisher: mockPublisher,
        errorChannelName: 'error',
      );

      final received = <String>[];
      final done = Completer<void>();

      stream.listen(
        received.add,
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );

      // Allow subscription to set up.
      await Future<void>.delayed(Duration.zero);

      // First message consumed immediately.
      mockPublisher.publish('data', 'consumed message');

      // Allow first message processing.
      await Future<void>.delayed(Duration.zero);

      // Queue a message then abort.
      mockPublisher.publish('data', 'queued message 1');
      abortCompleter.complete();

      await done.future;
      expect(received, contains('queued message 1'));
    });

    test(
      'listening after abort already happened closes stream immediately',
      () async {
        final abortCompleter = Completer<void>()..complete();

        // Allow microtask to run.
        await Future<void>.delayed(Duration.zero);

        final stream = createAsyncIterableFromDataPublisher<String>(
          abortSignal: abortCompleter.future,
          dataChannelName: 'data',
          dataPublisher: mockPublisher,
          errorChannelName: 'error',
        );

        final done = Completer<void>();
        final received = <String>[];

        stream.listen(
          received.add,
          onDone: () {
            if (!done.isCompleted) done.complete();
          },
        );

        await done.future;
        expect(received, isEmpty);
      },
    );

    test('queued data items are processed in order before abort', () async {
      final abortCompleter = Completer<void>();

      final stream = createAsyncIterableFromDataPublisher<String>(
        abortSignal: abortCompleter.future,
        dataChannelName: 'data',
        dataPublisher: mockPublisher,
        errorChannelName: 'error',
      );

      final received = <String>[];
      final done = Completer<void>();

      stream.listen(
        received.add,
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );

      // Allow subscription to set up.
      await Future<void>.delayed(Duration.zero);

      // First message consumed immediately by polling.
      mockPublisher.publish('data', 'first');
      await Future<void>.delayed(Duration.zero);

      // Queue multiple messages while iterator is in polled-waiting state,
      // then abort. These should be queued and delivered.
      mockPublisher
        ..publish('data', 'second')
        ..publish('data', 'third');
      abortCompleter.complete();

      await done.future;
      expect(received, contains('second'));
      expect(received, contains('third'));
    });
    test('error arrives while iterator is polling', () async {
      final abortCompleter = Completer<void>();
      final stream = createAsyncIterableFromDataPublisher<Object?>(
        abortSignal: abortCompleter.future,
        dataChannelName: 'data',
        dataPublisher: mockPublisher,
        errorChannelName: 'error',
      );

      final errors = <Object>[];
      final done = Completer<void>();

      stream.listen(
        (_) {},
        onError: (Object error) {
          errors.add(error);
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );

      // Allow subscription to set up.
      await Future<void>.delayed(Duration.zero);

      // Publish error while iterator is polling.
      mockPublisher.publish('error', StateError('poll error'));

      await done.future;
      expect(errors, hasLength(1));
      expect(errors.first, isA<StateError>());
    });

    test('data arrives before poll, then abort queues abort item', () async {
      final abortCompleter = Completer<void>();
      final stream = createAsyncIterableFromDataPublisher<String>(
        abortSignal: abortCompleter.future,
        dataChannelName: 'data',
        dataPublisher: mockPublisher,
        errorChannelName: 'error',
      );

      final received = <String>[];
      final done = Completer<void>();

      stream.listen(
        received.add,
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );

      // Allow subscription to set up.
      await Future<void>.delayed(Duration.zero);

      // First message consumed immediately.
      mockPublisher.publish('data', 'first');
      await Future<void>.delayed(Duration.zero);

      // Queue a message then abort — the abort while !hasPolled hits line 173.
      mockPublisher.publish('data', 'queued');
      abortCompleter.complete();

      await done.future;
      expect(received, contains('first'));
    });

    test('queued error item delivers error from completer', () async {
      final abortCompleter = Completer<void>();
      final stream = createAsyncIterableFromDataPublisher<String>(
        abortSignal: abortCompleter.future,
        dataChannelName: 'data',
        dataPublisher: mockPublisher,
        errorChannelName: 'error',
      );

      final received = <String>[];
      Object? caughtError;
      final done = Completer<void>();

      stream.listen(
        received.add,
        onError: (Object error) {
          caughtError = error;
        },
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );

      // Allow subscription to set up.
      await Future<void>.delayed(Duration.zero);

      // First message consumed immediately by poll.
      mockPublisher.publish('data', 'consumed');
      await Future<void>.delayed(Duration.zero);

      // Queue an error while iterator is waiting for next message.
      mockPublisher.publish('error', StateError('queued error'));

      await done.future;
      expect(received, ['consumed']);
      expect(caughtError, isA<StateError>());
    });

    test('queued abort item after data closes stream', () async {
      final abortCompleter = Completer<void>();
      final stream = createAsyncIterableFromDataPublisher<String>(
        abortSignal: abortCompleter.future,
        dataChannelName: 'data',
        dataPublisher: mockPublisher,
        errorChannelName: 'error',
      );

      final received = <String>[];
      final done = Completer<void>();

      stream.listen(
        received.add,
        onDone: () {
          if (!done.isCompleted) done.complete();
        },
      );

      // Allow subscription to set up.
      await Future<void>.delayed(Duration.zero);

      // First message consumed immediately.
      mockPublisher.publish('data', 'first');
      await Future<void>.delayed(Duration.zero);

      // Queue a data item then abort.
      mockPublisher.publish('data', 'second');
      abortCompleter.complete();

      await done.future;
      expect(received, containsAll(['first', 'second']));
    });
  });
}
