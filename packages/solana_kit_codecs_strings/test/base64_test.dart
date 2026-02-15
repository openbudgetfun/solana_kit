import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getBase64Codec', () {
    final base64 = getBase64Codec();
    final base16 = getBase16Codec();

    test('can encode base 64 strings', () {
      expect(base64.encode(''), equals(Uint8List(0)));
      expect(base64.read(Uint8List(0), 0), equals(('', 0)));

      expect(base64.encode('AA'), equals(Uint8List.fromList([0])));
      expect(base64.encode('AA=='), equals(Uint8List.fromList([0])));
      expect(base64.read(Uint8List.fromList([0]), 0), equals(('AA==', 1)));

      expect(base64.encode('AQ=='), equals(Uint8List.fromList([1])));
      expect(base64.read(Uint8List.fromList([1]), 0), equals(('AQ==', 1)));

      expect(base64.encode('Kg'), equals(Uint8List.fromList([42])));
      expect(base64.read(Uint8List.fromList([42]), 0), equals(('Kg==', 1)));

      const sentence = 'TWFueSBoYW5kcyBtYWtlIGxpZ2h0IHdvcmsu';
      final sentenceBytes = Uint8List.fromList([
        77,
        97,
        110,
        121,
        32,
        104,
        97,
        110,
        100,
        115,
        32,
        109,
        97,
        107,
        101,
        32,
        108,
        105,
        103,
        104,
        116,
        32,
        119,
        111,
        114,
        107,
        46,
      ]);
      expect(base64.encode(sentence), equals(sentenceBytes));
      expect(base64.read(sentenceBytes, 0), equals((sentence, 27)));

      expect(
        () => base64.encode('INVALID_INPUT'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.codecsInvalidStringForBase),
          ),
        ),
      );
    });

    test('roundtrips base64 token data via base16', () {
      // 220 base64 chars = 165 decoded bytes = 330 hex chars.
      // Token data must be a single line to avoid string split issues.
      // ignore: lines_longer_than_80_chars
      const base64TokenData =
          'AShNrkm2joOHhfQnRCzfSbrtDUkUcJSS7PJryR4PPjsnyyIWxL0ESVFoE7QWBowtz2B/iTtUGdb2EEyKbLuN5gEAAAAAAAAAAQAAAGCtpnOhgF7t+dM8By+nG51mKI9Dgb0RtO/6xvPX1w52AgAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      // Hex encoding of the decoded base64 bytes above (165 bytes).
      // ignore: lines_longer_than_80_chars
      const base16TokenData =
          '01284dae49b68e838785f427442cdf49baed0d4914709492ecf26bc91e0f3e3b27cb2216c4bd0449516813b416068c2dcf607f893b5419d6f6104c8a6cbb8de601000000000000000100000060ada673a1805eedf9d33c072fa71b9d66288f4381bd11b4effac6f3d7d70e76020000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

      expect(
        base16.decode(base64.encode(base64TokenData)),
        equals(base16TokenData),
      );
      expect(
        base64.decode(base16.encode(base16TokenData)),
        equals(base64TokenData),
      );
    });

    test('tolerates base64 strings with less padding than expected', () {
      // Dart's base64 decoder is tolerant of missing padding (like Node.js).
      expect(base64.encode('A'), equals(Uint8List(0)));
      expect(base64.encode('AA='), equals(Uint8List.fromList([0])));
    });
  });
}
