// Private helper — minimal system program CreateAccount instruction.
// This will be replaced when a dedicated solana_kit_system package exists.

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// System program address.
const systemProgramAddress =
    Address('11111111111111111111111111111111');

/// Builds a System Program CreateAccount instruction.
Instruction getSystemCreateAccountInstruction({
  required Address payer,
  required Address newAccount,
  required BigInt lamports,
  required int space,
  required Address programOwner,
  Address systemProgram = systemProgramAddress,
}) {
  // CreateAccount layout: u32 instruction index (0) + u64 lamports +
  // u64 space + 32-byte owner
  final data = Uint8List(4 + 8 + 8 + 32);
  // instruction index 0 (CreateAccount) — already zeroed
  getU64Encoder().write(lamports, data, 4);
  getU64Encoder().write(BigInt.from(space), data, 12);
  getAddressEncoder().write(programOwner, data, 20);

  return Instruction(
    programAddress: systemProgram,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: newAccount, role: AccountRole.writableSigner),
    ],
    data: data,
  );
}
