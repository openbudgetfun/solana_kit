// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';

void main() {
  final signer = generateKeyPairSigner();

  final instruction = Instruction(
    programAddress: const Address('11111111111111111111111111111111'),
    accounts: [
      AccountMeta(
        address: signer.address,
        role: AccountRole.readonlySigner,
      ),
    ],
    data: Uint8List(0),
  );

  final uniqueSigners = deduplicateSigners([signer, signer]);
  final signedInstruction = addSignersToInstruction(uniqueSigners, instruction);
  final extractedSigners = getSignersFromInstruction(signedInstruction);

  print('Unique signers: ${uniqueSigners.length}');
  print('Extracted signers from instruction: ${extractedSigners.length}');
}
