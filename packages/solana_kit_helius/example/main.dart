// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_helius/solana_kit_helius.dart';

void main() {
  final helius = createHelius(const HeliusConfig(apiKey: 'demo-api-key'));
  final keypair = helius.auth.generateKeypair();

  print('Generated Helius public key: ${keypair.publicKey}');
  print('Generated Helius secret key length: ${keypair.secretKey.length}');
}
