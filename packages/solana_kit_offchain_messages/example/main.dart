// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

void main() {
  const signerA = Address('11111111111111111111111111111111');
  const signerB = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  final message = OffchainMessageV0(
    applicationDomain: offchainMessageApplicationDomain(
      '11111111111111111111111111111111',
    ),
    content: const OffchainMessageContent(
      format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
      text: 'Hello from Solana Kit',
    ),
    requiredSignatories: const [
      OffchainMessageSignatory(address: signerA),
      OffchainMessageSignatory(address: signerB),
    ],
  );

  final envelope = compileOffchainMessageEnvelope(message);

  print('Envelope byte length: ${envelope.content.length}');
  print('Required signatures: ${envelope.signatures.length}');
}
