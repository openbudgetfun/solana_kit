import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:test/test.dart';

void main() {
  group('signature coercion', () {
    test('can coerce a valid string to Signature', () {
      const raw =
          '3bwsNoq6EP89sShUAKBeB26aCC3KLGNajRm5wqwr6zRPP3gErZH7erSg3332'
          'SVY7Ru6cME43qT35Z7JKpZqCoPaL';
      final coerced = signature(raw);
      expect(coerced.value, equals(raw));
    });

    test('throws on string length 63', () {
      expect(
        () => signature('t' * 63),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysSignatureStringLengthOutOfRange),
          ),
        ),
      );
    });

    test('throws on string length 89', () {
      expect(
        () => signature('t' * 89),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysSignatureStringLengthOutOfRange),
          ),
        ),
      );
    });
  });

  group('signatureBytes coercion', () {
    test('can coerce a valid Uint8List to SignatureBytes', () {
      final raw = Uint8List(64);
      final coerced = signatureBytes(raw);
      expect(coerced.value, equals(raw));
    });

    test('throws on byte length 63', () {
      expect(
        () => signatureBytes(Uint8List(63)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysInvalidSignatureByteLength),
          ),
        ),
      );
    });

    test('throws on byte length 65', () {
      expect(
        () => signatureBytes(Uint8List(65)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysInvalidSignatureByteLength),
          ),
        ),
      );
    });
  });
}
