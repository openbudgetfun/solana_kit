// ignore_for_file: avoid_dynamic_calls, cascade_invocations
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('createDependentStructDecoder', () {
    test('decodes a struct with only static fields', () {
      final decoder = createDependentStructDecoder()
          .field('a', getU8Decoder())
          .field(
            'b',
            getU16Decoder(),
          )
          .build();
      expect(decoder.decode(b('010200')), equals({'a': 1, 'b': 2}));
    });

    test('decodes a struct with a dependent length field', () {
      final decoder = createDependentStructDecoder()
          .field('count', getU8Decoder())
          .field(
            'items',
            (fields) => getArrayDecoder(
              getU32Decoder(),
              size: FixedArraySize(fields['count']! as int),
            ),
          )
          .build();
      // count=2, items=[1,2] as little-endian u32s.
      expect(
        decoder.decode(b('02010000000200000000'.substring(0, 18))),
        equals({
          'count': 2,
          'items': [1, 2],
        }),
      );
    });

    test('passes only the fields decoded so far to a factory', () {
      final seenByFactory = <Map<String, Object?>>[];
      final decoder = createDependentStructDecoder()
          .field('first', getU8Decoder())
          .field('second', getU8Decoder())
          .field(
            'third',
            (fields) {
              seenByFactory.add({...fields});
              return getU8Decoder();
            },
          )
          .build();
      decoder.decode(b('010203'));
      expect(
        seenByFactory,
        equals([
          {'first': 1, 'second': 2},
        ]),
      );
    });

    test('lets a factory pick the v0 decoder based on a discriminator', () {
      final versioned = createDependentStructDecoder()
          .field('version', getU8Decoder())
          .field(
            'payload',
            (fields) => (fields['version']! as int) == 0
                ? getU16Decoder()
                : getU32Decoder(),
          )
          .build();
      expect(
        versioned.decode(b('000100')),
        equals({'payload': 1, 'version': 0}),
      );
    });

    test('lets a factory pick the v1 decoder based on a discriminator', () {
      final versioned = createDependentStructDecoder()
          .field('version', getU8Decoder())
          .field(
            'payload',
            (fields) => (fields['version']! as int) == 0
                ? getU16Decoder()
                : getU32Decoder(),
          )
          .build();
      expect(
        versioned.decode(b('0101000000')),
        equals({'payload': 1, 'version': 1}),
      );
    });

    test(
      'decodes from a non-zero offset and returns the new offset from read',
      () {
        final decoder = createDependentStructDecoder()
            .field('n', getU8Decoder())
            .field(
              'xs',
              (fields) => getArrayDecoder(
                getU8Decoder(),
                size: FixedArraySize(fields['n']! as int),
              ),
            )
            .build();
        final (value, offset) = decoder.read(b('ff03010203'), 1);
        expect(
          value,
          equals({
            'n': 3,
            'xs': [1, 2, 3],
          }),
        );
        expect(offset, equals(5));
      },
    );

    test('returns an empty record when no fields are added', () {
      final decoder = createDependentStructDecoder().build();
      expect(decoder.decode(b('')), equals(<String, Object?>{}));
    });

    test('preserves declaration order in the decoded object keys', () {
      final decoder = createDependentStructDecoder()
          .field('z', getU8Decoder())
          .field('a', getU8Decoder())
          .field('m', getU8Decoder())
          .build();
      expect(
        decoder.decode(b('010203')).keys.toList(),
        equals(['z', 'a', 'm']),
      );
    });

    test(
      'produces a fixed size decoder of size zero when no fields are added',
      () {
        final decoder = createDependentStructDecoder().build();
        expect(decoder, isA<FixedSizeDecoder<Map<String, Object?>>>());
        expect(
          (decoder as FixedSizeDecoder<Map<String, Object?>>).fixedSize,
          0,
        );
      },
    );

    test(
      'produces a fixed size decoder summing the field sizes when every field is fixed',
      () {
        final decoder = createDependentStructDecoder()
            .field('a', getU8Decoder())
            .field('b', getU16Decoder())
            .field('c', getU32Decoder())
            .build();
        expect(decoder, isA<FixedSizeDecoder<Map<String, Object?>>>());
        expect(
          (decoder as FixedSizeDecoder<Map<String, Object?>>).fixedSize,
          1 + 2 + 4,
        );
      },
    );

    test(
      'drops to a variable size decoder once a variable size field is added',
      () {
        // A prefixed (default u32) array is variable-size.
        final decoder = createDependentStructDecoder()
            .field('a', getU8Decoder())
            .field('items', getArrayDecoder(getU8Decoder()))
            .field('b', getU8Decoder())
            .build();
        expect(decoder, isA<VariableSizeDecoder<Map<String, Object?>>>());
      },
    );

    test('drops to a variable size decoder once a factory field is added', () {
      final decoder = createDependentStructDecoder()
          .field('count', getU8Decoder())
          .field(
            'items',
            (fields) => getArrayDecoder(
              getU8Decoder(),
              size: FixedArraySize(fields['count']! as int),
            ),
          )
          .build();
      expect(decoder, isA<VariableSizeDecoder<Map<String, Object?>>>());
    });

    test('does not mutate the builder when adding a field', () {
      final builderA = createDependentStructDecoder().field(
        'a',
        getU8Decoder(),
      );
      final builderAB = builderA.field('b', getU8Decoder());
      final decoderA = builderA.build();
      final decoderAB = builderAB.build();
      expect(decoderA.decode(b('01')).keys.toList(), equals(['a']));
      expect(decoderAB.decode(b('0102')).keys.toList(), equals(['a', 'b']));
    });

    test('builds independent decoders from independent build calls', () {
      final builder = createDependentStructDecoder().field('a', getU8Decoder());
      final firstDecoder = builder.build();
      final secondDecoder = builder.build();
      expect(identical(firstDecoder, secondDecoder), isFalse);
      expect(firstDecoder.decode(b('07')), equals({'a': 7}));
      expect(secondDecoder.decode(b('09')), equals({'a': 9}));
    });
  });
}
