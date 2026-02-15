import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('literal union codec', () {
    test('encodes string literals by index', () {
      final codec = getLiteralUnionCodec(['small', 'medium', 'large']);
      expect(hex(codec.encode('small')), equals('00'));
      expect(hex(codec.encode('medium')), equals('01'));
      expect(hex(codec.encode('large')), equals('02'));
    });

    test('decodes string literals by index', () {
      final codec = getLiteralUnionCodec(['small', 'medium', 'large']);
      expect(codec.decode(b('00')), equals('small'));
      expect(codec.decode(b('01')), equals('medium'));
      expect(codec.decode(b('02')), equals('large'));
    });

    test('throws on invalid literal value', () {
      final codec = getLiteralUnionCodec(['a', 'b']);
      expect(
        () => codec.encode('c'),
        throwsA(
          predicate(
            (e) => isSolanaError(
              e,
              SolanaErrorCode.codecsInvalidLiteralUnionVariant,
            ),
          ),
        ),
      );
    });

    test('throws on out of range discriminator during decode', () {
      final codec = getLiteralUnionCodec(['a', 'b']);
      expect(
        () => codec.decode(b('05')),
        throwsA(
          predicate(
            (e) => isSolanaError(
              e,
              SolanaErrorCode.codecsLiteralUnionDiscriminatorOutOfRange,
            ),
          ),
        ),
      );
    });

    test('uses custom size codec', () {
      final codec = getLiteralUnionCodec([
        false,
        true,
        'either',
      ], size: getU16Codec());
      expect(hex(codec.encode(false)), equals('0000'));
      expect(hex(codec.encode(true)), equals('0100'));
      expect(hex(codec.encode('either')), equals('0200'));
      expect(codec.decode(b('0000')), equals(false));
      expect(codec.decode(b('0100')), equals(true));
      expect(codec.decode(b('0200')), equals('either'));
    });

    test('roundtrips', () {
      final codec = getLiteralUnionCodec([10, 20, 30]);
      expect(codec.decode(codec.encode(10)), equals(10));
      expect(codec.decode(codec.encode(20)), equals(20));
      expect(codec.decode(codec.encode(30)), equals(30));
    });
  });
}
