import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('tuple codec', () {
    test('encodes a tuple with 2 items', () {
      final codec = getTupleCodec([
        getU8Codec() as Codec<Object?, Object?>,
        getU32Codec() as Codec<Object?, Object?>,
      ]);
      expect(hex(codec.encode([42, 256])), equals('2a00010000'));
    });

    test('decodes a tuple with 2 items', () {
      final codec = getTupleCodec([
        getU8Codec() as Codec<Object?, Object?>,
        getU32Codec() as Codec<Object?, Object?>,
      ]);
      final result = codec.decode(b('2a00010000'));
      expect(result, equals([42, 256]));
    });

    test('throws on wrong number of items', () {
      final codec = getTupleCodec([
        getU8Codec() as Codec<Object?, Object?>,
        getU8Codec() as Codec<Object?, Object?>,
      ]);
      expect(
        () => codec.encode([42]),
        throwsA(
          predicate(
            (e) => isSolanaError(e, SolanaErrorCode.codecsInvalidNumberOfItems),
          ),
        ),
      );
    });

    test('encodes empty tuple', () {
      final codec = getTupleCodec(<Codec<Object?, Object?>>[]);
      expect(hex(codec.encode([])), equals(''));
    });

    test('roundtrips with mixed types', () {
      final codec = getTupleCodec([
        getU8Codec() as Codec<Object?, Object?>,
        getU32Codec() as Codec<Object?, Object?>,
        getU8Codec() as Codec<Object?, Object?>,
      ]);
      final original = <Object?>[1, 1000, 255];
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(original));
    });
  });
}
