// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';

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

/// Identifies the type of a TokenVault instruction.
TokenVaultInstruction identifyTokenVaultInstruction(
  Uint8List data,
) {
  if (containsBytes(data, getU8Encoder().encode(0), 0)) {
    return TokenVaultInstruction.initializeVault;
  }
  if (containsBytes(data, getU8Encoder().encode(1), 0)) {
    return TokenVaultInstruction.deposit;
  }
  if (containsBytes(data, getU8Encoder().encode(2), 0)) {
    return TokenVaultInstruction.withdraw;
  }
  if (containsBytes(data, getU8Encoder().encode(3), 0)) {
    return TokenVaultInstruction.updateVaultStatus;
  }

  throw SolanaError(
    SolanaErrorCode.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': 'tokenVault',
    },
  );
}

/// A parsed instruction from the TokenVault program.
sealed class ParsedTokenVaultInstruction {
  const ParsedTokenVaultInstruction(this.instructionType);

  final TokenVaultInstruction instructionType;
}

/// A parsed InitializeVault instruction.
final class ParsedInitializeVault extends ParsedTokenVaultInstruction {
  const ParsedInitializeVault({required this.data})
    : super(TokenVaultInstruction.initializeVault);

  final InitializeVaultInstructionData data;
}

/// A parsed Deposit instruction.
final class ParsedDeposit extends ParsedTokenVaultInstruction {
  const ParsedDeposit({required this.data})
    : super(TokenVaultInstruction.deposit);

  final DepositInstructionData data;
}

/// A parsed Withdraw instruction.
final class ParsedWithdraw extends ParsedTokenVaultInstruction {
  const ParsedWithdraw({required this.data})
    : super(TokenVaultInstruction.withdraw);

  final WithdrawInstructionData data;
}

/// A parsed UpdateVaultStatus instruction.
final class ParsedUpdateVaultStatus extends ParsedTokenVaultInstruction {
  const ParsedUpdateVaultStatus({required this.data})
    : super(TokenVaultInstruction.updateVaultStatus);

  final UpdateVaultStatusInstructionData data;
}

/// Parses a TokenVault instruction.
ParsedTokenVaultInstruction parseTokenVaultInstruction(
  Instruction instruction,
) {
  return switch (identifyTokenVaultInstruction(
    instruction.data ?? Uint8List(0),
  )) {
    TokenVaultInstruction.initializeVault => ParsedInitializeVault(
      data: parseInitializeVaultInstruction(instruction),
    ),
    TokenVaultInstruction.deposit => ParsedDeposit(
      data: parseDepositInstruction(instruction),
    ),
    TokenVaultInstruction.withdraw => ParsedWithdraw(
      data: parseWithdrawInstruction(instruction),
    ),
    TokenVaultInstruction.updateVaultStatus => ParsedUpdateVaultStatus(
      data: parseUpdateVaultStatusInstruction(instruction),
    ),
  };
}
