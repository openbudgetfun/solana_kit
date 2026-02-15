import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('array codec', () {
    test('encodes with u32 prefix by default', () {
      final codec = getArrayCodec(getU8Codec());
      expect(hex(codec.encode([1, 2, 3])), equals('03000000010203'));
    });

    test('decodes with u32 prefix by default', () {
      final codec = getArrayCodec(getU8Codec());
      final result = codec.decode(b('03000000010203'));
      expect(result, equals([1, 2, 3]));
    });

    test('encodes empty array', () {
      final codec = getArrayCodec(getU8Codec());
      expect(hex(codec.encode([])), equals('00000000'));
    });

    test('decodes empty array', () {
      final codec = getArrayCodec(getU8Codec());
      expect(codec.decode(b('00000000')), isEmpty);
    });

    test('uses custom prefix codec', () {
      final codec = getArrayCodec(
        getU8Codec(),
        size: PrefixedArraySize(getU8Codec()),
      );
      expect(hex(codec.encode([1, 2, 3])), equals('03010203'));
      expect(codec.decode(b('03010203')), equals([1, 2, 3]));
    });

    test('uses fixed size', () {
      final codec = getArrayCodec(getU8Codec(), size: const FixedArraySize(3));
      expect(hex(codec.encode([1, 2, 3])), equals('010203'));
      expect(codec.decode(b('010203')), equals([1, 2, 3]));
    });

    test('throws on wrong number of items for fixed size', () {
      final codec = getArrayCodec(getU8Codec(), size: const FixedArraySize(3));
      expect(
        () => codec.encode([1, 2]),
        throwsA(
          predicate(
            (e) => isSolanaError(e, SolanaErrorCode.codecsInvalidNumberOfItems),
          ),
        ),
      );
    });

    test('uses remainder size', () {
      final codec = getArrayCodec(
        getU8Codec(),
        size: const RemainderArraySize(),
      );
      expect(hex(codec.encode([1, 2, 3])), equals('010203'));
      expect(codec.decode(b('010203')), equals([1, 2, 3]));
    });

    test('encodes with u32 items', () {
      final codec = getArrayCodec(getU32Codec());
      expect(hex(codec.encode([1, 2])), equals('020000000100000002000000'));
    });

    test('returns empty for prefix with no remaining bytes', () {
      final codec = getArrayCodec(getU8Codec());
      // No bytes at all - the decoder should handle gracefully
      expect(codec.decode(b('')), isEmpty);
    });
  });
}
