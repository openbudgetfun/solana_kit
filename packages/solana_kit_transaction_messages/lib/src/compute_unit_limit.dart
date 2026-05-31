import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/v1_transaction_config.dart';

/// A provisional compute unit limit used as a placeholder before estimation.
const provisoryComputeUnitLimit = 0;

/// The maximum compute unit limit accepted by the Compute Budget program.
const maxComputeUnitLimit = 1400000;

const _setComputeUnitLimitDiscriminator = 2;

/// A function that estimates the compute unit limit for [transactionMessage].
typedef EstimateComputeUnitLimit =
    Future<int> Function(TransactionMessage transactionMessage);

/// Returns the compute unit limit set on [transactionMessage], if any.
int? getTransactionMessageComputeUnitLimit(
  TransactionMessage transactionMessage,
) {
  if (transactionMessage.version == TransactionVersion.v1) {
    return transactionMessage.config?.computeUnitLimit;
  }

  final instruction = transactionMessage.instructions
      .where(_isSetComputeUnitLimitInstruction)
      .firstOrNull;
  if (instruction == null) return null;
  return _parseComputeUnitLimitInstruction(instruction);
}

/// Sets or removes the compute unit limit on [transactionMessage].
///
/// For legacy and v0 messages this appends a Compute Budget
/// `SetComputeUnitLimit` instruction, replaces the first existing one, or
/// removes the first existing one when [computeUnitLimit] is `null`.
TransactionMessage setTransactionMessageComputeUnitLimit(
  int? computeUnitLimit,
  TransactionMessage transactionMessage,
) {
  if (transactionMessage.version == TransactionVersion.v1) {
    return _setTransactionMessageComputeUnitLimitUsingConfig(
      computeUnitLimit,
      transactionMessage,
    );
  }

  final existingIndex = transactionMessage.instructions.indexWhere(
    _isSetComputeUnitLimitInstruction,
  );

  if (computeUnitLimit == null) {
    if (existingIndex == -1) return transactionMessage;
    return transactionMessage.copyWith(
      instructions: _withoutInstructionAt(
        transactionMessage.instructions,
        existingIndex,
      ),
    );
  }

  if (getTransactionMessageComputeUnitLimit(transactionMessage) ==
      computeUnitLimit) {
    return transactionMessage;
  }

  final instruction = _getSetComputeUnitLimitInstruction(
    units: computeUnitLimit,
  );
  if (existingIndex == -1) {
    return transactionMessage.copyWith(
      instructions: [...transactionMessage.instructions, instruction],
    );
  }

  return transactionMessage.copyWith(
    instructions: _replaceInstructionAt(
      transactionMessage.instructions,
      existingIndex,
      instruction,
    ),
  );
}

/// Returns [transactionMessage] with a provisional compute unit limit if none
/// is already present.
TransactionMessage fillTransactionMessageProvisoryComputeUnitLimit(
  TransactionMessage transactionMessage,
) {
  if (getTransactionMessageComputeUnitLimit(transactionMessage) != null) {
    return transactionMessage;
  }
  return setTransactionMessageComputeUnitLimit(
    provisoryComputeUnitLimit,
    transactionMessage,
  );
}

/// Returns a function that estimates and sets the compute unit limit.
///
/// Existing non-provisional, non-maximum limits are preserved. A provisional
/// limit (`0`) or maximum limit (`1400000`) is replaced with the estimate.
Future<TransactionMessage> Function(TransactionMessage transactionMessage)
estimateAndSetComputeUnitLimitFactory(
  EstimateComputeUnitLimit estimateComputeUnitLimit,
) {
  return (transactionMessage) async {
    final existingLimit = getTransactionMessageComputeUnitLimit(
      transactionMessage,
    );
    if (existingLimit != null &&
        existingLimit != provisoryComputeUnitLimit &&
        existingLimit != maxComputeUnitLimit) {
      return transactionMessage;
    }

    final estimatedUnits = await estimateComputeUnitLimit(transactionMessage);
    return setTransactionMessageComputeUnitLimit(
      estimatedUnits,
      transactionMessage,
    );
  };
}

TransactionMessage _setTransactionMessageComputeUnitLimitUsingConfig(
  int? computeUnitLimit,
  TransactionMessage transactionMessage,
) {
  final nextConfig = computeUnitLimit == null
      ? transactionMessage.config?.copyWith(clearComputeUnitLimit: true)
      : setTransactionMessageConfig(
          V1TransactionConfig(computeUnitLimit: computeUnitLimit),
          transactionMessage,
        ).config;

  if (nextConfig == null || nextConfig.isEmpty) {
    return transactionMessage.config == null
        ? transactionMessage
        : transactionMessage.copyWith(clearConfig: true);
  }

  if (transactionMessage.config == nextConfig) return transactionMessage;
  return transactionMessage.copyWith(config: nextConfig);
}

Instruction _getSetComputeUnitLimitInstruction({required int units}) {
  final data = Uint8List(5)..first = _setComputeUnitLimitDiscriminator;
  ByteData.sublistView(data).setUint32(1, units, Endian.little);
  return Instruction(
    programAddress: computeBudgetProgramAddress,
    accounts: const [],
    data: data,
  );
}

bool _isSetComputeUnitLimitInstruction(Instruction instruction) {
  if (instruction.programAddress != computeBudgetProgramAddress) return false;
  final data = instruction.data;
  return data != null &&
      data.length >= 5 &&
      data.first == _setComputeUnitLimitDiscriminator;
}

int _parseComputeUnitLimitInstruction(Instruction instruction) {
  return ByteData.sublistView(instruction.data!).getUint32(1, Endian.little);
}

List<Instruction> _withoutInstructionAt(
  List<Instruction> instructions,
  int index,
) {
  return [...instructions.take(index), ...instructions.skip(index + 1)];
}

List<Instruction> _replaceInstructionAt(
  List<Instruction> instructions,
  int index,
  Instruction instruction,
) {
  return [
    ...instructions.take(index),
    instruction,
    ...instructions.skip(index + 1),
  ];
}
