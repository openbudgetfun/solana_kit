/// Ed25519 key and signature primitives for the Solana Kit Dart SDK.
///
/// Exports key-pair generation, public/private key types, and Solana
/// compatible signature byte wrappers.
///
/// <!-- {=docsKeyPairSection} -->
///
/// ## Generate keys and verify signatures
///
/// Use the key primitives when you need raw Ed25519 key material or signature
/// verification outside the higher-level signer abstractions.
///
/// ```dart
/// import 'dart:typed_data';
///
/// import 'package:solana_kit_keys/solana_kit_keys.dart';
///
/// void main() {
///   final keyPair = generateKeyPair();
///   final message = Uint8List.fromList([1, 2, 3]);
///
///   final signature = signBytes(keyPair.privateKey, message);
///   final verified = verifySignature(keyPair.publicKey, signature, message);
///
///   print(verified);
/// }
/// ```
///
/// This package is the right layer when you need direct access to key bytes,
/// public-key derivation, or low-level signature helpers.
///
/// <!-- {/docsKeyPairSection} -->
library;

export 'src/key_pair.dart';
export 'src/private_key.dart';
export 'src/public_key.dart';
export 'src/signatures.dart';
