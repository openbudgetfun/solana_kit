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
  try {
    return Uint8List.fromList(ed.public(privateKey).bytes);
  } finally {
    // Zero the 64-byte expanded key so deriving a public key leaves no heap
    // copy of the seed-derived secret beyond the caller's own bytes.
    final expanded = privateKey.bytes;
    for (var i = 0; i < expanded.length; i++) {
      expanded[i] = 0;
    }
  }
}
