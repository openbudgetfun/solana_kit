/// Instruction plans describe operations that go beyond a single instruction
/// and may even span multiple transactions.
///
/// They define a set of instructions that must be executed following a
/// specific order. For instance, imagine we wanted to create an instruction
/// plan for a simple escrow transfer between Alice and Bob. First, both
/// would need to deposit their assets into a vault. This could happen in
/// any order. Then and only then, the vault can be activated to switch the
/// assets. Alice and Bob can now both withdraw each other's assets (again,
/// in any order).
///
/// ```dart
/// final instructionPlan = sequentialInstructionPlan([
///   parallelInstructionPlan([depositFromAlice, depositFromBob]),
///   activateVault,
///   parallelInstructionPlan([withdrawToAlice, withdrawToBob]),
/// ]);
/// ```
///
/// Instruction plans don't concern themselves with building transaction
/// messages from these instructions. Instead, they solely focus on
/// describing operations and delegate all that to two components:
/// - **Transaction planner**: builds transaction messages from an
///   instruction plan and returns an appropriate transaction plan.
/// - **Transaction plan executor**: compiles, signs and sends
///   transaction plans and returns a detailed result of this operation.
library;

export 'src/append_instruction_plan.dart';
export 'src/instruction_plan.dart';
export 'src/instruction_plan_input.dart';
export 'src/transaction_plan.dart';
export 'src/transaction_plan_executor.dart';
export 'src/transaction_plan_result.dart';
export 'src/transaction_planner.dart';
