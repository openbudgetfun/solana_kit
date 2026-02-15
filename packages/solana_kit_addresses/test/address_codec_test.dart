import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getAddressCodec', () {
    late FixedSizeCodec<Address, Address> codec;

    setUp(() {
      codec = getAddressCodec();
    });

    test('serializes a base58 encoded address into a 32-byte buffer', () {
      final result = codec.encode(
        const Address('4wBqpZM9xaSheZzJSMawUHDgZ7miWfSsxmfVF5jJpYP'),
      );
      expect(
        result,
        equals(
          Uint8List.fromList([
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, //
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          ]),
        ),
      );
    });

    test('deserializes a byte buffer into a base58 encoded address', () {
      final result = codec.decode(
        Uint8List.fromList([
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, //
          17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
          // Extra bytes not part of the address
          33, 34,
        ]),
      );
      expect(
        result.value,
        equals('4wBqpZM9xaSheZzJSMawUKKwhdpChKbZ5eu5ky4Vigw'),
      );
    });

    test(
      'fatals when trying to deserialize a buffer shorter than 32 bytes',
      () {
        final tooShortBuffer = Uint8List(31);
        expect(
          () => codec.decode(tooShortBuffer),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.codecsInvalidByteLength,
            ),
          ),
        );
      },
    );

    test('round-trips addresses correctly', () {
      const original = Address('11111111111111111111111111111111');
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);
      expect(decoded.value, equals(original.value));
    });

    test('round-trips a complex address', () {
      const original = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      final encoded = codec.encode(original);
      expect(encoded.length, equals(32));
      final decoded = codec.decode(encoded);
      expect(decoded.value, equals(original.value));
    });
  });

  group('getAddressEncoder', () {
    test('returns a FixedSizeEncoder with fixedSize 32', () {
      final encoder = getAddressEncoder();
      expect(encoder.fixedSize, equals(32));
    });
  });

  group('getAddressDecoder', () {
    test('returns a FixedSizeDecoder with fixedSize 32', () {
      final decoder = getAddressDecoder();
      expect(decoder.fixedSize, equals(32));
    });
  });
}
