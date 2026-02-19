import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/association_keypair.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/src/constants.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/src/crypto.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/src/ecdh_keypair.dart';

/// Result of parsing a HELLO_RSP message.
class HelloRspResult {
  const HelloRspResult({
    required this.sharedSecret,
    this.encryptedSessionProps,
  });

  /// The derived AES-128-GCM shared secret key (16 bytes).
  final Uint8List sharedSecret;

  /// Encrypted session properties, if present in the response.
  ///
  /// This is `null` for legacy wallets that don't send session properties.
  final Uint8List? encryptedSessionProps;
}

/// Parses a HELLO_RSP message from the wallet and derives the shared secret.
///
/// The HELLO_RSP payload contains:
/// - Bytes 0-64: The wallet's ECDH public key in X9.62 uncompressed format
/// - Bytes 65+: Optional encrypted session properties
///
/// The shared secret is derived through:
/// 1. ECDH key agreement between our ephemeral keypair and the wallet's
///    public key, yielding a 256-bit shared secret.
/// 2. HKDF-SHA256 key derivation using the association public key as salt,
///    producing a 128-bit AES key.
HelloRspResult parseHelloRsp(
  Uint8List payload,
  AssociationKeypair associationKeyPair,
  EcdhKeypair ecdhKeyPair,
) {
  if (payload.length < mwaPublicKeyLengthBytes) {
    throw SolanaError(SolanaErrorCode.mwaInvalidHelloResponse, {
      'actualLength': payload.length,
    });
  }

  // Extract the wallet's ECDH public key (first 65 bytes).
  final walletPublicKey = ecPublicKeyFromBytes(
    payload.sublist(0, mwaPublicKeyLengthBytes),
  );

  // Export the association public key bytes for use as HKDF salt.
  final associationPublicKeyBytes = exportPublicKeyBytes(
    associationKeyPair.publicKey,
  );

  // Step 1: ECDH key agreement -> 256-bit shared secret.
  final sharedSecretBytes = ecdhSharedSecret(
    ecdhKeyPair.privateKey,
    walletPublicKey,
  );

  // Step 2: HKDF-SHA256 with association public key as salt -> 128-bit
  // AES key.
  final aesKey = hkdfSha256(
    ikm: sharedSecretBytes,
    salt: associationPublicKeyBytes,
    info: Uint8List(0),
    outputLength: 16, // 128 bits for AES-128-GCM
  );

  // Extract optional encrypted session properties.
  final Uint8List? encryptedSessionProps;
  if (payload.length > mwaPublicKeyLengthBytes) {
    encryptedSessionProps = payload.sublist(mwaPublicKeyLengthBytes);
  } else {
    encryptedSessionProps = null;
  }

  return HelloRspResult(
    sharedSecret: aesKey,
    encryptedSessionProps: encryptedSessionProps,
  );
}
