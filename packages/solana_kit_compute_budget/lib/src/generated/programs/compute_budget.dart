// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_compute_budget/src/generated/instructions/request_heap_frame.dart';
import 'package:solana_kit_compute_budget/src/generated/instructions/request_units.dart';
import 'package:solana_kit_compute_budget/src/generated/instructions/set_compute_unit_limit.dart';
import 'package:solana_kit_compute_budget/src/generated/instructions/set_compute_unit_price.dart';
import 'package:solana_kit_compute_budget/src/generated/instructions/set_loaded_accounts_data_size_limit.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The canonical Compute Budget program address.
const computeBudgetProgramAddress = Address(
  'ComputeBudget111111111111111111111111111111',
);

/// Known instruction types for the Compute Budget program.
enum ComputeBudgetInstruction {
  /// Deprecated request-units instruction (discriminator 0).
  requestUnits,

  /// Request a specific heap frame size (discriminator 1).
  requestHeapFrame,

  /// Set a transaction-wide compute unit limit (discriminator 2).
  setComputeUnitLimit,

  /// Set a compute unit price for priority fees (discriminator 3).
  setComputeUnitPrice,

  /// Set a limit on loaded accounts data size (discriminator 4).
  setLoadedAccountsDataSizeLimit,
}

/// Identifies the instruction type from raw instruction [data].
///
/// Returns the matching [ComputeBudgetInstruction] variant based on the
/// single-byte discriminator at offset 0.
///
/// Throws [ArgumentError] if the discriminator is unrecognized.
ComputeBudgetInstruction identifyComputeBudgetInstruction(Uint8List data) {
  if (data.isEmpty) {
    throw ArgumentError('Empty instruction data');
  }
  final discriminator = data[0];
  return switch (discriminator) {
    0 => ComputeBudgetInstruction.requestUnits,
    1 => ComputeBudgetInstruction.requestHeapFrame,
    2 => ComputeBudgetInstruction.setComputeUnitLimit,
    3 => ComputeBudgetInstruction.setComputeUnitPrice,
    4 => ComputeBudgetInstruction.setLoadedAccountsDataSizeLimit,
    _ => throw ArgumentError(
      'Unrecognized Compute Budget instruction discriminator: $discriminator',
    ),
  };
}

/// A parsed Compute Budget instruction with its identified type and data.
sealed class ParsedComputeBudgetInstruction {
  /// The instruction type.
  ComputeBudgetInstruction get instructionType;
}

/// A parsed [ComputeBudgetInstruction.requestUnits] instruction.
class ParsedRequestUnits implements ParsedComputeBudgetInstruction {
  /// Creates a [ParsedRequestUnits].
  const ParsedRequestUnits(this.data);

  @override
  ComputeBudgetInstruction get instructionType =>
      ComputeBudgetInstruction.requestUnits;

  /// The decoded instruction data.
  final RequestUnitsInstructionData data;
}

/// A parsed [ComputeBudgetInstruction.requestHeapFrame] instruction.
class ParsedRequestHeapFrame implements ParsedComputeBudgetInstruction {
  /// Creates a [ParsedRequestHeapFrame].
  const ParsedRequestHeapFrame(this.data);

  @override
  ComputeBudgetInstruction get instructionType =>
      ComputeBudgetInstruction.requestHeapFrame;

  /// The decoded instruction data.
  final RequestHeapFrameInstructionData data;
}

/// A parsed [ComputeBudgetInstruction.setComputeUnitLimit] instruction.
class ParsedSetComputeUnitLimit implements ParsedComputeBudgetInstruction {
  /// Creates a [ParsedSetComputeUnitLimit].
  const ParsedSetComputeUnitLimit(this.data);

  @override
  ComputeBudgetInstruction get instructionType =>
      ComputeBudgetInstruction.setComputeUnitLimit;

  /// The decoded instruction data.
  final SetComputeUnitLimitInstructionData data;
}

/// A parsed [ComputeBudgetInstruction.setComputeUnitPrice] instruction.
class ParsedSetComputeUnitPrice implements ParsedComputeBudgetInstruction {
  /// Creates a [ParsedSetComputeUnitPrice].
  const ParsedSetComputeUnitPrice(this.data);

  @override
  ComputeBudgetInstruction get instructionType =>
      ComputeBudgetInstruction.setComputeUnitPrice;

  /// The decoded instruction data.
  final SetComputeUnitPriceInstructionData data;
}

/// A parsed [ComputeBudgetInstruction.setLoadedAccountsDataSizeLimit]
/// instruction.
class ParsedSetLoadedAccountsDataSizeLimit
    implements ParsedComputeBudgetInstruction {
  /// Creates a [ParsedSetLoadedAccountsDataSizeLimit].
  const ParsedSetLoadedAccountsDataSizeLimit(this.data);

  @override
  ComputeBudgetInstruction get instructionType =>
      ComputeBudgetInstruction.setLoadedAccountsDataSizeLimit;

  /// The decoded instruction data.
  final SetLoadedAccountsDataSizeLimitInstructionData data;
}

/// Parses a Compute Budget [instruction] into a typed
/// [ParsedComputeBudgetInstruction].
///
/// Throws [ArgumentError] if the instruction cannot be identified.
ParsedComputeBudgetInstruction parseComputeBudgetInstruction(
  Instruction instruction,
) {
  final data = instruction.data;
  if (data == null || data.isEmpty) {
    throw ArgumentError('Instruction has no data');
  }

  final type = identifyComputeBudgetInstruction(data);

  return switch (type) {
    ComputeBudgetInstruction.requestUnits => ParsedRequestUnits(
      getRequestUnitsInstructionDataDecoder().decode(data),
    ),
    ComputeBudgetInstruction.requestHeapFrame => ParsedRequestHeapFrame(
      getRequestHeapFrameInstructionDataDecoder().decode(data),
    ),
    ComputeBudgetInstruction.setComputeUnitLimit =>
      ParsedSetComputeUnitLimit(
        getSetComputeUnitLimitInstructionDataDecoder().decode(data),
      ),
    ComputeBudgetInstruction.setComputeUnitPrice =>
      ParsedSetComputeUnitPrice(
        getSetComputeUnitPriceInstructionDataDecoder().decode(data),
      ),
    ComputeBudgetInstruction.setLoadedAccountsDataSizeLimit =>
      ParsedSetLoadedAccountsDataSizeLimit(
        getSetLoadedAccountsDataSizeLimitInstructionDataDecoder().decode(data),
      ),
  };
}
