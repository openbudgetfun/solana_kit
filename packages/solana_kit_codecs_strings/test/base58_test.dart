import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getBase58Codec', () {
    test('can encode base 58 strings', () {
      final base58 = getBase58Codec();

      expect(base58.encode(''), equals(Uint8List(0)));
      expect(base58.read(Uint8List(0), 0), equals(('', 0)));

      expect(base58.encode('1'), equals(Uint8List.fromList([0])));
      expect(base58.read(Uint8List.fromList([0]), 0), equals(('1', 1)));

      expect(base58.encode('2'), equals(Uint8List.fromList([1])));
      expect(base58.read(Uint8List.fromList([1]), 0), equals(('2', 1)));

      expect(base58.encode('11'), equals(Uint8List.fromList([0, 0])));
      expect(base58.read(Uint8List.fromList([0, 0]), 0), equals(('11', 2)));

      final zeroes32 = Uint8List(32);
      expect(base58.encode('1' * 32), equals(zeroes32));
      expect(base58.read(zeroes32, 0), equals(('1' * 32, 32)));

      expect(base58.encode('j'), equals(Uint8List.fromList([42])));
      expect(base58.read(Uint8List.fromList([42]), 0), equals(('j', 1)));

      expect(base58.encode('Jf'), equals(Uint8List.fromList([4, 0])));
      expect(base58.read(Uint8List.fromList([4, 0]), 0), equals(('Jf', 2)));

      expect(base58.encode('LUv'), equals(Uint8List.fromList([255, 255])));
      expect(
        base58.read(Uint8List.fromList([255, 255]), 0),
        equals(('LUv', 2)),
      );

      const pubkey = 'LorisCg1FTs89a32VSrFskYDgiRbNQzct1WxyZb7nuA';
      final pubkeyBytes = Uint8List.fromList([
        5,
        19,
        4,
        94,
        5,
        47,
        73,
        25,
        182,
        8,
        150,
        61,
        231,
        60,
        102,
        110,
        6,
        114,
        224,
        110,
        40,
        20,
        10,
        184,
        65,
        191,
        241,
        204,
        131,
        161,
        120,
        181,
      ]);
      expect(base58.encode(pubkey), equals(pubkeyBytes));
      expect(base58.read(pubkeyBytes, 0), equals((pubkey, 32)));

      expect(
        () => base58.encode('INVALID_INPUT'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.codecsInvalidStringForBase),
          ),
        ),
      );
    });

    test('computes the buffer size of base 58 strings', () {
      final base58 = getBase58Codec();

      // Empty.
      expect(base58.getSizeFromValue(''), equals(0));

      // Simple strings.
      expect(base58.getSizeFromValue('2'), equals(1));
      expect(base58.getSizeFromValue('Jf'), equals(2));

      // Leading zeroes.
      expect(base58.getSizeFromValue('1'), equals(1));
      expect(base58.getSizeFromValue('11'), equals(2));
      expect(base58.getSizeFromValue('11111'), equals(5));
      expect(base58.getSizeFromValue('1' * 32), equals(32));
      expect(base58.getSizeFromValue('11111LUv'), equals(5 + 2));

      // Boundaries.
      expect(base58.getSizeFromValue('5Q'), equals(1));
      expect(base58.getSizeFromValue('5R'), equals(2));
      expect(base58.getSizeFromValue('LUv'), equals(2));
      expect(base58.getSizeFromValue('LUw'), equals(3));
      expect(base58.getSizeFromValue('2UzHL'), equals(3));
      expect(base58.getSizeFromValue('2UzHM'), equals(4));
      expect(
        base58.getSizeFromValue('4uQeVj5tqViQh7yWWGStvkEG1Zmhx6uasJtWCJziofL'),
        equals(31),
      );
      expect(
        base58.getSizeFromValue('4uQeVj5tqViQh7yWWGStvkEG1Zmhx6uasJtWCJziofM'),
        equals(32),
      );
      expect(
        base58.getSizeFromValue('JEKNVnkbo3jma5nREBBJCDoXFVeKkD56V3xKrvRmWxFG'),
        equals(32),
      );
      expect(
        base58.getSizeFromValue('JEKNVnkbo3jma5nREBBJCDoXFVeKkD56V3xKrvRmWxFH'),
        equals(33),
      );

      // Addresses.
      expect(
        base58.getSizeFromValue('LorisCg1FTs89a32VSrFskYDgiRbNQzct1WxyZb7nuA'),
        equals(32),
      );
    });
  });
}
