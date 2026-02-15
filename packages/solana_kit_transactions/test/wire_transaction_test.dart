import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('getBase64EncodedWireTransaction', () {
    test('serializes a transaction to wire format', () {
      final transaction = Transaction(
        messageBytes: Uint8List.fromList([
          128, 2, 1, 1, 3, 15, 30, 107, 20, 33, 192, 74, 7, 4, 49, 38, //
          92, 25, 197, 187, 238, 25, 146, 186, 232, 175, 209, 205, 7, 142,
          248, 175, 112, 71, 220, 17, 247, 45, 91, 65, 60, 101, 64, 222,
          21, 12, 147, 115, 20, 77, 81, 51, 202, 76, 184, 48, 186, 15,
          117, 103, 22, 172, 234, 14, 80, 215, 148, 53, 229, 60, 121, 172,
          80, 135, 1, 40, 28, 16, 196, 153, 112, 103, 22, 239, 184, 102,
          74, 235, 162, 191, 71, 52, 30, 59, 226, 189, 193, 31, 112, 71,
          220, 30, 60, 214, 40, 67, 128, 148, 14, 8, 98, 76, 184, 51,
          139, 119, 220, 51, 37, 117, 209, 95, 163, 154, 15, 29, 241, 94,
          224, 143, 184, 35, 238, 1, 2, 1, 1, 0, 0,
        ]),
        signatures: {
          const Address('22222222222222222222222222222222222222222222'): null,
          const Address(
            '44444444444444444444444444444444444444444444',
          ): SignatureBytes(
            Uint8List.fromList([
              0x65, 0xc9, 0xfa, 0x89, 0xe6, 0xab, 0xdb, 0x8b, //
              0x62, 0x79, 0xaf, 0x58, 0x43, 0x82, 0x48, 0xa6,
              0x7f, 0xbc, 0x40, 0xb2, 0x37, 0x06, 0x76, 0xe0,
              0xed, 0xa6, 0xef, 0x73, 0x7d, 0x39, 0xfc, 0x30,
              0x6c, 0x80, 0x80, 0xc0, 0x66, 0x2d, 0x32, 0x7a,
              0x56, 0xb5, 0xb9, 0xd3, 0xc1, 0x20, 0xd7, 0x15,
              0xa4, 0x34, 0x3f, 0x93, 0x8a, 0x23, 0xee, 0x08,
              0xfb, 0x82, 0x3e, 0xe0, 0x8f, 0xb8, 0x23, 0xee,
            ]),
          ),
        },
      );

      final encoded = getBase64EncodedWireTransaction(transaction);
      expect(encoded, isA<String>());
      expect(encoded.isNotEmpty, isTrue);
      // The encoded string should be a valid base64 string.
      expect(RegExp(r'^[A-Za-z0-9+/]+=*$').hasMatch(encoded), isTrue);
    });

    test('produces a deterministic result', () {
      final sigBytes = SignatureBytes(
        Uint8List.fromList(List<int>.filled(64, 42)),
      );
      final transaction = Transaction(
        messageBytes: Uint8List.fromList([1, 2, 3, 4]),
        signatures: {
          const Address('11111111111111111111111111111111'): sigBytes,
        },
      );

      final encoded1 = getBase64EncodedWireTransaction(transaction);
      final encoded2 = getBase64EncodedWireTransaction(transaction);
      expect(encoded1, encoded2);
    });
  });
}
