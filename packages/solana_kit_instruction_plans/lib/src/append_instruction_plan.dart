import 'package:solana_kit_instruction_plans/src/instruction_plan.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

/// Appends all instructions from an instruction plan to a transaction
/// message.
///
/// This function flattens the instruction plan into its leaf plans and
/// sequentially appends each instruction to the provided transaction
/// message. It handles both single instructions and message packer plans.
TransactionMessage appendTransactionMessageInstructionPlan(
  InstructionPlan instructionPlan,
  TransactionMessage transactionMessage,
) {
  final leafInstructionPlans = flattenInstructionPlan(instructionPlan);
  var messageSoFar = transactionMessage;

  for (final plan in leafInstructionPlans) {
    switch (plan) {
      case SingleInstructionPlan(:final instruction):
        messageSoFar = appendTransactionMessageInstruction(
          instruction,
          messageSoFar,
        );
      case MessagePackerInstructionPlan(:final getMessagePacker):
        final packer = getMessagePacker();
        while (!packer.done()) {
          messageSoFar = packer.packMessageToCapacity(messageSoFar);
        }
      default:
        // Should not happen as flattenInstructionPlan only returns
        // SingleInstructionPlan and MessagePackerInstructionPlan.
        break;
    }
  }

  return messageSoFar;
}
