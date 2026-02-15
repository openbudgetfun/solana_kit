import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:test/test.dart';

void main() {
  group('createSignableMessage', () {
    test('creates a SignableMessage from a byte array', () {
      final content = Uint8List.fromList([1, 2, 3]);
      final message = createSignableMessage(content);

      expect(message.content, equals(content));
      expect(message.signatures, isEmpty);
    });

    test('creates a SignableMessage with signatures', () {
      final content = Uint8List.fromList([1, 2, 3]);
      final signatures = <Address, SignatureBytes>{
        const Address('11111111111111111111111111111111'): SignatureBytes(
          Uint8List.fromList([1, 1, 1, 1]),
        ),
        const Address('22222222222222222222222222222222'): SignatureBytes(
          Uint8List.fromList([2, 2, 2, 2]),
        ),
      };

      final message = createSignableMessage(content, signatures);

      expect(message.content, equals(content));
      expect(message.signatures, equals(signatures));
    });

    test('creates a SignableMessage from a UTF-8 string', () {
      final message = createSignableMessage('Hello world!');

      expect(
        message.content,
        equals(Uint8List.fromList(utf8.encode('Hello world!'))),
      );
      expect(message.signatures, isEmpty);
    });

    test('creates an unmodifiable empty signature dictionary', () {
      final message = createSignableMessage('Hello world!');
      expect(message.signatures, isEmpty);
      expect(
        () => message.signatures[const Address('test')] = SignatureBytes(
          Uint8List(64),
        ),
        throwsUnsupportedError,
      );
    });

    test('shallow copies and freezes the provided signature dictionary', () {
      final signatures = <Address, SignatureBytes>{
        const Address('11111111111111111111111111111111'): SignatureBytes(
          Uint8List.fromList([1, 1, 1, 1]),
        ),
        const Address('22222222222222222222222222222222'): SignatureBytes(
          Uint8List.fromList([2, 2, 2, 2]),
        ),
      };

      final message = createSignableMessage('Hello world!', signatures);

      // The signature dictionary is a copy.
      expect(identical(message.signatures, signatures), isFalse);
      expect(message.signatures, equals(signatures));

      // The copy is unmodifiable.
      expect(
        () => message.signatures[const Address('test')] = SignatureBytes(
          Uint8List(64),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
