import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('map codec', () {
    test('encodes a map with u32 prefix', () {
      final codec = getMapCodec(getU8Codec(), getU8Codec());
      final result = codec.encode({1: 10, 2: 20});
      // u32 prefix (2 entries) + 2 key-value pairs
      expect(hex(result), equals('02000000010a0214'));
    });

    test('decodes a map with u32 prefix', () {
      final codec = getMapCodec(getU8Codec(), getU8Codec());
      final result = codec.decode(b('02000000010a0214'));
      expect(result[1], equals(10));
      expect(result[2], equals(20));
    });

    test('encodes empty map', () {
      final codec = getMapCodec(getU8Codec(), getU8Codec());
      expect(hex(codec.encode({})), equals('00000000'));
    });

    test('decodes empty map', () {
      final codec = getMapCodec(getU8Codec(), getU8Codec());
      expect(codec.decode(b('00000000')), isEmpty);
    });

    test('uses fixed size', () {
      final codec = getMapCodec(
        getU8Codec(),
        getU8Codec(),
        size: const FixedArraySize(2),
      );
      expect(hex(codec.encode({1: 10, 2: 20})), equals('010a0214'));
      final decoded = codec.decode(b('010a0214'));
      expect(decoded[1], equals(10));
      expect(decoded[2], equals(20));
    });

    test('roundtrips', () {
      final codec = getMapCodec(getU8Codec(), getU32Codec());
      final original = {1: 100, 2: 200};
      final decoded = codec.decode(codec.encode(original));
      expect(decoded, equals(original));
    });
  });
}
