import 'package:solana_kit_addresses/solana_kit_addresses.dart';

// Auto-generated. Do not edit.
// ignore_for_file: type=lint

/// The address of the SolanaStakeInterface program.
const solanaStakeInterfaceProgramAddress = stakeProgramAddress;

/// Known accounts for the SolanaStakeInterface program.
enum SolanaStakeInterfaceAccount {
  stakeStateAccount,
}

/// Known instructions for the SolanaStakeInterface program.
enum SolanaStakeInterfaceInstruction {
  initialize,
  authorize,
  delegateStake,
  split,
  withdraw,
  deactivate,
  setLockup,
  merge,
  authorizeWithSeed,
  initializeChecked,
  authorizeChecked,
  authorizeCheckedWithSeed,
  setLockupChecked,
  getMinimumDelegation,
  deactivateDelinquent,
  moveStake,
  moveLamports,
}
