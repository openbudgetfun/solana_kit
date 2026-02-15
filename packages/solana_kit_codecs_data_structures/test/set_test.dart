import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('set codec', () {
    test('encodes a set with u32 prefix', () {
      final codec = getSetCodec(getU8Codec());
      final result = codec.encode({1, 2, 3});
      expect(hex(result), equals('03000000010203'));
    });

    test('decodes a set with u32 prefix', () {
      final codec = getSetCodec(getU8Codec());
      final result = codec.decode(b('03000000010203'));
      expect(result, equals({1, 2, 3}));
    });

    test('encodes empty set', () {
      final codec = getSetCodec(getU8Codec());
      expect(hex(codec.encode(<int>{})), equals('00000000'));
    });

    test('uses fixed size', () {
      final codec = getSetCodec(getU8Codec(), size: const FixedArraySize(3));
      expect(hex(codec.encode({1, 2, 3})), equals('010203'));
      expect(codec.decode(b('010203')), equals({1, 2, 3}));
    });

    test('uses remainder size', () {
      final codec = getSetCodec(getU8Codec(), size: const RemainderArraySize());
      expect(hex(codec.encode({1, 2, 3})), equals('010203'));
      expect(codec.decode(b('010203')), equals({1, 2, 3}));
    });

    test('roundtrips', () {
      final codec = getSetCodec(getU8Codec());
      final original = {10, 20, 30};
      expect(codec.decode(codec.encode(original)), equals(original));
    });
  });
}
