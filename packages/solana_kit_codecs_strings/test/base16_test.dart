import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getBase16Codec', () {
    test('can encode base 16 strings', () {
      final base16 = getBase16Codec();

      expect(base16.encode(''), equals(Uint8List(0)));
      expect(base16.read(Uint8List(0), 0), equals(('', 0)));

      expect(base16.encode('0'), equals(Uint8List.fromList([0])));
      expect(base16.encode('00'), equals(Uint8List.fromList([0])));
      expect(base16.read(Uint8List.fromList([0]), 0), equals(('00', 1)));

      expect(base16.encode('1'), equals(Uint8List.fromList([1])));
      expect(base16.encode('01'), equals(Uint8List.fromList([1])));
      expect(base16.read(Uint8List.fromList([1]), 0), equals(('01', 1)));

      expect(base16.encode('2a'), equals(Uint8List.fromList([42])));
      expect(base16.read(Uint8List.fromList([42]), 0), equals(('2a', 1)));

      expect(base16.encode('0400'), equals(Uint8List.fromList([4, 0])));
      expect(base16.read(Uint8List.fromList([4, 0]), 0), equals(('0400', 2)));

      expect(base16.encode('ffff'), equals(Uint8List.fromList([255, 255])));
      expect(
        base16.read(Uint8List.fromList([255, 255]), 0),
        equals(('ffff', 2)),
      );

      expect(
        () => base16.encode('INVALID_INPUT'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.codecsInvalidStringForBase),
          ),
        ),
      );
    });

    test(
      'encodes odd-length strings by padding the final digit (upstream v8.5.0)',
      () {
        final base16 = getBase16Codec();

        // 'abc' encodes as [0xab, 0x0c]: the trailing lone digit becomes the
        // low nibble of the final byte instead of being dropped.
        expect(base16.encode('abc'), equals(Uint8List.fromList([0xab, 0x0c])));
        expect(base16.getSizeFromValue('abc'), equals(2));
        expect(
          base16.encode('abcde'),
          equals(Uint8List.fromList([0xab, 0xcd, 0x0e])),
        );

        // The single-character case is unchanged.
        expect(base16.encode('f'), equals(Uint8List.fromList([0x0f])));
      },
    );

    test('throws on a single invalid hex character', () {
      final base16 = getBase16Codec();
      expect(
        () => base16.encode('g'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.codecsInvalidStringForBase),
          ),
        ),
      );
    });
  });
}
