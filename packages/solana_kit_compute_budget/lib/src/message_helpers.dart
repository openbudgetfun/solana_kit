import 'dart:typed_data';

import 'package:solana_kit_compute_budget/src/generated/instructions/set_compute_unit_limit.dart';
import 'package:solana_kit_compute_budget/src/generated/instructions/set_compute_unit_price.dart';
import 'package:solana_kit_compute_budget/src/generated/programs/compute_budget.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

/// A provisional compute unit limit used before estimation.
const provisoryComputeUnitLimit = 0;

/// The maximum compute unit limit accepted by the Compute Budget program.
const maxComputeUnitLimit = 1400000;

/// The index and units for a `SetComputeUnitLimit` instruction.
typedef SetComputeUnitLimitInstructionDetails = ({int index, int units});

/// The index and micro-lamports for a `SetComputeUnitPrice` instruction.
typedef SetComputeUnitPriceInstructionDetails = ({
  int index,
  BigInt microLamports,
});

/// A function that updates a compute unit limit from its previous value.
typedef ComputeUnitLimitUpdater = int Function(int? previousUnits);

/// A function that updates a compute unit price from its previous value.
typedef ComputeUnitPriceUpdater =
    BigInt Function(BigInt? previousMicroLamports);

/// Finds the first `SetComputeUnitLimit` instruction and its units.
SetComputeUnitLimitInstructionDetails?
findSetComputeUnitLimitInstructionIndexAndUnits(
  TransactionMessage transactionMessage,
) {
  final index = transactionMessage.instructions.indexWhere(
    _isSetComputeUnitLimitInstruction,
  );
  if (index < 0) return null;

  final data = transactionMessage.instructions[index].data!;
  return (
    index: index,
    units: ByteData.sublistView(data).getUint32(1, Endian.little),
  );
}

/// Finds the first `SetComputeUnitPrice` instruction and its micro-lamports.
SetComputeUnitPriceInstructionDetails?
findSetComputeUnitPriceInstructionIndexAndMicroLamports(
  TransactionMessage transactionMessage,
) {
  final index = transactionMessage.instructions.indexWhere(
    _isSetComputeUnitPriceInstruction,
  );
  if (index < 0) return null;

  final data = transactionMessage.instructions[index].data!;
  return (
    index: index,
    microLamports: BigInt.from(
      ByteData.sublistView(data).getUint64(1, Endian.little),
    ),
  );
}

/// Appends a provisory `SetComputeUnitLimit` instruction when none exists.
TransactionMessage fillProvisorySetComputeUnitLimitInstruction(
  TransactionMessage transactionMessage,
) {
  return updateOrAppendSetComputeUnitLimitInstruction(
    (int? previousUnits) => previousUnits ?? provisoryComputeUnitLimit,
    transactionMessage,
  );
}

/// Sets the compute unit price by appending a `SetComputeUnitPrice` instruction.
TransactionMessage setTransactionMessageComputeUnitPrice(
  BigInt microLamports,
  TransactionMessage transactionMessage,
) {
  return appendTransactionMessageInstruction(
    getSetComputeUnitPriceInstruction(microLamports: microLamports),
    transactionMessage,
  );
}

/// Updates the first `SetComputeUnitLimit` instruction, or appends one.
TransactionMessage updateOrAppendSetComputeUnitLimitInstruction(
  Object units,
  TransactionMessage transactionMessage,
) {
  final details = findSetComputeUnitLimitInstructionIndexAndUnits(
    transactionMessage,
  );
  final previousUnits = details?.units;
  final newUnits = units is int
      ? units
      : (units as int Function(int?))(previousUnits);

  if (details == null) {
    return appendTransactionMessageInstruction(
      getSetComputeUnitLimitInstruction(units: newUnits),
      transactionMessage,
    );
  }

  if (newUnits == previousUnits) return transactionMessage;
  return transactionMessage.copyWith(
    instructions: _replaceInstructionAt(
      transactionMessage.instructions,
      details.index,
      getSetComputeUnitLimitInstruction(units: newUnits),
    ),
  );
}

/// Updates the first `SetComputeUnitPrice` instruction, or appends one.
TransactionMessage updateOrAppendSetComputeUnitPriceInstruction(
  Object microLamports,
  TransactionMessage transactionMessage,
) {
  final details = findSetComputeUnitPriceInstructionIndexAndMicroLamports(
    transactionMessage,
  );
  final previousMicroLamports = details?.microLamports;
  final newMicroLamports = microLamports is BigInt
      ? microLamports
      : (microLamports as BigInt Function(BigInt?))(previousMicroLamports);

  if (details == null) {
    return appendTransactionMessageInstruction(
      getSetComputeUnitPriceInstruction(microLamports: newMicroLamports),
      transactionMessage,
    );
  }

  if (newMicroLamports == previousMicroLamports) return transactionMessage;
  return transactionMessage.copyWith(
    instructions: _replaceInstructionAt(
      transactionMessage.instructions,
      details.index,
      getSetComputeUnitPriceInstruction(microLamports: newMicroLamports),
    ),
  );
}

bool _isSetComputeUnitLimitInstruction(Instruction instruction) {
  if (instruction.programAddress != computeBudgetProgramAddress) return false;
  final data = instruction.data;
  return data != null &&
      data.length >= 5 &&
      identifyComputeBudgetInstruction(data) ==
          ComputeBudgetInstruction.setComputeUnitLimit;
}

bool _isSetComputeUnitPriceInstruction(Instruction instruction) {
  if (instruction.programAddress != computeBudgetProgramAddress) return false;
  final data = instruction.data;
  return data != null &&
      data.length >= 9 &&
      identifyComputeBudgetInstruction(data) ==
          ComputeBudgetInstruction.setComputeUnitPrice;
}

List<Instruction> _replaceInstructionAt(
  List<Instruction> instructions,
  int index,
  Instruction instruction,
) {
  return List.unmodifiable([
    ...instructions.take(index),
    instruction,
    ...instructions.skip(index + 1),
  ]);
}
