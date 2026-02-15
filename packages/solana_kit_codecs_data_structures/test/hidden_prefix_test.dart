import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('hidden prefix codec', () {
    test('encodes with hidden prefix constants', () {
      final codec = getHiddenPrefixCodec(getU8Codec() as Codec<num, int>, [
        getConstantCodec(b('010203')),
        getConstantCodec(b('040506')),
      ]);
      expect(hex(codec.encode(42)), equals('0102030405062a'));
    });

    test('decodes skipping hidden prefix constants', () {
      final codec = getHiddenPrefixCodec(getU8Codec() as Codec<num, int>, [
        getConstantCodec(b('010203')),
        getConstantCodec(b('040506')),
      ]);
      expect(codec.decode(b('0102030405062a')), equals(42));
    });

    test('roundtrips', () {
      final codec = getHiddenPrefixCodec(getU8Codec() as Codec<num, int>, [
        getConstantCodec(b('ff')),
      ]);
      expect(codec.decode(codec.encode(99)), equals(99));
    });
  });
}
