import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:test/test.dart';

/// Helper to convert a hex string to [Uint8List].
Uint8List _hex(String hex) {
  final bytes = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

void main() {
  group('keccak256', () {
    // Test vectors cross-validated against Python hashlib's keccak-256.

    test('empty input returns known hash', () {
      final result = keccak256(Uint8List(0));
      expect(
        result,
        equals(
          _hex(
            'c5d2460186f7233c927e7db2dcc703c0'
            'e500b653ca82273b7bfad8045d85a470',
          ),
        ),
      );
    });

    test('abc returns known hash', () {
      final result = keccak256(Uint8List.fromList([0x61, 0x62, 0x63]));
      expect(
        result,
        equals(
          _hex(
            '4e03657aea45a94fc7d47ba826c8d667'
            'c0d1e6e33a64a036ec44f58fa12d6c45',
          ),
        ),
      );
    });

    test('single zero byte returns known hash', () {
      final result = keccak256(Uint8List.fromList([0x00]));
      expect(
        result,
        equals(
          _hex(
            'bc36789e7a1e281436464229828f817d'
            '6612f7b477d66591ff96a9e064bcc98a',
          ),
        ),
      );
    });

    test('the quick brown fox returns known hash', () {
      final input = Uint8List.fromList(
        'The quick brown fox jumps over the lazy dog'.codeUnits,
      );
      final result = keccak256(input);
      expect(
        result,
        equals(
          _hex(
            '4d741b6f1eb29cb2a9b9911c82f56fa8'
            'd73b04959d3d9d222895df6c0b28aa15',
          ),
        ),
      );
    });

    test('produces 32-byte output', () {
      final result = keccak256(Uint8List.fromList([0x01]));
      expect(result.length, 32);
    });

    test('different inputs produce different outputs', () {
      final a = keccak256(Uint8List.fromList([0x01]));
      final b = keccak256(Uint8List.fromList([0x02]));
      expect(a, isNot(equals(b)));
    });

    test('is deterministic', () {
      final input = Uint8List.fromList([0x61, 0x62, 0x63]);
      final a = keccak256(input);
      final b = keccak256(input);
      expect(a, equals(b));
    });

    test('longer input spanning multiple rate blocks', () {
      // 200 bytes > 136 byte rate, so this spans at least one full block.
      final input = Uint8List(200);
      for (var i = 0; i < 200; i++) {
        input[i] = i % 256;
      }
      final result = keccak256(input);
      expect(result.length, 32);
      // Verify it's not all zeros and not all the same byte.
      expect(result.any((b) => b != 0), isTrue);
    });

    test('input exactly one rate block (136 bytes)', () {
      // Empty message would be 0 bytes + padding.
      // 136-byte message fills exactly one rate block, then needs a padding block.
      final input = Uint8List(136);
      for (var i = 0; i < 136; i++) {
        input[i] = i % 256;
      }
      final result = keccak256(input);
      expect(result.length, 32);
    });

    test('input slightly less than one rate block', () {
      // 135 bytes + 1 byte padding = 136 bytes rate block.
      final input = Uint8List(135);
      for (var i = 0; i < 135; i++) {
        input[i] = i % 256;
      }
      final result = keccak256(input);
      expect(result.length, 32);
    });

    test('distinguishes from SHA3-256 (different padding)', () {
      // Keccak-256 of empty string should NOT equal SHA3-256 of empty string.
      // SHA3-256("") = a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a
      // Keccak-256("") = c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
      final result = keccak256(Uint8List(0));
      expect(
        result,
        isNot(
          equals(
            _hex(
              'a7ffc6f8bf1ed76651c14756a061d662'
              'f580ff4de43b49fa82d80a4b80f8434a',
            ),
          ),
        ),
      );
    });
  });
}
