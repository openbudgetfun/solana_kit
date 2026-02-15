import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

import 'package:solana_kit_keys/src/private_key.dart';

/// Derives the Ed25519 public key bytes from the given [privateKeyBytes].
///
/// The [privateKeyBytes] must be exactly 32 bytes. Returns the corresponding
/// 32-byte public key.
Uint8List getPublicKeyFromPrivateKey(Uint8List privateKeyBytes) {
  assertIsPrivateKey(privateKeyBytes);
  final privateKey = ed.newKeyFromSeed(privateKeyBytes);
  final publicKey = ed.public(privateKey);
  return Uint8List.fromList(publicKey.bytes);
}
