import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('base16 input validation', () {
    // Upstream v8.5.0 pads a trailing lone hex digit into the low nibble, so
    // odd-length inputs with a valid final digit ('ab1', 'abcde') are now
    // accepted; only genuinely invalid characters are rejected.
    for (final value in ['abg', 'ab!', 'abcdz']) {
      test('rejects invalid hex characters in $value', () {
        expect(
          () => getBase16Encoder().encode(value),
          throwsA(
            isA<SolanaError>().having(
              (error) => error.code,
              'code',
              SolanaErrorCode.codecsInvalidStringForBase,
            ),
          ),
        );
      });
    }

    test('encodes odd-length inputs with a padded final digit', () {
      expect(getBase16Encoder().encode('ab1'), [0xab, 0x01]);
      expect(getBase16Encoder().encode('abcde'), [0xab, 0xcd, 0x0e]);
    });

    test('odd input does not overwrite a following field', () {
      final bytes = Uint8List.fromList([99, 99, 99, 42]);
      final written = getBase16Encoder().write('ab1', bytes, 1);
      expect(written, 3);
      expect(bytes, [99, 0xab, 0x01, 42]);
    });

    test(
      'valid hex writes consume their advertised size at nonzero offsets',
      () {
        final codec = getBase16Codec();
        for (final value in ['', 'a', 'Ab', 'aBcD', 'ab1', 'abcde']) {
          final size = codec.getSizeFromValue(value);
          final bytes = Uint8List(size + 2)..fillRange(0, size + 2, 99);
          expect(codec.write(value, bytes, 1), 1 + size);
          expect(bytes.first, 99);
          expect(bytes.last, 99);
          expect(bytes.sublist(1, 1 + size), codec.encode(value));
        }
      },
    );
  });
}
