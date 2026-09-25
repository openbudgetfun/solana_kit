import 'dart:math';
import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

/// Adversarial invariant tests for the numeric decoders.
///
/// A decoder that reads fixed-width fields out of untrusted wire data has one
/// contract: for *any* byte array, it either returns a value or throws
/// [SolanaError]. Nothing else may escape. A raw [RangeError] or [IndexError]
/// means a truncated message reached a buffer access that assumed sufficient
/// length, which is exactly the class of bug that hand-written vectors miss:
/// the vector picks the length, so only the length the author thought of is
/// ever exercised.
///
/// These tests generate arbitrary lengths and offsets, so the boundary between
/// "enough bytes" and "not enough bytes" is probed for every width rather than
/// for the few lengths a fixture happens to cover.
void main() {
  // Fixed seed keeps failures reproducible. A failure prints the offending
  // bytes, so a new case can be pasted into a regression test verbatim.
  final random = Random(20260919);

  /// Decoders paired with the width they consume, in bytes.
  final decoders = <String, (FixedSizeDecoder<int>, int)>{
    'u8': (getU8Decoder(), 1),
    'i8': (getI8Decoder(), 1),
    'u16': (getU16Decoder(), 2),
    'i16': (getI16Decoder(), 2),
    'u32': (getU32Decoder(), 4),
    'i32': (getI32Decoder(), 4),
  };

  final floatDecoders = <String, (FixedSizeDecoder<double>, int)>{
    'f32': (getF32Decoder(), 4),
    'f64': (getF64Decoder(), 8),
  };

  /// The BigInt-backed widths, which read through per-byte index arithmetic
  /// rather than a [ByteData] view and so have their own bounds story.
  final bigIntDecoders = <String, (FixedSizeDecoder<BigInt>, int)>{
    'u64': (getU64Decoder(), 8),
    'i64': (getI64Decoder(), 8),
    'u128': (getU128Decoder(), 16),
    'i128': (getI128Decoder(), 16),
    'u256': (getU256Decoder(), 32),
    'i256': (getI256Decoder(), 32),
  };

  /// Runs [read] against arbitrary buffers and reports anything that is not a
  /// [SolanaError]. Returns the number of inputs that decoded successfully, so
  /// a caller can assert the generator actually reached the success path
  /// instead of only ever producing rejects.
  int assertOnlySolanaErrorsEscape(
    String label,
    void Function(Uint8List bytes, int offset) read,
  ) {
    var decoded = 0;
    final lengths = [
      0,
      1,
      2,
      3,
      4,
      5,
      7,
      8,
      9,
      15,
      16,
      17,
      31,
      32,
      33,
      40,
      64,
      255,
    ];

    for (final length in lengths) {
      for (var trial = 0; trial < 25; trial++) {
        final bytes = Uint8List.fromList(
          List<int>.generate(length, (_) => random.nextInt(256)),
        );
        // Offsets include the legal end-of-buffer position and one past it,
        // so the guard is checked on both sides of its boundary.
        final offsets = <int>{
          0,
          length ~/ 2,
          length,

          if (length > 0) length - 1,
          length + 1,
        };

        for (final offset in offsets) {
          final Uint8List view;
          final int viewOffset;

          if (offset <= length) {
            view = Uint8List.sublistView(bytes, offset);
            viewOffset = 0;
          } else {
            // Reading past the end of the buffer itself.
            view = bytes;
            viewOffset = offset;
          }

          try {
            read(view, viewOffset);
            decoded++;

          } on SolanaError {
            // The documented rejection path.
          } catch (error) {
            fail(
              '$label leaked ${error.runtimeType} instead of SolanaError.\n'
              '  bytes:  ${_hex(bytes)}\n'
              '  offset: $viewOffset (buffer length ${view.length})',
            );
          }
        }
      }
    }

    return decoded;
  }

  group('integer decoders only ever throw SolanaError', () {
    for (final entry in decoders.entries) {
      final (decoder, width) = entry.value;
      test('${entry.key} (width $width)', () {
        final decoded = assertOnlySolanaErrorsEscape(entry.key, decoder.read);
        // If the generator never produced a valid read, the test would pass
        // while proving nothing about the boundary.
        expect(
          decoded,
          greaterThan(0),
          reason: 'no input decoded; the boundary was never exercised',
        );
      });
    }
  });

  group('float decoders only ever throw SolanaError', () {
    for (final entry in floatDecoders.entries) {
      final (decoder, width) = entry.value;
      test('${entry.key} (width $width)', () {
        final decoded = assertOnlySolanaErrorsEscape(entry.key, decoder.read);
        expect(decoded, greaterThan(0));
      });
    }
  });

  group('BigInt decoders only ever throw SolanaError', () {
    for (final entry in bigIntDecoders.entries) {
      final (decoder, width) = entry.value;
      test('${entry.key} (width $width)', () {
        final decoded = assertOnlySolanaErrorsEscape(entry.key, decoder.read);
        expect(decoded, greaterThan(0));
      });
    }
  });

  test('a truncated read reports the codec name and the short length', () {
    // The message is the diagnostic a caller sees when a malformed message
    // arrives; it has to name the field that ran out of bytes.
    try {
      getU32Decoder().read(Uint8List.fromList([1, 2]), 0);
      fail('expected a SolanaError');
    } on SolanaError catch (error) {
      expect(error.code, SolanaErrorCode.codecsInvalidByteLength);
      expect(error.context['codecDescription'], 'u32');
      expect(error.context['expected'], 4);
      expect(error.context['bytesLength'], 2);
    }
  });

  test('an empty read reports the empty-array code', () {
    try {
      getU32Decoder().read(Uint8List(0), 0);
      fail('expected a SolanaError');
    } on SolanaError catch (error) {
      expect(error.code, SolanaErrorCode.codecsCannotDecodeEmptyByteArray);
      expect(error.context['codecDescription'], 'u32');
    }
  });

  test('shortU16 rejects every prefix length shorter than its value needs', () {
    final decoder = getShortU16Decoder();
    // Continuation set, but the buffer ends: never a RangeError.
    for (final bytes in [
      [0x80],
      [0xff],
      [0x80, 0x80],
      [0xff, 0xff],
      [0x80, 0x80, 0x80],
      [0xff, 0xff, 0xff],
    ]) {
      expect(
        () => decoder.read(Uint8List.fromList(bytes), 0),
        throwsA(isA<SolanaError>()),
        reason: 'bytes $bytes',
      );
    }
  });
}

String _hex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
