import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Generates a new Ed25519 keypair for authentication.
///
/// Uses [Random.secure] to generate a 64-byte secret key. The public key is
/// derived as the last 32 bytes of the secret key. Both keys are returned as
/// base64-encoded strings.
///
/// Note: In a full implementation, this would use proper Ed25519 key
/// derivation. The current implementation generates random bytes as a
/// placeholder.
KeypairResult authGenerateKeypair() {
  final random = Random.secure();
  final secretKey = Uint8List(64);
  for (var i = 0; i < 64; i++) {
    secretKey[i] = random.nextInt(256);
  }
  final publicKey = Uint8List.sublistView(secretKey, 32);
  return KeypairResult(
    publicKey: base64Encode(publicKey),
    secretKey: base64Encode(secretKey),
  );
}
