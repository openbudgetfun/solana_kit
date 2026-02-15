import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('fixCodecSize', () {
    test('keeps same-sized byte arrays as-is', () {
      final mock = getMockVariableCodec(initialSize: 10, innerSize: 10);
      mock.setSizeFromValue(10);

      // Override write to produce known bytes.
      final codec = VariableSizeCodec<Object?, String>(
        getSizeFromValue: (_) => 10,
        write: (_, bytes, offset) {
          final src = b('08050c0c0f170f120c04');
          bytes.setAll(offset, src);
          return offset + 10;
        },
        read: (bytes, offset) {
          return (h(bytes.sublist(offset)), bytes.length);
        },
      );

      // Encode: same size, bytes unchanged.
      expect(
        fixCodecSize(codec, 10).encode('helloworld'),
        equals(b('08050c0c0f170f120c04')),
      );

      // Decode: same size.
      final decoded = fixCodecSize(codec, 10).decode(b('08050c0c0f170f120c04'));
      expect(decoded, equals('08050c0c0f170f120c04'));

      // Read with offset.
      final (value, offset) = fixCodecSize(
        codec,
        10,
      ).read(b('ffff08050c0c0f170f120c04'), 2);
      expect(value, equals('08050c0c0f170f120c04'));
      expect(offset, equals(12));
    });

    test('truncates over-sized byte arrays', () {
      final codec = VariableSizeCodec<Object?, String>(
        getSizeFromValue: (_) => 10,
        write: (_, bytes, offset) {
          final src = b('08050c0c0f170f120c04');
          bytes.setAll(offset, src);
          return offset + 10;
        },
        read: (bytes, offset) {
          return (h(bytes.sublist(offset)), bytes.length);
        },
      );

      // Encode truncated to 5 bytes.
      expect(
        fixCodecSize(codec, 5).encode('helloworld'),
        equals(b('08050c0c0f')),
      );

      // Decode with truncation.
      final decoded = fixCodecSize(codec, 5).decode(b('08050c0c0f170f120c04'));
      expect(decoded, equals('08050c0c0f'));

      // Read with offset.
      final (value, offset) = fixCodecSize(
        codec,
        5,
      ).read(b('ffff08050c0c0f170f120c04'), 2);
      expect(value, equals('08050c0c0f'));
      expect(offset, equals(7));
    });

    test('pads under-sized byte arrays', () {
      final codec = VariableSizeCodec<Object?, String>(
        getSizeFromValue: (_) => 5,
        write: (_, bytes, offset) {
          final src = b('08050c0c0f');
          bytes.setAll(offset, src);
          return offset + 5;
        },
        read: (bytes, offset) {
          return (h(bytes.sublist(offset)), bytes.length);
        },
      );

      // Encode padded to 10 bytes.
      expect(
        fixCodecSize(codec, 10).encode('hello'),
        equals(b('08050c0c0f0000000000')),
      );

      // Decode with padding.
      final decoded = fixCodecSize(codec, 10).decode(b('08050c0c0f0000000000'));
      expect(decoded, equals('08050c0c0f0000000000'));

      // Read with offset.
      final (value, offset) = fixCodecSize(
        codec,
        10,
      ).read(b('ffff08050c0c0f0000000000'), 2);
      expect(value, equals('08050c0c0f0000000000'));
      expect(offset, equals(12));

      // Error when not enough bytes.
      expect(
        () => fixCodecSize(codec, 10).decode(b('08050c0c0f')),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsInvalidByteLength,
          ),
        ),
      );
    });

    test('has the right sizes', () {
      final codec = VariableSizeCodec<Object?, String>(
        getSizeFromValue: (_) => 0,
        write: (_, __, offset) => offset,
        read: (_, offset) => ('', offset),
      );
      expect(fixCodecSize(codec, 12).fixedSize, equals(12));
      expect(fixCodecSize(codec, 42).fixedSize, equals(42));
    });

    test('can fix a codec that requires a minimum amount of bytes', () {
      // A mock u32 codec that requires 4 bytes.
      final u32 = FixedSizeCodec<int, int>(
        fixedSize: 4,
        read: (bytes, offset) {
          if (bytes.sublist(offset).length < 4) {
            throw StateError('Not enough bytes to decode a u32.');
          }
          return (bytes[offset], offset + 4);
        },
        write: (value, bytes, offset) {
          bytes[offset] = value;
          return offset + 4;
        },
      );

      // Synthesize a u24 from that u32 using fixCodecSize.
      final u24 = fixCodecSize(u32, 3);

      // Encode.
      final bytes = u24.encode(42);
      expect(bytes, equals(Uint8List.fromList([42, 0, 0])));

      // Decode.
      final (value, offset) = u24.read(bytes, 0);
      expect(value, equals(42));
      expect(offset, equals(3));
    });
  });

  group('fixEncoderSize', () {
    test('can fix an encoder to a given amount of bytes', () {
      // Same size: 10 -> 10.
      final encoder10 = VariableSizeEncoder<String>(
        getSizeFromValue: (_) => 10,
        write: (_, bytes, offset) {
          bytes.setAll(offset, b('08050c0c0f170f120c04'));
          return offset + 10;
        },
      );
      expect(
        fixEncoderSize(encoder10, 10).encode('helloworld'),
        equals(b('08050c0c0f170f120c04')),
      );

      // Truncate: 10 -> 5.
      expect(
        fixEncoderSize(encoder10, 5).encode('helloworld'),
        equals(b('08050c0c0f')),
      );

      // Pad: 5 -> 10.
      final encoder5 = VariableSizeEncoder<String>(
        getSizeFromValue: (_) => 5,
        write: (_, bytes, offset) {
          bytes.setAll(offset, b('08050c0c0f'));
          return offset + 5;
        },
      );
      expect(
        fixEncoderSize(encoder5, 10).encode('hello'),
        equals(b('08050c0c0f0000000000')),
      );
    });
  });

  group('fixDecoderSize', () {
    test('can fix a decoder to a given amount of bytes', () {
      final decoder = VariableSizeDecoder<String>(
        read: (bytes, offset) {
          return (h(bytes.sublist(offset)), bytes.length);
        },
      );

      // Same size.
      final decoded10 = fixDecoderSize(
        decoder,
        10,
      ).decode(b('08050c0c0f170f120c04'));
      expect(decoded10, equals('08050c0c0f170f120c04'));

      // Truncate: read only 5 bytes.
      final decoded5 = fixDecoderSize(
        decoder,
        5,
      ).decode(b('08050c0c0f170f120c04'));
      expect(decoded5, equals('08050c0c0f'));

      // Pad: read 10 bytes from padded data.
      final decoded10b = fixDecoderSize(
        decoder,
        10,
      ).decode(b('08050c0c0f0000000000'));
      expect(decoded10b, equals('08050c0c0f0000000000'));

      // Error when not enough bytes.
      expect(
        () => fixDecoderSize(decoder, 10).decode(b('08050c0c0f')),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsInvalidByteLength,
          ),
        ),
      );
    });
  });
}
