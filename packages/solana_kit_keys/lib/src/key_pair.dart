import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_keys/src/private_key.dart';
import 'package:solana_kit_keys/src/public_key.dart';
import 'package:solana_kit_keys/src/signatures.dart';

/// An Ed25519 key pair consisting of a 32-byte private key and a 32-byte
/// public key.
///
/// Key bytes are stored internally and defensive copies are returned from
/// getters to prevent external mutation of key material.
class KeyPair {
  /// Creates a [KeyPair] from the given [privateKey] and [publicKey] bytes.
  KeyPair({required Uint8List privateKey, required Uint8List publicKey})
    : _privateKey = Uint8List.fromList(privateKey),
      _publicKey = Uint8List.fromList(publicKey);

  // TODO(security): Dart's GC makes deterministic memory wiping impossible.
  // Private key material remains in memory until garbage collected. Consider
  // wrapping in a secure key class if/when Dart adds finalizer-based memory
  // zeroing support.
  final Uint8List _privateKey;
  final Uint8List _publicKey;

  /// The 32-byte Ed25519 private key (seed).
  ///
  /// Returns a defensive copy to prevent external mutation.
  Uint8List get privateKey => Uint8List.fromList(_privateKey);

  /// The 32-byte Ed25519 public key.
  ///
  /// Returns a defensive copy to prevent external mutation.
  Uint8List get publicKey => Uint8List.fromList(_publicKey);
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

  // Also verify the provided public key matches the derived one using
  // constant-time comparison to prevent timing attacks.
  if (!constantTimeEqual(publicKeyBytes, derivedPublicKey)) {
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

/// Compares two byte arrays in constant time to prevent timing attacks.
///
/// Returns `true` if both arrays have the same length and identical contents.
/// The comparison always examines all bytes regardless of where mismatches
/// occur, preventing an attacker from learning partial key information through
/// timing side-channels.
bool constantTimeEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    result |= a[i] ^ b[i];
  }
  return result == 0;
}
