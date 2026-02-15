import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_keys/src/private_key.dart';
import 'package:solana_kit_keys/src/public_key.dart';
import 'package:solana_kit_keys/src/signatures.dart';

/// An Ed25519 key pair consisting of a 32-byte private key and a 32-byte
/// public key.
class KeyPair {
  /// Creates a [KeyPair] from the given [privateKey] and [publicKey] bytes.
  const KeyPair({required this.privateKey, required this.publicKey});

  /// The 32-byte Ed25519 private key (seed).
  final Uint8List privateKey;

  /// The 32-byte Ed25519 public key.
  final Uint8List publicKey;
}

/// Generates a new random Ed25519 key pair.
///
/// Returns a [KeyPair] with a randomly generated 32-byte private key and its
/// corresponding 32-byte public key.
KeyPair generateKeyPair() {
  final keyPair = ed.generateKey();
  final seed = keyPair.privateKey.bytes.sublist(0, 32);
  final publicKeyBytes = keyPair.publicKey.bytes;
  return KeyPair(
    privateKey: Uint8List.fromList(seed),
    publicKey: Uint8List.fromList(publicKeyBytes),
  );
}

/// Creates a [KeyPair] from a 64-byte array where the first 32 bytes
/// represent the private key and the last 32 bytes represent the public key.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.keysInvalidKeyPairByteLength] if [bytes] is not exactly
/// 64 bytes.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.keysPublicKeyMustMatchPrivateKey] if the public key bytes
/// do not match the public key derived from the private key bytes.
KeyPair createKeyPairFromBytes(Uint8List bytes) {
  if (bytes.length != 64) {
    throw SolanaError(SolanaErrorCode.keysInvalidKeyPairByteLength, {
      'byteLength': bytes.length,
    });
  }

  final privateKeyBytes = Uint8List.sublistView(bytes, 0, 32);
  final publicKeyBytes = Uint8List.sublistView(bytes, 32, 64);

  // Verify the public key matches the private key by signing and verifying
  // random data.
  final derivedPublicKey = getPublicKeyFromPrivateKey(privateKeyBytes);
  final testData = Uint8List.fromList([0, 1, 2, 3]);
  final sig = signBytes(privateKeyBytes, testData);
  final isValid = verifySignature(derivedPublicKey, sig, testData);
  if (!isValid) {
    throw SolanaError(SolanaErrorCode.keysPublicKeyMustMatchPrivateKey);
  }

  // Also verify the provided public key matches the derived one.
  var keysMatch = true;
  for (var i = 0; i < 32; i++) {
    if (publicKeyBytes[i] != derivedPublicKey[i]) {
      keysMatch = false;
      break;
    }
  }
  if (!keysMatch) {
    throw SolanaError(SolanaErrorCode.keysPublicKeyMustMatchPrivateKey);
  }

  return KeyPair(
    privateKey: Uint8List.fromList(privateKeyBytes),
    publicKey: Uint8List.fromList(publicKeyBytes),
  );
}

/// Creates a [KeyPair] from a 32-byte private key, deriving the corresponding
/// public key.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.keysInvalidPrivateKeyByteLength] if [bytes] is not
/// exactly 32 bytes.
KeyPair createKeyPairFromPrivateKeyBytes(Uint8List bytes) {
  assertIsPrivateKey(bytes);
  final publicKeyBytes = getPublicKeyFromPrivateKey(bytes);
  return KeyPair(
    privateKey: Uint8List.fromList(bytes),
    publicKey: publicKeyBytes,
  );
}
