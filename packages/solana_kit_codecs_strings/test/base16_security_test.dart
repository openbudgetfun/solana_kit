import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('base16 input validation', () {
    for (final value in ['abg', 'ab!', 'abcdz', 'ab1', 'abcde']) {
      test(
        'rejects incomplete hex input $value instead of dropping its tail',
        () {
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
        },
      );
    }

    test('rejects odd input before overwriting a following field', () {
      final bytes = Uint8List.fromList([99, 99, 99, 42]);
      expect(
        () => getBase16Encoder().write('ab1', bytes, 1),
        throwsA(isA<SolanaError>()),
      );
      expect(bytes, [99, 99, 99, 42]);
    });

    test(
      'valid hex writes consume their advertised size at nonzero offsets',
      () {
        final codec = getBase16Codec();
        for (final value in ['', 'a', 'Ab', 'aBcD']) {
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
