import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('nullable codec', () {
    test('encodes null as 0x00 with u8 prefix', () {
      final codec = getNullableCodec(getU32Codec());
      expect(hex(codec.encode(null)), equals('00'));
    });

    test('encodes value with 0x01 prefix', () {
      final codec = getNullableCodec(getU32Codec());
      expect(hex(codec.encode(42)), equals('012a000000'));
    });

    test('decodes null from 0x00 prefix', () {
      final codec = getNullableCodec(getU32Codec());
      expect(codec.decode(b('00')), isNull);
    });

    test('decodes value from 0x01 prefix', () {
      final codec = getNullableCodec(getU32Codec());
      expect(codec.decode(b('012a000000')), equals(42));
    });

    test('roundtrips null', () {
      final codec = getNullableCodec(getU8Codec());
      expect(codec.decode(codec.encode(null)), isNull);
    });

    test('roundtrips value', () {
      final codec = getNullableCodec(getU8Codec());
      expect(codec.decode(codec.encode(42)), equals(42));
    });

    test('uses zeroes none value with prefix', () {
      final codec = getNullableCodec(
        getU32Codec(),
        noneValue: const ZeroesNoneValue(),
      );
      // null -> prefix(0) + zeroes(4 bytes)
      expect(hex(codec.encode(null)), equals('0000000000'));
      // value -> prefix(1) + value
      expect(hex(codec.encode(42)), equals('012a000000'));
      expect(codec.decode(b('0000000000')), isNull);
      expect(codec.decode(b('012a000000')), equals(42));
    });

    test('uses zeroes none value without prefix', () {
      final codec = getNullableCodec(
        getU32Codec(),
        noneValue: const ZeroesNoneValue(),
        hasPrefix: false,
      );
      expect(hex(codec.encode(null)), equals('00000000'));
      expect(hex(codec.encode(42)), equals('2a000000'));
      expect(codec.decode(b('00000000')), isNull);
      expect(codec.decode(b('2a000000')), equals(42));
    });

    test('no prefix identifies null by absence of bytes', () {
      final codec = getNullableCodec(getU8Codec(), hasPrefix: false);
      expect(hex(codec.encode(null)), equals(''));
      expect(hex(codec.encode(42)), equals('2a'));
      expect(codec.decode(b('')), isNull);
      expect(codec.decode(b('2a')), equals(42));
    });
  });
}
