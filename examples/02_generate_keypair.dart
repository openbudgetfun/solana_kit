// ignore_for_file: avoid_print
/// Example 02: Generate and inspect Ed25519 key pairs.
///
/// Shows [generateKeyPair] and how to read the resulting public and private
/// key bytes.  No network access is required.
///
/// Run:
///   dart examples/02_generate_keypair.dart
library;

import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  // ── 1. Generate a fresh random key pair ───────────────────────────────────
  final keyPair = generateKeyPair();

  // The private key is the 32-byte Ed25519 seed.
  final privateKeyBytes = keyPair.privateKey; // Uint8List(32)
  // The public key is the 32-byte compressed Ed25519 point.
  final publicKeyBytes = keyPair.publicKey; // Uint8List(32)

  print('Private key (${privateKeyBytes.length} bytes): '
      '${_hexDump(privateKeyBytes)}');
  print('Public key  (${publicKeyBytes.length} bytes): '
      '${_hexDump(publicKeyBytes)}');

  // ── 2. Defensive copies ───────────────────────────────────────────────────
  // KeyPair returns defensive copies, so mutating the returned slice does NOT
  // affect the internally stored bytes.
  final copy = keyPair.privateKey;
  copy[0] = 0xFF;
  print('Internal key unchanged: ${keyPair.privateKey[0] != 0xFF}');

  // ── 3. Round-trip via createKeyPairFromPrivateKeyBytes ───────────────────
  // Reconstruct a key pair from just the private-key seed.
  final reconstructed = createKeyPairFromPrivateKeyBytes(keyPair.privateKey);
  print('Public keys match after round-trip: '
      '${constantTimeEqual(keyPair.publicKey, reconstructed.publicKey)}');

  // ── 4. Round-trip via createKeyPairFromBytes (64-byte form) ──────────────
  // Some wallets store keys as a 64-byte array [private(32) || public(32)].
  final combined = Uint8List(64)
    ..setAll(0, keyPair.privateKey)
    ..setAll(32, keyPair.publicKey);

  final fromBytes = createKeyPairFromBytes(combined);
  print('Reconstructed from 64-byte array: '
      '${constantTimeEqual(keyPair.publicKey, fromBytes.publicKey)}');
}

/// Returns a lower-case hex string for a small byte array.
String _hexDump(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
