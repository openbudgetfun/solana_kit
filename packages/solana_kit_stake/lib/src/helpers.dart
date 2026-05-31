import 'package:solana_kit_addresses/solana_kit_addresses.dart'
    hide sysvarClockAddress, sysvarRentAddress, sysvarStakeHistoryAddress;
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_stake/src/generated/solana_stake_interface.dart';
import 'package:solana_kit_system/solana_kit_system.dart' as system;
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

/// Builds a sequential plan that creates and initializes a stake account.
InstructionPlan getCreateStakeAccountInstructionPlan({
  required Address payer,
  required Address stake,
  required BigInt lamports,
  required Authorized authorized,
  Lockup? lockup,
  Address rentSysvar = sysvarRentAddress,
}) {
  final resolvedLockup =
      lockup ??
      Lockup(
        unixTimestamp: BigInt.zero,
        epoch: BigInt.zero,
        custodian: systemProgramAddress,
      );

  return SequentialInstructionPlan(
    divisible: false,
    plans: [
      SingleInstructionPlan(
        instruction: system.getCreateAccountInstruction(
          payer: payer,
          newAccount: stake,
          lamports: lamports,
          space: BigInt.from(stakeAccountSize),
          programOwner: solanaStakeInterfaceProgramAddress,
        ),
      ),
      SingleInstructionPlan(
        instruction: getInitializeInstruction(
          programAddress: solanaStakeInterfaceProgramAddress,
          stake: stake,
          rentSysvar: rentSysvar,
          arg0: authorized,
          arg1: resolvedLockup,
        ),
      ),
    ],
  );
}

/// Builds a delegate-stake plan with the canonical sysvar accounts.
InstructionPlan getDelegateStakeInstructionPlan({
  required Address stake,
  required Address vote,
  required Address stakeAuthority,
  Address clockSysvar = sysvarClockAddress,
  Address stakeHistorySysvar = sysvarStakeHistoryAddress,
  Address unused = stakeConfigAddress,
}) {
  return SingleInstructionPlan(
    instruction: getDelegateStakeInstruction(
      programAddress: solanaStakeInterfaceProgramAddress,
      stake: stake,
      vote: vote,
      clockSysvar: clockSysvar,
      stakeHistory: stakeHistorySysvar,
      unused: unused,
      stakeAuthority: stakeAuthority,
    ),
  );
}
