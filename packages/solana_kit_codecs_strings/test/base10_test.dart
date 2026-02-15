import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getBase10Codec', () {
    test('can encode base 10 strings', () {
      final base10 = getBase10Codec();

      expect(base10.encode(''), equals(Uint8List(0)));
      expect(base10.read(Uint8List(0), 0), equals(('', 0)));

      expect(base10.encode('0'), equals(Uint8List.fromList([0])));
      expect(base10.read(Uint8List.fromList([0]), 0), equals(('0', 1)));

      expect(base10.encode('000'), equals(Uint8List.fromList([0, 0, 0])));
      expect(base10.read(Uint8List.fromList([0, 0, 0]), 0), equals(('000', 3)));

      expect(base10.encode('1'), equals(Uint8List.fromList([1])));
      expect(base10.read(Uint8List.fromList([1]), 0), equals(('1', 1)));

      expect(base10.encode('42'), equals(Uint8List.fromList([42])));
      expect(base10.read(Uint8List.fromList([42]), 0), equals(('42', 1)));

      expect(base10.encode('1024'), equals(Uint8List.fromList([4, 0])));
      expect(base10.read(Uint8List.fromList([4, 0]), 0), equals(('1024', 2)));

      expect(base10.encode('65535'), equals(Uint8List.fromList([255, 255])));
      expect(
        base10.read(Uint8List.fromList([255, 255]), 0),
        equals(('65535', 2)),
      );

      expect(
        () => base10.encode('INVALID_INPUT'),
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
