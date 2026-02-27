// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// The address of the TokenVault program.
const tokenVaultProgramAddress = Address(
  'VauLT1111111111111111111111111111111111111111',
);

/// Known accounts for the TokenVault program.
enum TokenVaultAccount {
  vault,
  depositRecord,
}

/// Known instructions for the TokenVault program.
enum TokenVaultInstruction {
  initializeVault,
  deposit,
  withdraw,
  updateVaultStatus,
}
