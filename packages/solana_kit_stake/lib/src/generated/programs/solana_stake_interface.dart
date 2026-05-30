// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// The address of the SolanaStakeInterface program.
const solanaStakeInterfaceProgramAddress = Address(
  'Stake11111111111111111111111111111111111111',
);

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
  redelegate,
  moveStake,
  moveLamports,
}
