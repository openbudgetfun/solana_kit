import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/crypto.dart';

/// An MWA ephemeral ECDH keypair used for key exchange during the handshake.
class EcdhKeypair {
  const EcdhKeypair({required this.publicKey, required this.privateKey});

  /// The ECDH P-256 public key.
  final ECPublicKey publicKey;

  /// The ECDH P-256 private key.
  final ECPrivateKey privateKey;
}

/// Generates a new P-256 ECDH keypair for ephemeral key exchange.
///
/// This keypair is used in the HELLO_REQ/HELLO_RSP handshake to establish
/// a shared secret with the wallet via Elliptic-curve Diffie-Hellman.
EcdhKeypair generateEcdhKeypair() {
  final pair = generateP256KeyPair();
  return EcdhKeypair(publicKey: pair.publicKey, privateKey: pair.privateKey);
}

/// Exports the public key of an ECDH keypair as 65-byte X9.62 uncompressed
/// format.
Uint8List exportEcdhPublicKeyBytes(EcdhKeypair keyPair) {
  return ecPublicKeyToBytes(keyPair.publicKey);
}
