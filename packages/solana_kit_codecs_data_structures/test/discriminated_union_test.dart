import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('discriminated union codec', () {
    test('encodes a discriminated union with u8 prefix', () {
      final codec = getDiscriminatedUnionCodec([
        ('Quit', getUnitCodec() as Codec<Object?, Object?>),
        (
          'Move',
          getStructCodec([
                ('x', getU8Codec() as Codec<Object?, Object?>),
                ('y', getU8Codec() as Codec<Object?, Object?>),
              ])
              as Codec<Object?, Object?>,
        ),
      ]);

      // Quit variant (index 0)
      expect(hex(codec.encode({'__kind': 'Quit'})), equals('00'));

      // Move variant (index 1)
      expect(
        hex(codec.encode({'__kind': 'Move', 'x': 5, 'y': 6})),
        equals('010506'),
      );
    });

    test('decodes a discriminated union with u8 prefix', () {
      final codec = getDiscriminatedUnionCodec([
        ('Quit', getUnitCodec() as Codec<Object?, Object?>),
        (
          'Move',
          getStructCodec([
                ('x', getU8Codec() as Codec<Object?, Object?>),
                ('y', getU8Codec() as Codec<Object?, Object?>),
              ])
              as Codec<Object?, Object?>,
        ),
      ]);

      final quit = codec.decode(b('00'));
      expect(quit['__kind'], equals('Quit'));

      final move = codec.decode(b('010506'));
      expect(move['__kind'], equals('Move'));
      expect(move['x'], equals(5));
      expect(move['y'], equals(6));
    });

    test('throws on invalid discriminator value', () {
      final codec = getDiscriminatedUnionCodec([
        ('Quit', getUnitCodec() as Codec<Object?, Object?>),
      ]);
      expect(
        () => codec.encode({'__kind': 'Unknown'}),
        throwsA(
          predicate(
            (e) => isSolanaError(
              e,
              SolanaErrorCode.codecsInvalidDiscriminatedUnionVariant,
            ),
          ),
        ),
      );
    });

    test('uses custom discriminator property', () {
      final codec = getDiscriminatedUnionCodec([
        ('Quit', getUnitCodec() as Codec<Object?, Object?>),
      ], discriminator: 'type');
      expect(hex(codec.encode({'type': 'Quit'})), equals('00'));
      final decoded = codec.decode(b('00'));
      expect(decoded['type'], equals('Quit'));
    });

    test('roundtrips', () {
      final codec = getDiscriminatedUnionCodec([
        ('A', getUnitCodec() as Codec<Object?, Object?>),
        (
          'B',
          getStructCodec([('val', getU8Codec() as Codec<Object?, Object?>)])
              as Codec<Object?, Object?>,
        ),
      ]);
      final encoded = codec.encode({'__kind': 'B', 'val': 99});
      final decoded = codec.decode(encoded);
      expect(decoded['__kind'], equals('B'));
      expect(decoded['val'], equals(99));
    });
  });
}
