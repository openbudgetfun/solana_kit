import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('struct codec', () {
    test('encodes a struct with named fields', () {
      final codec = getStructCodec([
        ('age', getU8Codec() as Codec<Object?, Object?>),
        ('score', getU32Codec() as Codec<Object?, Object?>),
      ]);
      final result = codec.encode({'age': 42, 'score': 1000});
      expect(hex(result), equals('2ae8030000'));
    });

    test('decodes a struct with named fields', () {
      final codec = getStructCodec([
        ('age', getU8Codec() as Codec<Object?, Object?>),
        ('score', getU32Codec() as Codec<Object?, Object?>),
      ]);
      final result = codec.decode(b('2ae8030000'));
      expect(result['age'], equals(42));
      expect(result['score'], equals(1000));
    });

    test('roundtrips a struct', () {
      final codec = getStructCodec([
        ('x', getU8Codec() as Codec<Object?, Object?>),
        ('y', getU8Codec() as Codec<Object?, Object?>),
      ]);
      final original = {'x': 10, 'y': 20};
      final decoded = codec.decode(codec.encode(original));
      expect(decoded['x'], equals(10));
      expect(decoded['y'], equals(20));
    });

    test('encodes empty struct', () {
      final codec = getStructCodec(<(String, Codec<Object?, Object?>)>[]);
      expect(hex(codec.encode({})), equals(''));
    });
  });
}
