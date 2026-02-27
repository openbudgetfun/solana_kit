// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

void main() {
  const systemProgram = Address('11111111111111111111111111111111');

  final codec = getAddressCodec();
  final encoded = codec.encode(systemProgram);
  final decoded = codec.decode(encoded);

  print('Encoded bytes length: ${encoded.length}');
  print('Decoded address: ${decoded.value}');
}
