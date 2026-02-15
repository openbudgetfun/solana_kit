import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('assertIsSignature', () {
    test('does not throw for valid base58-encoded signatures', () {
      // 64 bytes of zeroes encoded as base58
      expect(() => assertIsSignature('1' * 64), returnsNormally);

      // Real-world example signatures
      expect(
        () => assertIsSignature(
          '5HkW5GttYoahVHaujuxEyfyq7RwvoKpc94ko5Fq9GuYdyhejg9cHcqm1MjEvH'
          'sjaADRe6hVBqB2E4RQgGgxeA2su',
        ),
        returnsNormally,
      );
      expect(
        () => assertIsSignature(
          '2VZm7DkqSKaHxsGiAuVuSkvEbGWf7JrfRdPTw42WKuJC8qw7yQbGL5AE7UxH'
          'H3tprgmT9EVbambnK9h3PLpvMvES',
        ),
        returnsNormally,
      );
    });

    test('throws for string length < 64', () {
      expect(
        () => assertIsSignature('t' * 63),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysSignatureStringLengthOutOfRange),
          ),
        ),
      );
    });

    test('throws for string length > 88', () {
      expect(
        () => assertIsSignature('t' * 89),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysSignatureStringLengthOutOfRange),
          ),
        ),
      );
    });

    test('throws for decoded byte length != 64', () {
      // A valid base58 string that decodes to 63 bytes
      expect(
        () => assertIsSignature(
          '3bwsNoq6EP89sShUAKBeB26aCC3KLGNajRm5wqwr6zRPP3gErZH7erSg33'
          '32SVY7Ru6cME43qT35Z7JKpZqCoP',
        ),
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

  group('isSignature', () {
    test('returns true for valid signatures', () {
      expect(isSignature('1' * 64), isTrue);
    });

    test('returns false for invalid signatures', () {
      expect(isSignature('too-short'), isFalse);
      expect(isSignature('t' * 63), isFalse);
      expect(isSignature('t' * 89), isFalse);
    });
  });

  group('assertIsSignatureBytes', () {
    test('does not throw for 64-byte arrays', () {
      expect(() => assertIsSignatureBytes(Uint8List(64)), returnsNormally);
      expect(() => assertIsSignatureBytes(mockDataSignature), returnsNormally);
    });

    test('throws for empty byte array', () {
      expect(
        () => assertIsSignatureBytes(Uint8List(0)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysInvalidSignatureByteLength),
          ),
        ),
      );
    });

    test('throws for 63-byte array', () {
      expect(
        () => assertIsSignatureBytes(Uint8List(63)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysInvalidSignatureByteLength),
          ),
        ),
      );
    });

    test('throws for 65-byte array', () {
      expect(
        () => assertIsSignatureBytes(Uint8List(65)),
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

  group('isSignatureBytes', () {
    test('returns true for 64-byte arrays', () {
      expect(isSignatureBytes(Uint8List(64)), isTrue);
    });

    test('returns false for non-64-byte arrays', () {
      expect(isSignatureBytes(Uint8List(0)), isFalse);
      expect(isSignatureBytes(Uint8List(63)), isFalse);
      expect(isSignatureBytes(Uint8List(65)), isFalse);
    });
  });

  group('signBytes', () {
    test('produces the expected 64-byte signature', () {
      final sig = signBytes(mockPrivateKeyBytes, mockData);
      expect(sig.value.length, equals(64));
      expect(sig.value, equals(mockDataSignature));
    });

    test('produces 64-byte signatures for arbitrary data', () {
      final keyPair = generateKeyPair();
      final data = Uint8List.fromList([4, 5, 6, 7, 8]);
      final sig = signBytes(keyPair.privateKey, data);
      expect(sig.value.length, equals(64));
    });
  });

  group('verifySignature', () {
    test('returns true for a valid signature', () {
      final result = verifySignature(
        mockPublicKeyBytes,
        SignatureBytes(mockDataSignature),
        mockData,
      );
      expect(result, isTrue);
    });

    test('returns false for a bad signature', () {
      final badSignature = SignatureBytes(
        Uint8List.fromList(List<int>.filled(64, 1)),
      );
      final result = verifySignature(
        mockPublicKeyBytes,
        badSignature,
        mockData,
      );
      expect(result, isFalse);
    });

    test('returns false for wrong data', () {
      final result = verifySignature(
        mockPublicKeyBytes,
        SignatureBytes(mockDataSignature),
        Uint8List.fromList([9, 8, 7]),
      );
      expect(result, isFalse);
    });

    test('returns false for wrong public key', () {
      final wrongKey = Uint8List.fromList(List<int>.filled(32, 0));
      final result = verifySignature(
        wrongKey,
        SignatureBytes(mockDataSignature),
        mockData,
      );
      expect(result, isFalse);
    });
  });
}
