import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
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
  });
}
