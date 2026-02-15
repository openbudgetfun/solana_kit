import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:test/test.dart';

void main() {
  group('getUtf8Codec', () {
    test('can encode UTF-8 strings', () {
      final utf8 = getUtf8Codec();

      expect(utf8.encode(''), equals(Uint8List(0)));
      expect(utf8.decode(Uint8List(0)), equals(''));

      expect(utf8.encode('0'), equals(Uint8List.fromList([48])));
      expect(utf8.decode(Uint8List.fromList([48])), equals('0'));

      expect(utf8.encode('ABC'), equals(Uint8List.fromList([65, 66, 67])));
      expect(utf8.decode(Uint8List.fromList([65, 66, 67])), equals('ABC'));

      final encodedHelloWorld = Uint8List.fromList([
        72,
        101,
        108,
        108,
        111,
        32,
        87,
        111,
        114,
        108,
        100,
        33,
      ]);
      expect(utf8.encode('Hello World!'), equals(encodedHelloWorld));
      expect(utf8.decode(encodedHelloWorld), equals('Hello World!'));

      expect(
        utf8.encode('\u8a9e'),
        equals(Uint8List.fromList([232, 170, 158])),
      );
      expect(
        utf8.decode(Uint8List.fromList([232, 170, 158])),
        equals('\u8a9e'),
      );
    });
  });
}
