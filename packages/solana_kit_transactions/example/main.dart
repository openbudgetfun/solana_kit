// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

void main() {
  final signaturesEncoder = getSignaturesEncoderWithSizePrefix();

  final encoded = signaturesEncoder.encode(const {
    Address('11111111111111111111111111111111'): null,
  });

  print('Encoded signatures length: ${encoded.length}');
}
