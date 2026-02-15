import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('addCodecSentinel', () {
    test('encodes the sentinel after the main content', () {
      final innerCodec = VariableSizeCodec<String, String>(
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

      final codec = addCodecSentinel(innerCodec, b('ff'));

      expect(
        codec.encode('68656c6c6f776f726c64'),
        equals(b('68656c6c6f776f726c64ff')),
      );
    });

    test('decodes until the first occurrence of the sentinel is found', () {
      final innerCodec = VariableSizeCodec<String, String>(
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

      final codec = addCodecSentinel(innerCodec, b('ff'));

      expect(
        codec.decode(b('68656c6c6f776f726c64ff0000')),
        equals('68656c6c6f776f726c64'),
      );
    });

    test('fails if the encoded bytes contain the sentinel', () {
      final innerCodec = VariableSizeCodec<String, String>(
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

      final codec = addCodecSentinel(innerCodec, b('ff'));

      // The value contains ff, which is the sentinel.
      expect(
        () => codec.encode('68656c6c6f776f726cff'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsEncodedBytesMustNotIncludeSentinel,
          ),
        ),
      );
    });

    test('fails if the decoded bytes do not contain the sentinel', () {
      final innerCodec = VariableSizeCodec<String, String>(
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

      final codec = addCodecSentinel(innerCodec, b('ff'));

      // No ff sentinel in the bytes.
      expect(
        () => codec.decode(b('68656c6c6f776f726c64000000')),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsSentinelMissingInDecodedBytes,
          ),
        ),
      );
    });

    test('returns the correct fixed size', () {
      final fixedCodec = FixedSizeCodec<String, String>(
        fixedSize: 10,
        write: (_, __, offset) => offset + 10,
        read: (_, offset) => ('', offset + 10),
      );

      final codec = addCodecSentinel(fixedCodec, b('ffff'));

      expect(codec, isA<FixedSizeCodec<String, String>>());
      expect((codec as FixedSizeCodec).fixedSize, equals(12));
    });

    test('returns the correct variable size', () {
      final varCodec = VariableSizeCodec<String, String>(
        getSizeFromValue: (value) => 10,
        write: (_, __, offset) => offset + 10,
        read: (_, offset) => ('', offset + 10),
      );

      final codec = addCodecSentinel(varCodec, b('ffff'));

      expect(codec, isA<VariableSizeCodec<String, String>>());
      expect(
        (codec as VariableSizeCodec<String, String>).getSizeFromValue(
          'helloworld',
        ),
        equals(12),
      );
    });

    test('works with multi-byte sentinels', () {
      final innerCodec = VariableSizeCodec<String, String>(
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

      final codec = addCodecSentinel(innerCodec, b('ffff'));

      // Encode with 2-byte sentinel.
      expect(codec.encode('0102'), equals(b('0102ffff')));

      // Decode with 2-byte sentinel.
      expect(codec.decode(b('0102ffff')), equals('0102'));
    });
  });
}
