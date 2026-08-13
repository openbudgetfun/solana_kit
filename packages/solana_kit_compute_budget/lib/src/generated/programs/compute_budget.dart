// Auto-generated. Do not edit.
// ignore_for_file: type=lint

/// The address of the ComputeBudget program.

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';

export 'package:solana_kit_addresses/solana_kit_addresses.dart'
    show computeBudgetProgramAddress;

/// Known instructions for the ComputeBudget program.
enum ComputeBudgetInstruction {
  requestUnits,
  requestHeapFrame,
  setComputeUnitLimit,
  setComputeUnitPrice,
  setLoadedAccountsDataSizeLimit,
}

/// Identifies the type of a ComputeBudget instruction.
ComputeBudgetInstruction identifyComputeBudgetInstruction(
  Uint8List data,
) {
  if (containsBytes(data, getU8Encoder().encode(0), 0)) {
    return ComputeBudgetInstruction.requestUnits;
  }
  if (containsBytes(data, getU8Encoder().encode(1), 0)) {
    return ComputeBudgetInstruction.requestHeapFrame;
  }
  if (containsBytes(data, getU8Encoder().encode(2), 0)) {
    return ComputeBudgetInstruction.setComputeUnitLimit;
  }
  if (containsBytes(data, getU8Encoder().encode(3), 0)) {
    return ComputeBudgetInstruction.setComputeUnitPrice;
  }
  if (containsBytes(data, getU8Encoder().encode(4), 0)) {
    return ComputeBudgetInstruction.setLoadedAccountsDataSizeLimit;
  }

  throw SolanaError(
    SolanaErrorCode.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': 'computeBudget',
    },
  );
}

/// A parsed instruction from the ComputeBudget program.
sealed class ParsedComputeBudgetInstruction {
  const ParsedComputeBudgetInstruction(this.instructionType);

  final ComputeBudgetInstruction instructionType;
}

/// A parsed RequestUnits instruction.
final class ParsedRequestUnits extends ParsedComputeBudgetInstruction {
  const ParsedRequestUnits({required this.data})
    : super(ComputeBudgetInstruction.requestUnits);

  final RequestUnitsInstructionData data;
}

/// A parsed RequestHeapFrame instruction.
final class ParsedRequestHeapFrame extends ParsedComputeBudgetInstruction {
  const ParsedRequestHeapFrame({required this.data})
    : super(ComputeBudgetInstruction.requestHeapFrame);

  final RequestHeapFrameInstructionData data;
}

/// A parsed SetComputeUnitLimit instruction.
final class ParsedSetComputeUnitLimit extends ParsedComputeBudgetInstruction {
  const ParsedSetComputeUnitLimit({required this.data})
    : super(ComputeBudgetInstruction.setComputeUnitLimit);

  final SetComputeUnitLimitInstructionData data;
}

/// A parsed SetComputeUnitPrice instruction.
final class ParsedSetComputeUnitPrice extends ParsedComputeBudgetInstruction {
  const ParsedSetComputeUnitPrice({required this.data})
    : super(ComputeBudgetInstruction.setComputeUnitPrice);

  final SetComputeUnitPriceInstructionData data;
}

/// A parsed SetLoadedAccountsDataSizeLimit instruction.
final class ParsedSetLoadedAccountsDataSizeLimit
    extends ParsedComputeBudgetInstruction {
  const ParsedSetLoadedAccountsDataSizeLimit({required this.data})
    : super(ComputeBudgetInstruction.setLoadedAccountsDataSizeLimit);

  final SetLoadedAccountsDataSizeLimitInstructionData data;
}

/// Parses a ComputeBudget instruction.
ParsedComputeBudgetInstruction parseComputeBudgetInstruction(
  Instruction instruction,
) {
  return switch (identifyComputeBudgetInstruction(
    instruction.data ?? Uint8List(0),
  )) {
    ComputeBudgetInstruction.requestUnits => ParsedRequestUnits(
      data: parseRequestUnitsInstruction(instruction),
    ),
    ComputeBudgetInstruction.requestHeapFrame => ParsedRequestHeapFrame(
      data: parseRequestHeapFrameInstruction(instruction),
    ),
    ComputeBudgetInstruction.setComputeUnitLimit => ParsedSetComputeUnitLimit(
      data: parseSetComputeUnitLimitInstruction(instruction),
    ),
    ComputeBudgetInstruction.setComputeUnitPrice => ParsedSetComputeUnitPrice(
      data: parseSetComputeUnitPriceInstruction(instruction),
    ),
    ComputeBudgetInstruction.setLoadedAccountsDataSizeLimit =>
      ParsedSetLoadedAccountsDataSizeLimit(
        data: parseSetLoadedAccountsDataSizeLimitInstruction(instruction),
      ),
  };
}
