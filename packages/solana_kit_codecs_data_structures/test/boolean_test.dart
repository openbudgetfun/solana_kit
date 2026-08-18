import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('boolean codec', () {
    test('encodes false as 0x00', () {
      final encoder = getBooleanEncoder();
      expect(hex(encoder.encode(false)), equals('00'));
    });

    test('encodes true as 0x01', () {
      final encoder = getBooleanEncoder();
      expect(hex(encoder.encode(true)), equals('01'));
    });

    test('decodes 0x00 as false', () {
      final decoder = getBooleanDecoder();
      expect(decoder.decode(b('00')), isFalse);
    });

    test('decodes 0x01 as true', () {
      final decoder = getBooleanDecoder();
      expect(decoder.decode(b('01')), isTrue);
    });

    test('rejects non-canonical values', () {
      final decoder = getBooleanDecoder();
      for (final bytes in [b('02'), b('ff')]) {
        expect(
          () => decoder.decode(bytes),
          throwsA(
            predicate<SolanaError>(
              (error) =>
                  error.code == SolanaErrorCode.codecsInvalidBoolean &&
                  error.context['value'] == bytes[0],
            ),
          ),
        );
      }
    });

    test('roundtrips with codec', () {
      final codec = getBooleanCodec();
      expect(codec.decode(codec.encode(true)), isTrue);
      expect(codec.decode(codec.encode(false)), isFalse);
    });

    test('uses custom number codec for size', () {
      final codec = getBooleanCodec(size: getU32Codec());
      expect(hex(codec.encode(false)), equals('00000000'));
      expect(hex(codec.encode(true)), equals('01000000'));
      expect(codec.decode(b('00000000')), isFalse);
      expect(codec.decode(b('01000000')), isTrue);
    });

    test('validates every supported numeric prefix', () {
      final prefixes = <(String, Decoder<num>, String, String, String)>[
        ('u8', getU8Decoder(), '00', '01', '02'),
        ('u16', getU16Decoder(), '0000', '0100', '0200'),
        ('u32', getU32Decoder(), '00000000', '01000000', '02000000'),
        ('i8', getI8Decoder(), '00', '01', 'ff'),
        ('i16', getI16Decoder(), '0000', '0100', 'feff'),
        ('i32', getI32Decoder(), '00000000', '01000000', 'feffffff'),
        ('f32', getF32Decoder(), '00000000', '0000803f', '0000c03f'),
        (
          'f64',
          getF64Decoder(),
          '0000000000000000',
          '000000000000f03f',
          '000000000000f83f',
        ),
        ('shortU16', getShortU16Decoder(), '00', '01', '02'),
      ];

      for (final (name, prefix, falseValue, trueValue, invalidValue)
          in prefixes) {
        final decoder = getBooleanDecoder(size: prefix);
        expect(decoder.decode(b(falseValue)), isFalse, reason: name);
        expect(decoder.decode(b(trueValue)), isTrue, reason: name);
        expect(
          () => decoder.decode(b(invalidValue)),
          throwsA(
            predicate<SolanaError>(
              (error) => error.code == SolanaErrorCode.codecsInvalidBoolean,
            ),
          ),
          reason: name,
        );
      }
    });

    test('rejects a non-canonical nullable prefix', () {
      final decoder = getNullableDecoder(
        getU8Decoder(),
        prefix: getU32Decoder(),
      );

      expect(
        () => decoder.decode(b('02000000')),
        throwsA(
          predicate<SolanaError>(
            (error) => error.code == SolanaErrorCode.codecsInvalidBoolean,
          ),
        ),
      );
    });
  });
}
