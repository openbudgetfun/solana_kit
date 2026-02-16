import 'package:solana_kit_instruction_plans/src/instruction_plan.dart';
import 'package:solana_kit_instruction_plans/src/transaction_plan.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

/// Parses a flexible input and returns an [InstructionPlan].
///
/// This function handles the following input types:
/// - A single [Instruction] is wrapped in a [SingleInstructionPlan].
/// - An existing [InstructionPlan] is returned as-is.
/// - A [List] with a single element is unwrapped and parsed recursively.
/// - A [List] with multiple elements is wrapped in a divisible
///   [SequentialInstructionPlan].
InstructionPlan parseInstructionPlanInput(Object input) {
  if (input is List) {
    if (input.length == 1) {
      return parseInstructionPlanInput(input[0] as Object);
    }
    return sequentialInstructionPlan(
      input.map((e) => parseInstructionPlanInput(e as Object)).toList(),
    );
  }
  if (input is InstructionPlan) {
    return input;
  }
  return singleInstructionPlan(input as Instruction);
}

/// Parses a flexible input and returns a [TransactionPlan].
///
/// This function handles the following input types:
/// - A single [TransactionMessage] is wrapped in a
///   [SingleTransactionPlan].
/// - An existing [TransactionPlan] is returned as-is.
/// - A [List] with a single element is unwrapped and parsed recursively.
/// - A [List] with multiple elements is wrapped in a divisible
///   [SequentialTransactionPlan].
TransactionPlan parseTransactionPlanInput(Object input) {
  if (input is List) {
    if (input.length == 1) {
      return parseTransactionPlanInput(input[0] as Object);
    }
    return sequentialTransactionPlan(
      input.map((e) => parseTransactionPlanInput(e as Object)).toList(),
    );
  }
  if (input is TransactionPlan) {
    return input;
  }
  return singleTransactionPlan(input as TransactionMessage);
}

/// Parses a flexible input and returns an [InstructionPlan] or
/// [TransactionPlan].
///
/// Automatically detects whether the input represents instructions
/// or transactions and delegates to the appropriate parser.
Object parseInstructionOrTransactionPlanInput(Object input) {
  if (input is List && input.isEmpty) {
    return parseTransactionPlanInput(input);
  }
  if (input is List && _isTransactionPlanInput(input[0] as Object)) {
    return parseTransactionPlanInput(input);
  }
  if (_isTransactionPlanInput(input)) {
    return parseTransactionPlanInput(input);
  }
  return parseInstructionPlanInput(input);
}

bool _isTransactionPlanInput(Object value) =>
    value is TransactionPlan || _isTransactionMessage(value);

bool _isTransactionMessage(Object value) => value is TransactionMessage;
