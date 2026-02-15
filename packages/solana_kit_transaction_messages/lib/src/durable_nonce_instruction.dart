import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The address of the recent blockhashes sysvar.
const Address recentBlockhashesSysvarAddress = Address(
  'SysvarRecentB1ockHashes11111111111111111111',
);

/// The address of the system program.
const Address systemProgramAddress = Address(
  '11111111111111111111111111111111',
);

/// The data bytes for the AdvanceNonceAccount instruction.
final Uint8List _advanceNonceData = Uint8List.fromList([4, 0, 0, 0]);

/// Creates an instruction for the System program to advance a nonce.
///
/// This instruction is a prerequisite for a transaction with a nonce-based
/// lifetime to be landed on the network.
Instruction createAdvanceNonceAccountInstruction(
  Address nonceAccountAddress,
  Address nonceAuthorityAddress,
) => Instruction(
  programAddress: systemProgramAddress,
  accounts: [
    AccountMeta(address: nonceAccountAddress, role: AccountRole.writable),
    const AccountMeta(
      address: recentBlockhashesSysvarAddress,
      role: AccountRole.readonly,
    ),
    AccountMeta(
      address: nonceAuthorityAddress,
      role: AccountRole.readonlySigner,
    ),
  ],
  data: Uint8List.fromList(_advanceNonceData),
);

/// Returns `true` if the instruction conforms to an
/// `AdvanceNonceAccount` instruction.
bool isAdvanceNonceAccountInstruction(Instruction instruction) {
  return instruction.programAddress == systemProgramAddress &&
      instruction.data != null &&
      _isAdvanceNonceAccountInstructionData(instruction.data!) &&
      instruction.accounts != null &&
      instruction.accounts!.length == 3 &&
      instruction.accounts![0].role == AccountRole.writable &&
      instruction.accounts![1].address == recentBlockhashesSysvarAddress &&
      instruction.accounts![1].role == AccountRole.readonly &&
      isSignerRole(instruction.accounts![2].role);
}

bool _isAdvanceNonceAccountInstructionData(Uint8List data) {
  return data.length == 4 &&
      data[0] == 4 &&
      data[1] == 0 &&
      data[2] == 0 &&
      data[3] == 0;
}
