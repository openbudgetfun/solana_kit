import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/crypto.dart';

/// An MWA association keypair used for ECDSA signing during the handshake.
class AssociationKeypair {
  const AssociationKeypair({required this.publicKey, required this.privateKey});

  /// The ECDSA P-256 public key.
  final ECPublicKey publicKey;

  /// The ECDSA P-256 private key.
  final ECPrivateKey privateKey;
}

/// Generates a new ECDSA P-256 keypair for MWA association.
///
/// The association keypair is used to:
/// - Sign the ECDH public key in the HELLO_REQ message
/// - Derive the association token (base64url-encoded public key)
/// - Serve as the HKDF salt during shared secret derivation
AssociationKeypair generateAssociationKeypair() {
  final pair = generateP256KeyPair();
  return AssociationKeypair(
    publicKey: pair.publicKey,
    privateKey: pair.privateKey,
  );
}

/// Exports a public key as a 65-byte X9.62 uncompressed format.
///
/// Format: `0x04 || x(32) || y(32)`
Uint8List exportPublicKeyBytes(ECPublicKey publicKey) {
  return ecPublicKeyToBytes(publicKey);
}

/// Returns the association token: the base64url-encoded public key bytes.
///
/// The association token is included in the association URI so the wallet
/// can identify the dApp's session.
String getAssociationToken(ECPublicKey publicKey) {
  final publicKeyBytes = exportPublicKeyBytes(publicKey);
  return base64Url.encode(publicKeyBytes).replaceAll('=', '');
}
