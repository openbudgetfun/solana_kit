import 'dart:async';

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:test/test.dart';

void main() {
  group('ChannelStreamController', () {
    test('emits typed events on independent named channels', () async {
      final channels = ChannelStreamController();
      final receivedA = <String>[];
      final receivedB = <int>[];
      final subscriptionA = channels.stream<String>('a').listen(receivedA.add);
      final subscriptionB = channels.stream<int>('b').listen(receivedB.add);

      channels
        ..add('a', 'hello')
        ..add('b', 42);

      expect(receivedA, ['hello']);
      expect(receivedB, [42]);
      await subscriptionA.cancel();
      await subscriptionB.cancel();
      await channels.close();
    });

    test('emits errors on named channels', () async {
      final channels = ChannelStreamController();
      final error = StateError('boom');
      final caught = Completer<Object>();
      final subscription = channels
          .stream<Object>('errors')
          .listen(null, onError: caught.complete);

      channels.addError('errors', error);

      expect(await caught.future, same(error));
      await subscription.cancel();
      await channels.close();
    });

    test('closes all channel streams', () async {
      final channels = ChannelStreamController();
      final doneA = Completer<void>();
      final doneB = Completer<void>();

      channels.stream<Object?>('a').listen(null, onDone: doneA.complete);
      channels.stream<Object?>('b').listen(null, onDone: doneB.complete);
      await channels.close();

      await expectLater(doneA.future, completes);
      await expectLater(doneB.future, completes);
    });
  });
}
