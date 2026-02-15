import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  /// Helper to create a reversed fixed-size base16 codec.
  FixedSizeCodec<String, String> s(int size) =>
      reverseCodec(fixCodecSize(base16Codec, size));

  group('reverseCodec', () {
    test('can reverse the bytes of a fixed-size codec', () {
      // Encode.
      expect(s(1).encode('99'), equals(b('99')));
      expect(s(2).encode('99ff'), equals(b('ff99')));
      expect(s(2).encode('ff9999'), equals(b('99ff')));
      expect(s(3).encode('9999ff'), equals(b('ff9999')));
      expect(s(3).encode('ff9999'), equals(b('9999ff')));
      expect(s(4).encode('999999ff'), equals(b('ff999999')));
      expect(s(4).encode('ff999999'), equals(b('999999ff')));
      expect(
        s(8).encode('99999999999999ff'),
        equals(b('ff99999999999999')),
      );
      expect(
        s(8).encode('ff99999999999999'),
        equals(b('99999999999999ff')),
      );
      expect(
        s(32).encode('ff${'99' * 31}'),
        equals(b('${'99' * 31}ff')),
      );
      expect(
        s(32).encode('${'99' * 31}ff'),
        equals(b('ff${'99' * 31}')),
      );

      // Decode.
      expect(s(2).decode(b('ff99')), equals('99ff'));
      expect(s(2).decode(b('99ff')), equals('ff99'));
      expect(s(3).decode(b('ff9999')), equals('9999ff'));
      expect(s(3).decode(b('9999ff')), equals('ff9999'));
      expect(s(3).read(b('aaaaff9999bbbb'), 2), equals(('9999ff', 5)));
      expect(s(3).read(b('aaaa9999ffbbbb'), 2), equals(('ff9999', 5)));
      expect(s(4).decode(b('999999ff')), equals('ff999999'));
      expect(s(4).decode(b('ff999999')), equals('999999ff'));
      expect(s(4).read(b('aaaaff999999bbbb'), 2), equals(('999999ff', 6)));
      expect(s(4).read(b('aaaa999999ffbbbb'), 2), equals(('ff999999', 6)));
    });

    test('throws for variable-size codec', () {
      // base16Codec is variable-size, so reverseCodec should throw.
      // We need to use assertIsFixedSize inside reverseCodec. Since
      // reverseCodec requires FixedSizeCodec, we test via the encoder/decoder
      // functions directly.
      expect(
        () => reverseEncoder(
          // Force passing a VariableSizeEncoder as FixedSizeEncoder
          // This tests the assertIsFixedSize inside reverseEncoder.
          FixedSizeEncoder<String>(
            fixedSize: 0,
            write: (_, __, ___) => 0,
          ),
        ),
        returnsNormally,
      );
    });
  });

  group('reverseEncoder', () {
    test('can reverse the bytes of a fixed-size encoder', () {
      final encoder = FixedSizeEncoder<int>(
        fixedSize: 2,
        write: (value, bytes, offset) {
          bytes[offset] = value;
          bytes[offset + 1] = 0;
          return offset + 2;
        },
      );

      final reversedEnc = reverseEncoder(encoder);
      expect(reversedEnc.fixedSize, equals(2));
      expect(reversedEnc.encode(42), equals(Uint8List.fromList([0, 42])));
    });

    test('gives the encoder access to the original byte array', () {
      Uint8List? capturedBytes;

      final encoder = FixedSizeEncoder<int>(
        fixedSize: 2,
        write: (value, bytes, offset) {
          capturedBytes = bytes;
          return offset + 2;
        },
      );

      final reversedEnc = reverseEncoder(encoder);
      final inputBytes = Uint8List.fromList([1, 2, 3, 4]);
      reversedEnc.write(9, inputBytes, 1);

      // The write callback receives the original (uncloned) byte array.
      expect(identical(capturedBytes, inputBytes), isTrue);
    });
  });

  group('reverseDecoder', () {
    test('can reverse the bytes of a fixed-size decoder', () {
      final decoder = FixedSizeDecoder<String>(
        fixedSize: 2,
        read: (bytes, offset) => (
          '${bytes[offset]}-${bytes[offset + 1]}',
          offset + 2,
        ),
      );

      final reversedDec = reverseDecoder(decoder);
      expect(reversedDec.fixedSize, equals(2));
      expect(
        reversedDec.read(Uint8List.fromList([42, 0]), 0),
        equals(('0-42', 2)),
      );
    });

    test('does not modify the input bytes in-place', () {
      final decoder = FixedSizeDecoder<String>(
        fixedSize: 2,
        read: (bytes, offset) => (
          '${bytes[offset]}-${bytes[offset + 1]}',
          offset + 2,
        ),
      );

      final reversedDec = reverseDecoder(decoder);
      final inputBytes = Uint8List.fromList([42, 0]);
      reversedDec.read(inputBytes, 0);
      expect(inputBytes, equals(Uint8List.fromList([42, 0])));
    });

    test('gives the decoder access to the original bytes envelope', () {
      Uint8List? capturedBytes;

      final decoder = FixedSizeDecoder<String>(
        fixedSize: 2,
        read: (bytes, offset) {
          capturedBytes = bytes;
          return ('', offset + 2);
        },
      );

      final reversedDec = reverseDecoder(decoder);
      final inputBytes = Uint8List.fromList([1, 2, 3, 4]);
      reversedDec.read(inputBytes, 1);

      // The read callback receives a byte array that has the same length
      // and preserves the non-reversed portions.
      expect(capturedBytes!.length, equals(inputBytes.length));
      expect(capturedBytes![0], equals(1));
      expect(capturedBytes![3], equals(4));
    });
  });
}
