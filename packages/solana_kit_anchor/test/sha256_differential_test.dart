import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:solana_kit_anchor/solana_kit_anchor.dart';
import 'package:test/test.dart';

/// Differential tests for the hand-written SHA-256.
///
/// Anchor discriminators are `sha256("<namespace>:<name>")` truncated to eight
/// bytes, so a bug in this hash silently changes which instruction an Anchor
/// program dispatches to. Fixed NIST vectors catch a broken round function, but
/// they do not probe the padding and multi-block boundaries where a length bug
/// hides: the block loop is only wrong at particular input lengths, and a
/// handful of vectors rarely lands on the interesting ones.
///
/// These tests compare the implementation against `package:crypto`, an
/// independent SHA-256, over randomized inputs and every length around the
/// 64-byte block and padding boundaries. Agreement across thousands of inputs
/// is much stronger evidence than a handful of hand-checked digests, and the
/// reference is a second implementation rather than another fixture written by
/// the same author.
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
      expect(hexOf(sha256(const [])), reference(const []));
      for (var byte = 0; byte < 256; byte += 17) {
        expect(
          hexOf(sha256([byte])),
          reference([byte]),
          reason: 'byte $byte',
        );
      }
    });

    test('every length through the padding and block boundaries', () {
      // 55 is where the 0x80 marker exactly fills a block, 56 forces the
      // length into a second block, and 64 is the first full block. Lengths
      // just past each are where an off-by-one in padding shows up.
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

    test('ASCII text inputs of every boundary length', () {
      for (final length in [0, 1, 2, 31, 32, 33, 55, 56, 57, 63, 64, 65, 100]) {
        final input = utf8.encode('a' * length);
        expect(
          hexOf(sha256(input)),
          reference(input),
          reason: 'length $length',
        );
      }
    });
  });

  group('anchor discriminators match an independent hash', () {
    test('instruction and account names produce the reference sighash', () {
      // The discriminator is the first eight bytes of the namespaced hash, so
      // it inherits any hash defect. Checking the full digest above plus the
      // namespace separator here pins the framing as well as the hash.
      for (final name in [
        'initialize',
        'update',
        'close',
        'account_and_event_arg_and_field',
        'with_underscores_and_digits_123',
      ]) {
        final expected = reference(utf8.encode('global:$name')).substring(
          0,
          16,
        );
        expect(
          hexOf(instructionDiscriminator(name)),
          expected,
          reason: 'instruction $name',
        );
      }
    });
  });
}
