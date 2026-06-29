import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('demultiplexStream', () {
    test('emits transformed messages for the selected destination channel', () {
      final source = StreamController<Map<String, Object?>>.broadcast(
        sync: true,
      );
      final stream = demultiplexStream<Map<String, Object?>, String>(
        source: source.stream,
        channelName: 'matched',
        messageTransformer: (message) {
          return (message['channel']! as String, message['payload']);
        },
      );
      final received = <String>[];
      final subscription = stream.listen(received.add);

      source
        ..add({'channel': 'ignored', 'payload': 'nope'})
        ..add({'channel': 'matched', 'payload': 'hello'});

      expect(received, ['hello']);
      subscription.cancel().ignore();
      source.close().ignore();
    });

    test('drops messages when the transformer returns null', () {
      final source = StreamController<String>.broadcast(sync: true);
      final stream = demultiplexStream<String, String>(
        source: source.stream,
        channelName: 'matched',
        messageTransformer: (_) => null,
      );
      final received = <String>[];
      final subscription = stream.listen(received.add);

      source.add('hello');

      expect(received, isEmpty);
      subscription.cancel().ignore();
      source.close().ignore();
    });

    test(
      'listens lazily and cancels the source when the listener leaves',
      () async {
        var listenCount = 0;
        var cancelCount = 0;
        final source = StreamController<String>.broadcast(
          onListen: () => listenCount++,
          onCancel: () => cancelCount++,
          sync: true,
        );
        final stream = demultiplexStream<String, String>(
          source: source.stream,
          channelName: 'matched',
          messageTransformer: (message) => ('matched', message),
        );

        expect(listenCount, 0);
        final subscription = stream.listen((_) {});
        expect(listenCount, 1);

        await subscription.cancel();
        await Future<void>.delayed(Duration.zero);
        expect(cancelCount, 1);
        await source.close();
      },
    );
  });
}
