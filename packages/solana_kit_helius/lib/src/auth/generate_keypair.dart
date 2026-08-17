import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_helius/src/types/auth_types.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

/// Generates a new Ed25519 keypair for authentication.
///
/// The secret key uses Solana CLI format: the 32-byte Ed25519 private seed
/// followed by its derived 32-byte public key. Both values are returned as
/// base64-encoded strings.
KeypairResult authGenerateKeypair() {
  final keyPair = generateKeyPair();
  final privateKey = keyPair.privateKey;
  final publicKey = keyPair.publicKey;
  final secretKey = Uint8List(64)
    ..setRange(0, 32, privateKey)
    ..setRange(32, 64, publicKey);
  try {
    return KeypairResult(
      publicKey: base64Encode(publicKey),
      secretKey: base64Encode(secretKey),
    );
  } finally {
    privateKey.fillRange(0, privateKey.length, 0);
    publicKey.fillRange(0, publicKey.length, 0);
    secretKey.fillRange(0, secretKey.length, 0);
    keyPair.dispose();
  }
}
