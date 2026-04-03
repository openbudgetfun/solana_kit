// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'package:solana_kit_addresses/solana_kit_addresses.dart';


/// The address of the Token program.
const tokenProgramAddress = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

/// Known accounts for the Token program.
enum TokenAccount {
  mint,
  token,
  multisig,
}

/// Known instructions for the Token program.
enum TokenInstruction {
  initializeMint,
  initializeAccount,
  initializeMultisig,
  transfer,
  approve,
  revoke,
  setAuthority,
  mintTo,
  burn,
  closeAccount,
  freezeAccount,
  thawAccount,
  transferChecked,
  approveChecked,
  mintToChecked,
  burnChecked,
  initializeAccount2,
  syncNative,
  initializeAccount3,
  initializeMultisig2,
  initializeMint2,
  getAccountDataSize,
  initializeImmutableOwner,
  amountToUiAmount,
  uiAmountToAmount,
  withdrawExcessLamports,
  unwrapLamports,
  batch,
}
