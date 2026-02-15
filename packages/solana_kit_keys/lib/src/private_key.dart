import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Validates that [bytes] represents a valid Ed25519 private key.
///
/// A private key must be exactly 32 bytes. Throws a [SolanaError] with code
/// [SolanaErrorCode.keysInvalidPrivateKeyByteLength] if the length is wrong.
void assertIsPrivateKey(Uint8List bytes) {
  if (bytes.length != 32) {
    throw SolanaError(SolanaErrorCode.keysInvalidPrivateKeyByteLength, {
      'actualLength': bytes.length,
    });
  }
}
