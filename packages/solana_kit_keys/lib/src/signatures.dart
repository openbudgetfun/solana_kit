import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_keys/src/private_key.dart';

/// A base58-encoded 64-byte Ed25519 signature.
extension type const Signature(String value) {}

/// A raw 64-byte Ed25519 signature as bytes.
extension type const SignatureBytes(Uint8List value) {}

/// Cached base58 encoder instance.
final VariableSizeEncoder<String> _base58Encoder = getBase58Encoder();

/// Asserts that [putativeSignature] is a valid base58-encoded Ed25519
/// signature.
///
/// A valid signature string must be between 64 and 88 characters long and
/// must decode to exactly 64 bytes.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.keysSignatureStringLengthOutOfRange] if the string length
/// is outside the valid range.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.keysInvalidSignatureByteLength] if the decoded bytes are
/// not exactly 64 bytes.
void assertIsSignature(String putativeSignature) {
  // Fast path: check string length.
  if (putativeSignature.length < 64 || putativeSignature.length > 88) {
    throw SolanaError(SolanaErrorCode.keysSignatureStringLengthOutOfRange, {
      'actualLength': putativeSignature.length,
    });
  }
  // Slow path: decode and check byte length.
  final bytes = _base58Encoder.encode(putativeSignature);
  assertIsSignatureBytes(bytes);
}

/// Returns `true` if [putativeSignature] is a valid base58-encoded Ed25519
/// signature string, `false` otherwise.
bool isSignature(String putativeSignature) {
  try {
    assertIsSignature(putativeSignature);
    return true;
  } on Object {
    return false;
  }
}

/// Asserts that [putativeSignatureBytes] is a valid Ed25519 signature (exactly
/// 64 bytes).
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.keysInvalidSignatureByteLength] if the byte array is not
/// exactly 64 bytes.
void assertIsSignatureBytes(Uint8List putativeSignatureBytes) {
  if (putativeSignatureBytes.length != 64) {
    throw SolanaError(SolanaErrorCode.keysInvalidSignatureByteLength, {
      'actualLength': putativeSignatureBytes.length,
    });
  }
}

/// Returns `true` if [putativeSignatureBytes] is a valid Ed25519 signature
/// (exactly 64 bytes), `false` otherwise.
bool isSignatureBytes(Uint8List putativeSignatureBytes) {
  return putativeSignatureBytes.length == 64;
}

/// Asserts and coerces [value] to a [Signature].
///
/// Validates that [value] is a valid base58-encoded 64-byte Ed25519 signature
/// and returns it as a [Signature].
Signature signature(String value) {
  assertIsSignature(value);
  return Signature(value);
}

/// Asserts and coerces [value] to [SignatureBytes].
///
/// Validates that [value] is exactly 64 bytes and returns it as
/// [SignatureBytes].
SignatureBytes signatureBytes(Uint8List value) {
  assertIsSignatureBytes(value);
  return SignatureBytes(value);
}

/// Signs [data] using the provided 32-byte [privateKeyBytes] and returns the
/// 64-byte Ed25519 signature.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.keysInvalidPrivateKeyByteLength] if [privateKeyBytes] is
/// not exactly 32 bytes.
SignatureBytes signBytes(Uint8List privateKeyBytes, Uint8List data) {
  assertIsPrivateKey(privateKeyBytes);
  final privateKey = ed.newKeyFromSeed(privateKeyBytes);
  final sig = ed.sign(privateKey, data);
  return SignatureBytes(Uint8List.fromList(sig));
}

/// Verifies that [signature] was produced by signing [data] with the private
/// key corresponding to [publicKeyBytes].
///
/// Returns `true` if the signature is valid, `false` otherwise.
/// Returns `false` for malformed lengths or small-order public key and nonce
/// points. Rejecting these weak points prevents signatures forged without a
/// private key from authenticating arbitrary messages.
bool verifySignature(
  Uint8List publicKeyBytes,
  SignatureBytes signature,
  Uint8List data,
) {
  if (publicKeyBytes.length != 32 || signature.value.length != 64) return false;
  if (_isSmallOrderPoint(publicKeyBytes) ||
      _isSmallOrderPoint(Uint8List.sublistView(signature.value, 0, 32))) {
    return false;
  }

  try {
    final publicKey = ed.PublicKey(publicKeyBytes);
    return ed.verify(publicKey, data, Uint8List.fromList(signature.value));
  } on Object {
    return false;
  }
}

/// The five y coordinates of the eight small-order Ed25519 points.
///
/// The sign bit selects the two x coordinates where x is nonzero. These are
/// the same points rejected by libsodium's `ge25519_has_small_order` check.
final Set<BigInt> _smallOrderPointYs = {
  BigInt.zero,
  BigInt.one,
  BigInt.parse(
    '2707385501144840649318225287225658788936804267575313519463743609750303402022',
  ),
  BigInt.parse(
    '55188659117513257062467267217118295137698188065244968500265048394206261417927',
  ),
  _ed25519FieldPrime - BigInt.one,
};

final BigInt _ed25519FieldPrime = (BigInt.one << 255) - BigInt.from(19);

/// Rejects weak points, including non-canonical encodings and either sign bit.
bool _isSmallOrderPoint(Uint8List bytes) {
  var y = BigInt.from(bytes[31] & 0x7f);
  for (var index = 30; index >= 0; index--) {
    y = (y << 8) | BigInt.from(bytes[index]);
  }

  // The underlying verifier reduces field elements modulo p, so aliases of
  // weak points must be rejected along with their canonical encodings.
  return _smallOrderPointYs.contains(y % _ed25519FieldPrime);
}
