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
        (Object? value) {
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
        (Object? value) {
          if (value is num && value > 255) return 1;
          return 0;
        },
        (bytes, offset) => bytes.length - offset > 1 ? 1 : 0,
      );
      expect(codec.decode(codec.encode(42)), equals(42));
      expect(codec.decode(codec.encode(1000)), equals(1000));
    });
  });
}
