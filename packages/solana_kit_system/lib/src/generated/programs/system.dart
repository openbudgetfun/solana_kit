// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'package:solana_kit_addresses/solana_kit_addresses.dart';


/// The address of the System program.
const systemProgramAddress = Address('11111111111111111111111111111111');

/// Known accounts for the System program.
enum SystemAccount {
  nonce,
}

/// Known instructions for the System program.
enum SystemInstruction {
  createAccount,
  assign,
  transferSol,
  createAccountWithSeed,
  advanceNonceAccount,
  withdrawNonceAccount,
  initializeNonceAccount,
  authorizeNonceAccount,
  allocate,
  allocateWithSeed,
  assignWithSeed,
  transferSolWithSeed,
  upgradeNonceAccount,
}
