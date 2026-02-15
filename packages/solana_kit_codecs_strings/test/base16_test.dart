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
  });
}
