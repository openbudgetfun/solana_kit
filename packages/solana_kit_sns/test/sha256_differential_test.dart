import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:solana_kit_sns/solana_kit_sns.dart';
import 'package:test/test.dart';

/// Differential tests for the hand-written SHA-256.
///
/// `getHashedName` hashes `"SPL Name Service" + name` to derive a name account
/// address, so a defect here resolves to the wrong account: the failure is a
/// wrong address rather than an exception, and the existing fixed vectors only
/// cover the name lengths someone thought to write down.
///
/// These tests compare against `package:crypto`, an independent SHA-256
/// implementation, across randomized inputs and every length near the 64-byte
/// block and padding boundaries. Two independent implementations agreeing over
/// thousands of inputs is far stronger evidence than additional fixtures, and
/// it fails loudly if a future optimization breaks the padding.
void main() {
  final random = Random(20260919);

  Uint8List randomBytes(int length) => Uint8List.fromList(
    List<int>.generate(length, (_) => random.nextInt(256)),
  );

  String hexOf(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  String reference(List<int> input) =>
      hexOf(crypto.sha256.convert(input).bytes);

  group('sha256 matches package:crypto', () {
    test('empty and single-byte inputs', () {
      expect(hexOf(sha256(Uint8List(0))), reference(const []));
      for (var byte = 0; byte < 256; byte += 17) {
        expect(
          hexOf(sha256(Uint8List.fromList([byte]))),
          reference([byte]),
          reason: 'byte $byte',
        );
      }
    });

    test('every length through the padding and block boundaries', () {
      for (var length = 0; length <= 200; length++) {
        final input = randomBytes(length);
        expect(
          hexOf(sha256(input)),
          reference(input),
          reason: 'length $length',
        );
      }
    });

    test('multi-block lengths well beyond one block', () {
      for (final length in [255, 256, 257, 511, 512, 513, 1000, 4096, 10000]) {
        final input = randomBytes(length);
        expect(
          hexOf(sha256(input)),
          reference(input),
          reason: 'length $length',
        );
      }
    });

    test('randomized inputs across all lengths', () {
      for (var trial = 0; trial < 400; trial++) {
        final length = random.nextInt(300);
        final input = randomBytes(length);
        expect(
          hexOf(sha256(input)),
          reference(input),
          reason: 'length $length',
        );
      }
    });

    test('all-zero and all-0xff buffers of every boundary length', () {
      for (final length in [0, 1, 55, 56, 57, 63, 64, 65, 127, 128, 129]) {
        for (final fill in [0x00, 0xff]) {
          final input = Uint8List(length)..fillRange(0, length, fill);
          expect(
            hexOf(sha256(input)),
            reference(input),
            reason: 'length $length filled with $fill',
          );
        }
      }
    });

    test('high bytes above 0x7f are hashed as raw bytes', () {
      // SNS names are UTF-8, but the hash must treat the input as bytes rather
      // than code points; a name with multi-byte characters exercises that.
      for (final name in ['café', '日本語', 'emoji-🚀', 'ß']) {
        final encoded = Uint8List.fromList(utf8.encode(name));
        expect(hexOf(sha256(encoded)), reference(encoded), reason: name);
      }
    });
  });

  group('getHashedName matches an independent hash', () {
    test('domain names hash the SPL namespace prefix', () {
      for (final name in ['', 'example', 'solana', 'a' * 55, 'a' * 64]) {
        final expected = reference(utf8.encode('SPL Name Service$name'));
        expect(
          hexOf(getHashedName(name).toList()),
          expected,
          reason: 'name "$name"',
        );
      }
    });
  });
}
