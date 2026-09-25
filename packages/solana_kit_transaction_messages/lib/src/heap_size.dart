import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/resource_limit_validation.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/v1_transaction_config.dart';

const _requestHeapFrameDiscriminator = 1;

/// Returns the heap size currently set on [transactionMessage], if any.
///
/// This function works with all transaction versions:
/// - **V1**: reads from the transaction message's `config.heapSize`.
/// - **Legacy / V0**: searches the instructions for a `RequestHeapFrame`
///   instruction and decodes its value.
int? getTransactionMessageHeapSize(TransactionMessage transactionMessage) {
  if (transactionMessage.version == TransactionVersion.v1) {
    return transactionMessage.config?.heapSize;
  }

  final instruction = transactionMessage.instructions
      .where(_isRequestHeapFrameInstruction)
      .firstOrNull;
  if (instruction == null) return null;
  return _getHeapSizeFromInstructionData(instruction.data!);
}

/// Sets the heap frame size for [transactionMessage].
///
/// This function works with all transaction versions:
/// - **V1**: sets the `heapSize` field in the transaction message's config.
/// - **Legacy / V0**: appends (or replaces) a `RequestHeapFrame` instruction
///   from the Compute Budget program.
///
/// Pass `null` as [heapSize] to remove the setting.
///
/// Throws a [SolanaError] with code
/// `SolanaErrorCode.transactionInvalidHeapSize` when [heapSize] is not an
/// integer multiple of [heapSizeMultipleOf] bytes between [minHeapSize] and
/// [maxHeapSize] inclusive. An invalid heap size fails the transaction
/// on-chain, so the value is rejected at the point it is set. Added in
/// @solana/kit v8.1.0 (#1972); the setter itself mirrors upstream's
/// `heap-size.ts` module.
TransactionMessage setTransactionMessageHeapSize(
  int? heapSize,
  TransactionMessage transactionMessage,
) {
  if (heapSize != null) {
    assertIsValidHeapSize(heapSize);
  }

  if (transactionMessage.version == TransactionVersion.v1) {
    return _setTransactionMessageHeapSizeUsingConfig(
      heapSize,
      transactionMessage,
    );
  }
  return _setTransactionMessageHeapSizeUsingInstruction(
    heapSize,
    transactionMessage,
  );
}

TransactionMessage _setTransactionMessageHeapSizeUsingConfig(
  int? heapSize,
  TransactionMessage transactionMessage,
) {
  final nextConfig = heapSize == null
      ? transactionMessage.config?.copyWith(clearHeapSize: true)
      : setTransactionMessageConfig(
          V1TransactionConfig(heapSize: heapSize),
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

TransactionMessage _setTransactionMessageHeapSizeUsingInstruction(
  int? heapSize,
  TransactionMessage transactionMessage,
) {
  final existingIndex = transactionMessage.instructions.indexWhere(
    _isRequestHeapFrameInstruction,
  );

  // Remove the heap size instruction if there is one and the new size is
  // undefined.
  if (heapSize == null) {
    if (existingIndex == -1) return transactionMessage;
    return transactionMessage.copyWith(
      instructions: _withoutInstructionAt(
        transactionMessage.instructions,
        existingIndex,
      ),
    );
  }

  // Ignore if the new heap size is the same as the existing one.
  if (getTransactionMessageHeapSize(transactionMessage) == heapSize) {
    return transactionMessage;
  }

  // Add or replace the heap size instruction with the new size.
  final instruction = _getRequestHeapFrameInstruction(bytes: heapSize);
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

Instruction _getRequestHeapFrameInstruction({required int bytes}) {
  final data = Uint8List(5)..first = _requestHeapFrameDiscriminator;
  ByteData.sublistView(data).setUint32(1, bytes, Endian.little);
  return Instruction(
    programAddress: computeBudgetProgramAddress,
    accounts: const [],
    data: data,
  );
}

bool _isRequestHeapFrameInstruction(Instruction instruction) {
  if (instruction.programAddress != computeBudgetProgramAddress) return false;
  final data = instruction.data;
  return data != null &&
      data.length >= 5 &&
      data.first == _requestHeapFrameDiscriminator;
}

int _getHeapSizeFromInstructionData(Uint8List data) {
  return ByteData.sublistView(data).getUint32(1, Endian.little);
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
