import 'dart:math' as math;

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// A set of instructions with constraints on how they can be executed.
///
/// This is structured as a recursive tree of plans in order to allow for
/// parallel execution, sequential execution and combinations of both.
///
/// The following plans are supported:
/// - [SingleInstructionPlan] - A plan that contains a single instruction.
/// - [ParallelInstructionPlan] - A plan that contains other plans that
///   can be executed in parallel.
/// - [SequentialInstructionPlan] - A plan that contains other plans that
///   must be executed sequentially.
/// - [MessagePackerInstructionPlan] - A plan that can dynamically pack
///   instructions into transaction messages.
sealed class InstructionPlan {
  /// Creates an [InstructionPlan].
  const InstructionPlan();

  /// The kind discriminator for this instruction plan.
  String get kind;
}

/// A plan that contains a single instruction.
///
/// This is a simple instruction wrapper and the simplest leaf in the
/// instruction plan tree.
class SingleInstructionPlan extends InstructionPlan {
  /// Creates a [SingleInstructionPlan] wrapping the given [instruction].
  const SingleInstructionPlan({required this.instruction});

  /// The instruction contained in this plan.
  final Instruction instruction;

  @override
  String get kind => 'single';
}

/// A plan wrapping other plans that must be executed sequentially.
///
/// It also defines whether nested plans are [divisible] -- meaning that
/// the instructions inside them can be split into separate transactions.
/// When [divisible] is `false`, the instructions inside the plan should
/// all be executed atomically -- either in a single transaction or in a
/// transaction bundle.
class SequentialInstructionPlan extends InstructionPlan {
  /// Creates a [SequentialInstructionPlan] with the given [plans] and
  /// [divisible] flag.
  const SequentialInstructionPlan({required this.plans, this.divisible = true});

  /// The nested plans that must be executed sequentially.
  final List<InstructionPlan> plans;

  /// Whether the instructions inside this plan can be split into separate
  /// transactions.
  final bool divisible;

  @override
  String get kind => 'sequential';
}

/// A plan wrapping other plans that can be executed in parallel.
///
/// This means direct children of this plan can be executed in separate
/// parallel transactions without consequence.
class ParallelInstructionPlan extends InstructionPlan {
  /// Creates a [ParallelInstructionPlan] with the given [plans].
  const ParallelInstructionPlan({required this.plans});

  /// The nested plans that can be executed in parallel.
  final List<InstructionPlan> plans;

  @override
  String get kind => 'parallel';
}

/// A plan that can dynamically pack instructions into transaction messages.
///
/// This plan provides a [MessagePacker] via the [getMessagePacker]
/// method, which enables instructions to be dynamically packed into the
/// provided transaction message until there are no more instructions to pack.
class MessagePackerInstructionPlan extends InstructionPlan {
  /// Creates a [MessagePackerInstructionPlan] with the given
  /// [getMessagePacker] factory.
  const MessagePackerInstructionPlan({required this.getMessagePacker});

  /// Returns a new [MessagePacker] for this plan.
  final MessagePacker Function() getMessagePacker;

  @override
  String get kind => 'messagePacker';
}

/// The message packer returned by the [MessagePackerInstructionPlan].
///
/// It offers a [packMessageToCapacity] method that packs as many instructions
/// as possible into the provided transaction message, while still being able
/// to fit into the transaction size limit.
///
/// The [done] method checks whether there are more instructions to pack into
/// transaction messages.
class MessagePacker {
  /// Creates a [MessagePacker] with the given [done] and
  /// [packMessageToCapacity] functions.
  const MessagePacker({
    required this.done,
    required this.packMessageToCapacity,
  });

  /// Checks whether the message packer has more instructions to pack.
  final bool Function() done;

  /// Packs the provided transaction message with instructions or throws
  /// if not possible.
  ///
  /// Throws a [SolanaError] with code
  /// [SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan]
  /// if the provided transaction message cannot be used to fill the next
  /// instructions.
  ///
  /// Throws a [SolanaError] with code
  /// [SolanaErrorCode.instructionPlansMessagePackerAlreadyComplete]
  /// if the message packer is already done and no more instructions can
  /// be packed.
  final TransactionMessage Function(TransactionMessage) packMessageToCapacity;
}

// ---------------------------------------------------------------------------
// Constructor helpers
// ---------------------------------------------------------------------------

List<InstructionPlan> _parseSingleInstructionPlans(List<Object> plans) =>
    List<InstructionPlan>.unmodifiable(
      plans.map(
        (plan) => plan is InstructionPlan
            ? plan
            : SingleInstructionPlan(instruction: plan as Instruction),
      ),
    );

/// Creates a [SingleInstructionPlan] from an [Instruction].
SingleInstructionPlan singleInstructionPlan(Instruction instruction) =>
    SingleInstructionPlan(instruction: instruction);

/// Creates a divisible [SequentialInstructionPlan] from an array of nested
/// plans.
///
/// It can accept [Instruction] objects directly, which will be wrapped
/// in [SingleInstructionPlan]s automatically.
SequentialInstructionPlan sequentialInstructionPlan(List<Object> plans) =>
    SequentialInstructionPlan(plans: _parseSingleInstructionPlans(plans));

/// Creates a non-divisible [SequentialInstructionPlan] from an array of
/// nested plans.
///
/// It can accept [Instruction] objects directly, which will be wrapped
/// in [SingleInstructionPlan]s automatically.
SequentialInstructionPlan nonDivisibleSequentialInstructionPlan(
  List<Object> plans,
) => SequentialInstructionPlan(
  plans: _parseSingleInstructionPlans(plans),
  divisible: false,
);

/// Creates a [ParallelInstructionPlan] from an array of nested plans.
///
/// It can accept [Instruction] objects directly, which will be wrapped
/// in [SingleInstructionPlan]s automatically.
ParallelInstructionPlan parallelInstructionPlan(List<Object> plans) =>
    ParallelInstructionPlan(plans: _parseSingleInstructionPlans(plans));

// ---------------------------------------------------------------------------
// Type checks and assertions
// ---------------------------------------------------------------------------

/// Returns `true` if [value] is an [InstructionPlan].
bool isInstructionPlan(Object? value) => value is InstructionPlan;

/// Returns `true` if [plan] is a [SingleInstructionPlan].
bool isSingleInstructionPlan(InstructionPlan plan) =>
    plan is SingleInstructionPlan;

/// Asserts that [plan] is a [SingleInstructionPlan].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansUnexpectedInstructionPlan] if the plan
/// is not a single instruction plan.
void assertIsSingleInstructionPlan(InstructionPlan plan) {
  if (plan is! SingleInstructionPlan) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedInstructionPlan,
      {'actualKind': plan.kind, 'expectedKind': 'single'},
    );
  }
}

/// Returns `true` if [plan] is a [MessagePackerInstructionPlan].
bool isMessagePackerInstructionPlan(InstructionPlan plan) =>
    plan is MessagePackerInstructionPlan;

/// Asserts that [plan] is a [MessagePackerInstructionPlan].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansUnexpectedInstructionPlan] if the plan
/// is not a message packer instruction plan.
void assertIsMessagePackerInstructionPlan(InstructionPlan plan) {
  if (plan is! MessagePackerInstructionPlan) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedInstructionPlan,
      {'actualKind': plan.kind, 'expectedKind': 'messagePacker'},
    );
  }
}

/// Returns `true` if [plan] is a [SequentialInstructionPlan].
bool isSequentialInstructionPlan(InstructionPlan plan) =>
    plan is SequentialInstructionPlan;

/// Asserts that [plan] is a [SequentialInstructionPlan].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansUnexpectedInstructionPlan] if the plan
/// is not a sequential instruction plan.
void assertIsSequentialInstructionPlan(InstructionPlan plan) {
  if (plan is! SequentialInstructionPlan) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedInstructionPlan,
      {'actualKind': plan.kind, 'expectedKind': 'sequential'},
    );
  }
}

/// Returns `true` if [plan] is a non-divisible [SequentialInstructionPlan].
bool isNonDivisibleSequentialInstructionPlan(InstructionPlan plan) =>
    plan is SequentialInstructionPlan && !plan.divisible;

/// Asserts that [plan] is a non-divisible [SequentialInstructionPlan].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansUnexpectedInstructionPlan] if the plan
/// is not a non-divisible sequential instruction plan.
void assertIsNonDivisibleSequentialInstructionPlan(InstructionPlan plan) {
  if (plan is! SequentialInstructionPlan || plan.divisible) {
    final actualKind = plan is SequentialInstructionPlan && plan.divisible
        ? 'divisible sequential'
        : plan.kind;
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedInstructionPlan,
      {'actualKind': actualKind, 'expectedKind': 'non-divisible sequential'},
    );
  }
}

/// Returns `true` if [plan] is a [ParallelInstructionPlan].
bool isParallelInstructionPlan(InstructionPlan plan) =>
    plan is ParallelInstructionPlan;

/// Asserts that [plan] is a [ParallelInstructionPlan].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansUnexpectedInstructionPlan] if the plan
/// is not a parallel instruction plan.
void assertIsParallelInstructionPlan(InstructionPlan plan) {
  if (plan is! ParallelInstructionPlan) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedInstructionPlan,
      {'actualKind': plan.kind, 'expectedKind': 'parallel'},
    );
  }
}

// ---------------------------------------------------------------------------
// Tree helpers
// ---------------------------------------------------------------------------

/// Finds the first instruction plan in the tree that matches the given
/// [predicate].
///
/// This function performs a depth-first search through the instruction plan
/// tree, returning the first plan that satisfies the predicate.
InstructionPlan? findInstructionPlan(
  InstructionPlan instructionPlan,
  bool Function(InstructionPlan) predicate,
) {
  if (predicate(instructionPlan)) {
    return instructionPlan;
  }
  return switch (instructionPlan) {
    SingleInstructionPlan() || MessagePackerInstructionPlan() => null,
    SequentialInstructionPlan(:final plans) ||
    ParallelInstructionPlan(:final plans) => _findInPlans(plans, predicate),
  };
}

InstructionPlan? _findInPlans(
  List<InstructionPlan> plans,
  bool Function(InstructionPlan) predicate,
) {
  for (final subPlan in plans) {
    final found = findInstructionPlan(subPlan, predicate);
    if (found != null) {
      return found;
    }
  }
  return null;
}

/// Checks if every instruction plan in the tree satisfies the given
/// [predicate].
bool everyInstructionPlan(
  InstructionPlan instructionPlan,
  bool Function(InstructionPlan) predicate,
) {
  if (!predicate(instructionPlan)) {
    return false;
  }
  return switch (instructionPlan) {
    SingleInstructionPlan() || MessagePackerInstructionPlan() => true,
    SequentialInstructionPlan(:final plans) ||
    ParallelInstructionPlan(
      :final plans,
    ) => plans.every((p) => everyInstructionPlan(p, predicate)),
  };
}

/// Transforms an instruction plan tree using a bottom-up approach.
///
/// Nested plans are transformed first, then the parent plans receive
/// the already-transformed children before being transformed themselves.
InstructionPlan transformInstructionPlan(
  InstructionPlan instructionPlan,
  InstructionPlan Function(InstructionPlan) fn,
) => switch (instructionPlan) {
  SingleInstructionPlan() ||
  MessagePackerInstructionPlan() => fn(instructionPlan),
  SequentialInstructionPlan(:final plans, :final divisible) => fn(
    SequentialInstructionPlan(
      plans: List<InstructionPlan>.unmodifiable(
        plans.map((p) => transformInstructionPlan(p, fn)),
      ),
      divisible: divisible,
    ),
  ),
  ParallelInstructionPlan(:final plans) => fn(
    ParallelInstructionPlan(
      plans: List<InstructionPlan>.unmodifiable(
        plans.map((p) => transformInstructionPlan(p, fn)),
      ),
    ),
  ),
};

/// Retrieves all individual [SingleInstructionPlan] and
/// [MessagePackerInstructionPlan] instances from an instruction plan tree.
List<InstructionPlan> flattenInstructionPlan(InstructionPlan instructionPlan) =>
    switch (instructionPlan) {
      SingleInstructionPlan() ||
      MessagePackerInstructionPlan() => [instructionPlan],
      SequentialInstructionPlan(:final plans) ||
      ParallelInstructionPlan(
        :final plans,
      ) => plans.expand(flattenInstructionPlan).toList(),
    };

// ---------------------------------------------------------------------------
// Message packer factories
// ---------------------------------------------------------------------------

/// The realloc limit in bytes (10,240).
const _reallocLimit = 10240;

/// Creates a [MessagePackerInstructionPlan] that packs instructions
/// such that each instruction consumes as many bytes as possible from the
/// given [totalLength] while still being able to fit into the given
/// transaction messages.
///
/// This is particularly useful for instructions that write data to accounts
/// and must span multiple transactions due to their size limit.
MessagePackerInstructionPlan getLinearMessagePackerInstructionPlan({
  required Instruction Function(int offset, int length) getInstruction,
  required int totalLength,
}) => MessagePackerInstructionPlan(
  getMessagePacker: () {
    var offset = 0;
    return MessagePacker(
      done: () => offset >= totalLength,
      packMessageToCapacity: (TransactionMessage message) {
        if (offset >= totalLength) {
          throw SolanaError(
            SolanaErrorCode.instructionPlansMessagePackerAlreadyComplete,
          );
        }

        final messageSizeWithBaseInstruction = getTransactionMessageSize(
          appendTransactionMessageInstruction(
            getInstruction(offset, 0),
            message,
          ),
        );
        // Leeway for shortU16 numbers in transaction headers.
        final freeSpace =
            transactionSizeLimit - messageSizeWithBaseInstruction - 1;

        if (freeSpace <= 0) {
          final messageSize = getTransactionMessageSize(message);
          throw SolanaError(
            SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan,
            {
              'numBytesRequired':
                  messageSizeWithBaseInstruction - messageSize + 1,
              'numFreeBytes': transactionSizeLimit - messageSize - 1,
            },
          );
        }

        final length = math.min(totalLength - offset, freeSpace);
        final instruction = getInstruction(offset, length);
        offset += length;
        return appendTransactionMessageInstruction(instruction, message);
      },
    );
  },
);

/// Creates a [MessagePackerInstructionPlan] from a list of instructions.
///
/// This can be useful to prepare a set of instructions that can be iterated
/// over -- e.g. to pack a list of instructions that gradually reallocate
/// the size of an account one `REALLOC_LIMIT` (10,240 bytes) at a time.
MessagePackerInstructionPlan getMessagePackerInstructionPlanFromInstructions(
  List<Instruction> instructions,
) => MessagePackerInstructionPlan(
  getMessagePacker: () {
    var instructionIndex = 0;
    return MessagePacker(
      done: () => instructionIndex >= instructions.length,
      packMessageToCapacity: (TransactionMessage message) {
        if (instructionIndex >= instructions.length) {
          throw SolanaError(
            SolanaErrorCode.instructionPlansMessagePackerAlreadyComplete,
          );
        }

        final originalMessageSize = getTransactionMessageSize(message);
        var currentMessage = message;

        for (
          var index = instructionIndex;
          index < instructions.length;
          index++
        ) {
          currentMessage = appendTransactionMessageInstruction(
            instructions[index],
            currentMessage,
          );
          final messageSize = getTransactionMessageSize(currentMessage);

          if (messageSize > transactionSizeLimit) {
            if (index == instructionIndex) {
              throw SolanaError(
                SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan,
                {
                  'numBytesRequired': messageSize - originalMessageSize,
                  'numFreeBytes': transactionSizeLimit - originalMessageSize,
                },
              );
            }
            instructionIndex = index;
            return currentMessage;
          }
        }

        instructionIndex = instructions.length;
        return currentMessage;
      },
    );
  },
);

/// Creates a [MessagePackerInstructionPlan] that packs a list of realloc
/// instructions.
///
/// It splits instruction by chunks of `REALLOC_LIMIT` (10,240) bytes until
/// the given [totalSize] is reached.
MessagePackerInstructionPlan getReallocMessagePackerInstructionPlan({
  required Instruction Function(int size) getInstruction,
  required int totalSize,
}) {
  final numberOfInstructions = (totalSize + _reallocLimit - 1) ~/ _reallocLimit;
  final lastInstructionSize = totalSize % _reallocLimit;
  final instructions = List<Instruction>.generate(
    numberOfInstructions,
    (i) => getInstruction(
      i == numberOfInstructions - 1 && lastInstructionSize != 0
          ? lastInstructionSize
          : _reallocLimit,
    ),
  );

  return getMessagePackerInstructionPlanFromInstructions(instructions);
}
