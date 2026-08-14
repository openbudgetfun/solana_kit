// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';

/// The address of the Staking program.
const stakingProgramAddress = Address(
  'StaKe111111111111111111111111111111111111111',
);

/// Known accounts for the Staking program.
enum StakingAccount {
  stakePool,
  stakeAccount,
}

/// Known instructions for the Staking program.
enum StakingInstruction {
  initializePool,
  stake,
  unstake,
  claimRewards,
}

/// Identifies the type of a Staking instruction.
StakingInstruction identifyStakingInstruction(
  Uint8List data,
) {
  if (containsBytes(data, getU8Encoder().encode(0), 0)) {
    return StakingInstruction.initializePool;
  }
  if (containsBytes(data, getU8Encoder().encode(1), 0)) {
    return StakingInstruction.stake;
  }
  if (containsBytes(data, getU8Encoder().encode(2), 0)) {
    return StakingInstruction.unstake;
  }
  if (containsBytes(data, getU8Encoder().encode(3), 0)) {
    return StakingInstruction.claimRewards;
  }

  throw SolanaError(
    SolanaErrorCode.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': 'staking',
    },
  );
}

/// A parsed instruction from the Staking program.
sealed class ParsedStakingInstruction {
  const ParsedStakingInstruction(this.instructionType);

  final StakingInstruction instructionType;
}

/// A parsed InitializePool instruction.
final class ParsedInitializePool extends ParsedStakingInstruction {
  const ParsedInitializePool({required this.data})
    : super(StakingInstruction.initializePool);

  final InitializePoolInstructionData data;
}

/// A parsed Stake instruction.
final class ParsedStake extends ParsedStakingInstruction {
  const ParsedStake({required this.data}) : super(StakingInstruction.stake);

  final StakeInstructionData data;
}

/// A parsed Unstake instruction.
final class ParsedUnstake extends ParsedStakingInstruction {
  const ParsedUnstake({required this.data}) : super(StakingInstruction.unstake);

  final UnstakeInstructionData data;
}

/// A parsed ClaimRewards instruction.
final class ParsedClaimRewards extends ParsedStakingInstruction {
  const ParsedClaimRewards({required this.data})
    : super(StakingInstruction.claimRewards);

  final ClaimRewardsInstructionData data;
}

/// Parses a Staking instruction.
ParsedStakingInstruction parseStakingInstruction(
  Instruction instruction,
) {
  return switch (identifyStakingInstruction(
    instruction.data ?? Uint8List(0),
  )) {
    StakingInstruction.initializePool => ParsedInitializePool(
      data: parseInitializePoolInstruction(instruction),
    ),
    StakingInstruction.stake => ParsedStake(
      data: parseStakeInstruction(instruction),
    ),
    StakingInstruction.unstake => ParsedUnstake(
      data: parseUnstakeInstruction(instruction),
    ),
    StakingInstruction.claimRewards => ParsedClaimRewards(
      data: parseClaimRewardsInstruction(instruction),
    ),
  };
}
