import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('generateKeyPair', () {
    test('produces a valid key pair with 32-byte keys', () {
      final keyPair = generateKeyPair();
      expect(keyPair.privateKey.length, equals(32));
      expect(keyPair.publicKey.length, equals(32));
    });
    test('produces key pairs that can sign and verify', () {
      final keyPair = generateKeyPair();
      final data = Uint8List.fromList([1, 2, 3]);
      final sig = signBytes(keyPair.privateKey, data);
      expect(sig.value.length, equals(64));
      expect(verifySignature(keyPair.publicKey, sig, data), isTrue);
    });
    test('produces different key pairs on each call', () {
      final kp1 = generateKeyPair();
      final kp2 = generateKeyPair();
      expect(kp1.privateKey, isNot(equals(kp2.privateKey)));
    });
  });

  group('createKeyPairFromBytes', () {
    test('creates a key pair from a 64-byte array', () {
      final keyPair = createKeyPairFromBytes(mockKeyBytes);
      expect(keyPair.privateKey, equals(mockPrivateKeyBytes));
      expect(keyPair.publicKey, equals(mockPublicKeyBytes));
    });
    test('throws on wrong length', () {
      expect(
        () => createKeyPairFromBytes(Uint8List(31)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysInvalidKeyPairByteLength),
          ),
        ),
      );
    });
    test('throws on 63-byte input', () {
      expect(
        () => createKeyPairFromBytes(Uint8List(63)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysInvalidKeyPairByteLength),
          ),
        ),
      );
    });
    test('throws on 65-byte input', () {
      expect(
        () => createKeyPairFromBytes(Uint8List(65)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysInvalidKeyPairByteLength),
          ),
        ),
      );
    });
    test('throws if public key does not match private key', () {
      expect(
        () => createKeyPairFromBytes(mockInvalidKeyBytes),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysPublicKeyMustMatchPrivateKey),
          ),
        ),
      );
    });
  });

  group('constantTimeEqual', () {
    test('returns true for identical byte arrays', () {
      final a = Uint8List.fromList([1, 2, 3, 4]);
      final b = Uint8List.fromList([1, 2, 3, 4]);
      expect(constantTimeEqual(a, b), isTrue);
    });

    test('returns false for different byte arrays', () {
      final a = Uint8List.fromList([1, 2, 3, 4]);
      final b = Uint8List.fromList([1, 2, 3, 5]);
      expect(constantTimeEqual(a, b), isFalse);
    });

    test('returns false for arrays of different lengths', () {
      final a = Uint8List.fromList([1, 2, 3]);
      final b = Uint8List.fromList([1, 2, 3, 4]);
      expect(constantTimeEqual(a, b), isFalse);
    });

    test('returns true for empty arrays', () {
      expect(constantTimeEqual(Uint8List(0), Uint8List(0)), isTrue);
    });

    test('uses XOR accumulation without early exit', () {
      // Verify that mismatch at the first byte and mismatch at the last byte
      // both return false (they both complete the full loop).
      final base = Uint8List.fromList(List.filled(32, 0));
      final diffFirst = Uint8List.fromList([1, ...List.filled(31, 0)]);
      final diffLast = Uint8List.fromList([...List.filled(31, 0), 1]);
      expect(constantTimeEqual(base, diffFirst), isFalse);
      expect(constantTimeEqual(base, diffLast), isFalse);
    });
  });

  group('KeyPair immutability', () {
    test('mutating returned privateKey does not affect internal state', () {
      final keyPair = generateKeyPair();
      final data = Uint8List.fromList([1, 2, 3]);

      // Sign with the original key.
      final sig = signBytes(keyPair.privateKey, data);

      // Mutate the returned privateKey bytes.
      final leaked = keyPair.privateKey;
      leaked[0] = 0xFF;
      leaked[1] = 0xFE;

      // The key pair should still sign correctly with its internal key.
      final sig2 = signBytes(keyPair.privateKey, data);
      expect(sig2.value, equals(sig.value));
    });

    test('mutating returned publicKey does not affect internal state', () {
      final keyPair = generateKeyPair();
      final original = Uint8List.fromList(keyPair.publicKey);

      // Mutate the returned publicKey bytes.
      final leaked = keyPair.publicKey;
      leaked[0] = 0xFF;

      // The internal public key should be unchanged.
      expect(keyPair.publicKey, equals(original));
    });
  });

  group('createKeyPairFromPrivateKeyBytes', () {
    test('creates a key pair from 32-byte private key', () {
      final keyPair = createKeyPairFromPrivateKeyBytes(mockPrivateKeyBytes);
      expect(keyPair.privateKey, equals(mockPrivateKeyBytes));
      expect(keyPair.publicKey, equals(mockPublicKeyBytes));
    });
    test('derives the correct public key', () {
      final keyPair = createKeyPairFromPrivateKeyBytes(mockPrivateKeyBytes);
      expect(keyPair.publicKey, equals(mockPublicKeyBytes));
    });
    test('throws on wrong length (31 bytes)', () {
      expect(
        () => createKeyPairFromPrivateKeyBytes(Uint8List(31)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysInvalidPrivateKeyByteLength),
          ),
        ),
      );
    });
    test('throws on wrong length (33 bytes)', () {
      expect(
        () => createKeyPairFromPrivateKeyBytes(Uint8List(33)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            equals(SolanaErrorCode.keysInvalidPrivateKeyByteLength),
          ),
        ),
      );
    });
  });
}
