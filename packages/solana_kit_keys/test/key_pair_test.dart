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
