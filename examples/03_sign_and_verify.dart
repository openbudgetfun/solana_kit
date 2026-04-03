// ignore_for_file: avoid_print
/// Example 03: Sign bytes and verify Ed25519 signatures.
///
/// Demonstrates [signBytes], [verifySignature], [assertIsSignature], and the
/// [Signature] / [SignatureBytes] extension types.
///
/// Run:
///   dart examples/03_sign_and_verify.dart
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  // ── 1. Generate a fresh key pair ─────────────────────────────────────────
  final keyPair = generateKeyPair();

  // ── 2. Sign a message ─────────────────────────────────────────────────────
  final message = Uint8List.fromList(utf8.encode('Hello, Solana!'));
  final signatureBytes = signBytes(keyPair.privateKey, message);

  print('Signature bytes (${signatureBytes.value.length} bytes): '
      '${_hexDump(signatureBytes.value).substring(0, 16)}…');

  // ── 3. Verify the signature ───────────────────────────────────────────────
  final publicKey = getPublicKeyFromPrivateKey(keyPair.privateKey);
  final valid = verifySignature(publicKey, signatureBytes, message);
  print('Signature is valid: $valid');

  // ── 4. Detect a tampered message ──────────────────────────────────────────
  final tampered = Uint8List.fromList(utf8.encode('Hello, Solana?'));
  final invalid = verifySignature(publicKey, signatureBytes, tampered);
  print('Tampered message signature is valid (should be false): $invalid');

  // ── 5. Base58 Signature extension type ────────────────────────────────────
  // Convert the raw bytes to a base58-encoded [Signature] string using the
  // base58 decoder (encoder.encode treats the string as base58 and gives bytes;
  // decoder.decode gives back the string from bytes).
  final base58Decoder = getBase58Decoder();
  final base58Str = base58Decoder.decode(signatureBytes.value);
  final sig = signature(base58Str);
  print('Base58 signature: ${sig.value.substring(0, 20)}…');

  // Validate that a string looks like a valid base58 signature.
  assertIsSignature(sig.value);
  print('assertIsSignature passed');

  // isSignature returns false without throwing.
  print('isSignature("not-a-sig"): ${isSignature("not-a-sig")}');
}

/// Returns a lower-case hex string for a byte array.
String _hexDump(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
