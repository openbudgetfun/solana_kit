import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('union codec', () {
    test('encodes by selecting variant from value', () {
      // Variant 0: u8, Variant 1: u32
      final encoder = getUnionEncoder(
        [
          getU8Encoder() as Encoder<Object?>,
          getU32Encoder() as Encoder<Object?>,
        ],
        (value) {
          // Use value > 255 as u32, otherwise u8
          if (value is num && value > 255) return 1;
          return 0;
        },
      );
      expect(hex(encoder.encode(42)), equals('2a'));
      expect(hex(encoder.encode(1000)), equals('e8030000'));
    });

    test('decodes by selecting variant from bytes', () {
      final decoder = getUnionDecoder([
        getU8Decoder() as Decoder<Object?>,
        getU32Decoder() as Decoder<Object?>,
      ], (bytes, offset) => bytes.length - offset > 1 ? 1 : 0);
      expect(decoder.decode(b('2a')), equals(42));
      expect(decoder.decode(b('e8030000')), equals(1000));
    });

    test('throws on invalid variant index', () {
      final encoder = getUnionEncoder([
        getU8Encoder() as Encoder<Object?>,
      ], (_) => 5);
      expect(
        () => encoder.encode(42),
        throwsA(
          predicate(
            (e) =>
                isSolanaError(e, SolanaErrorCode.codecsUnionVariantOutOfRange),
          ),
        ),
      );
    });

    test('roundtrips with codec', () {
      final codec = getUnionCodec(
        [
          getU8Codec() as Codec<Object?, Object?>,
          getU32Codec() as Codec<Object?, Object?>,
        ],
        (value) {
          if (value is num && value > 255) return 1;
          return 0;
        },
        (bytes, offset) => bytes.length - offset > 1 ? 1 : 0,
      );
      expect(codec.decode(codec.encode(42)), equals(42));
      expect(codec.decode(codec.encode(1000)), equals(1000));
    });
  });

  group('typed union helpers', () {
    test('encodes and decodes Union2 values', () {
      final codec = getUnion2Codec<num, int, num, int>(
        getU8Codec(),
        getU32Codec(),
        (bytes, offset) => bytes.length - offset > 1 ? 1 : 0,
      );

      final encodedSmall = codec.encode(const Union2Variant0<num, num>(42));
      final encodedLarge = codec.encode(const Union2Variant1<num, num>(1000));

      expect(hex(encodedSmall), equals('2a'));
      expect(hex(encodedLarge), equals('e8030000'));
      expect(codec.decode(encodedSmall), isA<Union2Variant0<int, int>>());
      expect(
        (codec.decode(encodedSmall) as Union2Variant0<int, int>).value,
        equals(42),
      );
      expect(codec.decode(encodedLarge), isA<Union2Variant1<int, int>>());
      expect(
        (codec.decode(encodedLarge) as Union2Variant1<int, int>).value,
        equals(1000),
      );
    });

    test('encodes and decodes Union3 values', () {
      final codec = getUnion3Codec<num, int, num, int, num, int>(
        getU8Codec(),
        getU16Codec(),
        getU32Codec(),
        (bytes, offset) {
          final remaining = bytes.length - offset;
          if (remaining == 1) return 0;
          if (remaining == 2) return 1;
          return 2;
        },
      );

      final v0 = codec.decode(
        codec.encode(const Union3Variant0<num, num, num>(7)),
      );
      final v1 = codec.decode(
        codec.encode(const Union3Variant1<num, num, num>(700)),
      );
      final v2 = codec.decode(
        codec.encode(const Union3Variant2<num, num, num>(70000)),
      );

      expect(v0, isA<Union3Variant0<int, int, int>>());
      expect(v1, isA<Union3Variant1<int, int, int>>());
      expect(v2, isA<Union3Variant2<int, int, int>>());
      expect((v0 as Union3Variant0<int, int, int>).value, equals(7));
      expect((v1 as Union3Variant1<int, int, int>).value, equals(700));
      expect((v2 as Union3Variant2<int, int, int>).value, equals(70000));
    });
  });
}
