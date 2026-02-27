// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

void main() {
  final keyPair = generateKeyPair();
  final message = Uint8List.fromList([1, 2, 3, 4]);

  final signature = signBytes(keyPair.privateKey, message);
  final verified = verifySignature(keyPair.publicKey, signature, message);

  final address = getAddressFromPublicKey(keyPair.publicKey);

  print('Signer address: ${address.value}');
  print('Signature verified: $verified');
}
