// ignore_for_file: avoid_print
/// Example 10: KeyPairSigner — sign messages and transactions.
///
/// Shows how to create a [KeyPairSigner], sign a raw bytes message, and inspect
/// the resulting signature maps.  No network access required.
///
/// Run:
///   dart examples/10_keypair_signer.dart
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_signers/solana_kit_signers.dart';

Future<void> main() async {
  // ── 1. Create a signer from a fresh random key pair ───────────────────────
  final signer = generateKeyPairSigner();
  print('Signer address: ${signer.address.value}');

  // ── 2. Sign a raw message ─────────────────────────────────────────────────
  // SignableMessage wraps raw bytes that are to be signed.
  final content = Uint8List.fromList(utf8.encode('Hello, Solana signer!'));
  // createSignableMessage is a convenience helper that also accepts a plain
  // String and sets up an empty signatures map.
  final message = createSignableMessage(content);

  final [sigMap] = await signer.signMessages([message]);
  final sigBytes = sigMap[signer.address];
  print('Signature produced: ${sigBytes != null}');
  print('Signature length  : ${sigBytes?.value.length} bytes');

  // ── 3. Create a signer from an existing private key ───────────────────────
  // Useful when loading a key from a file or environment variable.
  final existingKp = generateKeyPairSigner();
  final fromPrivateKey = createKeyPairSignerFromPrivateKeyBytes(
    existingKp.keyPair.privateKey,
  );
  print('\nReconstructed address matches: '
      '${fromPrivateKey.address == existingKp.address}');

  // ── 4. Deduplicate a signer list ──────────────────────────────────────────
  final s1 = generateKeyPairSigner();
  final duplicates = [s1, s1, generateKeyPairSigner()];
  final unique = deduplicateSigners(duplicates);
  print('\nBefore dedup: ${duplicates.length}, after: ${unique.length}');

  // ── 5. isKeyPairSigner / assertIsKeyPairSigner ────────────────────────────
  print('isKeyPairSigner(signer): ${isKeyPairSigner(signer)}');
  print('isKeyPairSigner("str") : ${isKeyPairSigner("not a signer")}');
}
