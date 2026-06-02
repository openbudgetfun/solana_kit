import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('loadKeypair', () {
    test('returns copied publicKey and secretKey from 64-byte input', () {
      final bytes = Uint8List(64)
        ..fillRange(0, 32, 1)
        ..fillRange(32, 64, 2);

      final result = loadKeypair(bytes);
      final secretKey = base64Decode(result.secretKey);
      final publicKey = base64Decode(result.publicKey);

      expect(secretKey, bytes);
      expect(identical(secretKey, bytes), isFalse);
      expect(secretKey, hasLength(64));
      expect(publicKey, bytes.sublist(32));
      expect(publicKey, hasLength(32));
    });

    test('throws on invalid length', () {
      expect(
        () => loadKeypair(Uint8List(32)),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Invalid keypair format'),
          ),
        ),
      );
    });
  });

  group('getAddress', () {
    test('returns deterministic base58 address from public key', () async {
      final bytes = Uint8List(64)
        ..fillRange(0, 32, 1)
        ..fillRange(32, 64, 2);
      final keypair = loadKeypair(bytes);

      final a = await getAddress(keypair);
      final b = await getAddress(keypair);

      expect(a, b);
      expect(a.length, inInclusiveRange(32, 44));
    });

    test('returns different addresses for different public keys', () async {
      final one = loadKeypair(Uint8List(64)..fillRange(32, 64, 1));
      final two = loadKeypair(Uint8List(64)..fillRange(32, 64, 2));

      expect(await getAddress(one), isNot(await getAddress(two)));
    });
  });
}
