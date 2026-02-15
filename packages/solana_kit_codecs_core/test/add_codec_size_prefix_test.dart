import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('addCodecSizePrefix', () {
    test('encodes the byte length before the content', () {
      // A simple 4-byte number prefix codec (little-endian u32).
      final numberCodec = FixedSizeCodec<num, num>(
        fixedSize: 4,
        write: (value, bytes, offset) {
          final v = value.toInt();
          bytes[offset] = v & 0xff;
          bytes[offset + 1] = (v >> 8) & 0xff;
          bytes[offset + 2] = (v >> 16) & 0xff;
          bytes[offset + 3] = (v >> 24) & 0xff;
          return offset + 4;
        },
        read: (bytes, offset) {
          final v =
              bytes[offset] |
              (bytes[offset + 1] << 8) |
              (bytes[offset + 2] << 16) |
              (bytes[offset + 3] << 24);
          return (v, offset + 4);
        },
      );

      // A simple content codec.
      final contentCodec = FixedSizeCodec<String, String>(
        fixedSize: 10,
        write: (value, bytes, offset) {
          final src = b(value);
          bytes.setAll(offset, src);
          return offset + src.length;
        },
        read: (bytes, offset) {
          return (h(bytes.sublist(offset, offset + 10)), offset + 10);
        },
      );

      final prefixedCodec = addCodecSizePrefix(contentCodec, numberCodec);

      // Encoding should place the size (10) as a 4-byte LE prefix.
      final encoded = prefixedCodec.encode('68656c6c6f776f726c64');
      // Size prefix: 10 = 0x0a000000 in LE.
      expect(encoded, equals(b('0a00000068656c6c6f776f726c64')));
    });

    test('decodes the byte length before reading the content', () {
      final numberCodec = FixedSizeCodec<num, num>(
        fixedSize: 4,
        write: (value, bytes, offset) {
          final v = value.toInt();
          bytes[offset] = v & 0xff;
          bytes[offset + 1] = (v >> 8) & 0xff;
          bytes[offset + 2] = (v >> 16) & 0xff;
          bytes[offset + 3] = (v >> 24) & 0xff;
          return offset + 4;
        },
        read: (bytes, offset) {
          final v =
              bytes[offset] |
              (bytes[offset + 1] << 8) |
              (bytes[offset + 2] << 16) |
              (bytes[offset + 3] << 24);
          return (v, offset + 4);
        },
      );

      final contentCodec = VariableSizeCodec<String, String>(
        getSizeFromValue: (value) => (value.length / 2).ceil(),
        write: (value, bytes, offset) {
          final src = b(value);
          bytes.setAll(offset, src);
          return offset + src.length;
        },
        read: (bytes, offset) {
          return (h(bytes.sublist(offset)), bytes.length);
        },
      );

      final prefixedCodec = addCodecSizePrefix(contentCodec, numberCodec);

      // Bytes: 0a000000 (size = 10) followed by 10 bytes of content.
      final decoded = prefixedCodec.decode(b('0a00000068656c6c6f776f726c64'));
      expect(decoded, equals('68656c6c6f776f726c64'));
    });

    test('lets the size codec fail if the byte length overflows', () {
      // A 1-byte size prefix that can only hold values up to 255.
      final numberCodec = FixedSizeCodec<num, num>(
        fixedSize: 1,
        write: (value, bytes, offset) {
          if (value.toInt() > 255) {
            throw StateError('overflow');
          }
          bytes[offset] = value.toInt();
          return offset + 1;
        },
        read: (bytes, offset) => (bytes[offset], offset + 1),
      );

      // Content codec with fixedSize 256.
      final contentCodec = FixedSizeCodec<String, String>(
        fixedSize: 256,
        write: (_, __, offset) => offset + 256,
        read: (_, offset) => ('', offset + 256),
      );

      final prefixedCodec = addCodecSizePrefix(contentCodec, numberCodec);

      expect(() => prefixedCodec.encode(''), throwsA(isA<StateError>()));
    });

    test('returns the correct fixed size', () {
      final numberCodec = FixedSizeCodec<num, num>(
        fixedSize: 4,
        write: (_, __, offset) => offset + 4,
        read: (_, offset) => (0, offset + 4),
      );

      final contentCodec = FixedSizeCodec<String, String>(
        fixedSize: 10,
        write: (_, __, offset) => offset + 10,
        read: (_, offset) => ('', offset + 10),
      );

      final prefixedCodec = addCodecSizePrefix(contentCodec, numberCodec);

      expect(prefixedCodec, isA<FixedSizeCodec<String, String>>());
      assertIsFixedSize(prefixedCodec);
      expect((prefixedCodec as FixedSizeCodec).fixedSize, equals(14));
    });

    test('returns the correct variable size', () {
      final numberCodec = FixedSizeCodec<num, num>(
        fixedSize: 4,
        write: (_, __, offset) => offset + 4,
        read: (_, offset) => (0, offset + 4),
      );

      final contentCodec = VariableSizeCodec<String, String>(
        getSizeFromValue: (value) => 10,
        write: (_, __, offset) => offset + 10,
        read: (_, offset) => ('', offset + 10),
      );

      final prefixedCodec = addCodecSizePrefix(contentCodec, numberCodec);

      expect(prefixedCodec, isA<VariableSizeCodec<String, String>>());
      assertIsVariableSize(prefixedCodec);
      expect(
        (prefixedCodec as VariableSizeCodec<String, String>).getSizeFromValue(
          'helloworld',
        ),
        equals(14),
      );
    });
  });
}
