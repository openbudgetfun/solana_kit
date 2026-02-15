import 'dart:typed_data';

import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('Message header encoder', () {
    test('serializes header data according to spec', () {
      final encoder = getMessageHeaderEncoder();
      final result = encoder.encode(
        const MessageHeader(
          numSignerAccounts: 3,
          numReadonlySignerAccounts: 2,
          numReadonlyNonSignerAccounts: 1,
        ),
      );
      expect(result, equals(Uint8List.fromList([3, 2, 1])));
    });
  });

  group('Message header decoder', () {
    test('deserializes header data according to spec', () {
      final decoder = getMessageHeaderDecoder();
      final result = decoder.decode(Uint8List.fromList([3, 2, 1]));
      expect(result.numSignerAccounts, equals(3));
      expect(result.numReadonlySignerAccounts, equals(2));
      expect(result.numReadonlyNonSignerAccounts, equals(1));
    });
  });

  group('Message header codec', () {
    test('round-trips header data', () {
      final codec = getMessageHeaderCodec();
      const header = MessageHeader(
        numSignerAccounts: 5,
        numReadonlySignerAccounts: 2,
        numReadonlyNonSignerAccounts: 3,
      );
      final encoded = codec.encode(header);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(header));
    });
  });
}
