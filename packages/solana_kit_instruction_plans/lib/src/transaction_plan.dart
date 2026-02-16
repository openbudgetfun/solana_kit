import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

/// A set of transaction messages with constraints on how they can be executed.
///
/// This is structured as a recursive tree of plans to allow for
/// parallel execution, sequential execution and combinations of both.
sealed class TransactionPlan {
  /// Creates a [TransactionPlan].
  const TransactionPlan();

  /// The kind discriminator for this transaction plan.
  String get kind;
}

/// A plan that contains a single transaction message.
class SingleTransactionPlan extends TransactionPlan {
  /// Creates a [SingleTransactionPlan] wrapping the given [message].
  const SingleTransactionPlan({required this.message});

  /// The transaction message contained in this plan.
  final TransactionMessage message;

  @override
  String get kind => 'single';
}

/// A plan wrapping other plans that must be executed sequentially.
///
/// It also defines whether nested plans are [divisible] -- meaning that
/// the transaction messages inside them can be split into separate batches.
/// When [divisible] is `false`, the transaction messages inside the plan
/// should all be executed atomically -- usually in a transaction bundle.
class SequentialTransactionPlan extends TransactionPlan {
  /// Creates a [SequentialTransactionPlan] with the given [plans] and
  /// [divisible] flag.
  const SequentialTransactionPlan({required this.plans, this.divisible = true});

  /// The nested plans that must be executed sequentially.
  final List<TransactionPlan> plans;

  /// Whether the transaction messages inside this plan can be split into
  /// separate batches.
  final bool divisible;

  @override
  String get kind => 'sequential';
}

/// A plan wrapping other plans that can be executed in parallel.
class ParallelTransactionPlan extends TransactionPlan {
  /// Creates a [ParallelTransactionPlan] with the given [plans].
  const ParallelTransactionPlan({required this.plans});

  /// The nested plans that can be executed in parallel.
  final List<TransactionPlan> plans;

  @override
  String get kind => 'parallel';
}

// ---------------------------------------------------------------------------
// Constructor helpers
// ---------------------------------------------------------------------------

List<TransactionPlan> _parseSingleTransactionPlans(List<Object> plans) =>
    List<TransactionPlan>.unmodifiable(
      plans.map(
        (plan) => plan is TransactionPlan
            ? plan
            : SingleTransactionPlan(message: plan as TransactionMessage),
      ),
    );

/// Creates a [SingleTransactionPlan] from a [TransactionMessage].
SingleTransactionPlan singleTransactionPlan(TransactionMessage message) =>
    SingleTransactionPlan(message: message);

/// Creates a divisible [SequentialTransactionPlan] from an array of nested
/// plans.
///
/// It can accept [TransactionMessage] objects directly, which will be
/// wrapped in [SingleTransactionPlan]s automatically.
SequentialTransactionPlan sequentialTransactionPlan(List<Object> plans) =>
    SequentialTransactionPlan(plans: _parseSingleTransactionPlans(plans));

/// Creates a non-divisible [SequentialTransactionPlan] from an array of
/// nested plans.
///
/// It can accept [TransactionMessage] objects directly, which will be
/// wrapped in [SingleTransactionPlan]s automatically.
SequentialTransactionPlan nonDivisibleSequentialTransactionPlan(
  List<Object> plans,
) => SequentialTransactionPlan(
  plans: _parseSingleTransactionPlans(plans),
  divisible: false,
);

/// Creates a [ParallelTransactionPlan] from an array of nested plans.
///
/// It can accept [TransactionMessage] objects directly, which will be
/// wrapped in [SingleTransactionPlan]s automatically.
ParallelTransactionPlan parallelTransactionPlan(List<Object> plans) =>
    ParallelTransactionPlan(plans: _parseSingleTransactionPlans(plans));

// ---------------------------------------------------------------------------
// Type checks and assertions
// ---------------------------------------------------------------------------

/// Returns `true` if [value] is a [TransactionPlan].
bool isTransactionPlan(Object? value) => value is TransactionPlan;

/// Returns `true` if [plan] is a [SingleTransactionPlan].
bool isSingleTransactionPlan(TransactionPlan plan) =>
    plan is SingleTransactionPlan;

/// Asserts that [plan] is a [SingleTransactionPlan].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansUnexpectedTransactionPlan] if the plan
/// is not a single transaction plan.
void assertIsSingleTransactionPlan(TransactionPlan plan) {
  if (plan is! SingleTransactionPlan) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedTransactionPlan,
      {'actualKind': plan.kind, 'expectedKind': 'single'},
    );
  }
}

/// Returns `true` if [plan] is a [SequentialTransactionPlan].
bool isSequentialTransactionPlan(TransactionPlan plan) =>
    plan is SequentialTransactionPlan;

/// Asserts that [plan] is a [SequentialTransactionPlan].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansUnexpectedTransactionPlan] if the plan
/// is not a sequential transaction plan.
void assertIsSequentialTransactionPlan(TransactionPlan plan) {
  if (plan is! SequentialTransactionPlan) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedTransactionPlan,
      {'actualKind': plan.kind, 'expectedKind': 'sequential'},
    );
  }
}

/// Returns `true` if [plan] is a non-divisible [SequentialTransactionPlan].
bool isNonDivisibleSequentialTransactionPlan(TransactionPlan plan) =>
    plan is SequentialTransactionPlan && !plan.divisible;

/// Asserts that [plan] is a non-divisible [SequentialTransactionPlan].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansUnexpectedTransactionPlan] if the plan
/// is not a non-divisible sequential transaction plan.
void assertIsNonDivisibleSequentialTransactionPlan(TransactionPlan plan) {
  if (plan is! SequentialTransactionPlan || plan.divisible) {
    final actualKind = plan is SequentialTransactionPlan && plan.divisible
        ? 'divisible sequential'
        : plan.kind;
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedTransactionPlan,
      {'actualKind': actualKind, 'expectedKind': 'non-divisible sequential'},
    );
  }
}

/// Returns `true` if [plan] is a [ParallelTransactionPlan].
bool isParallelTransactionPlan(TransactionPlan plan) =>
    plan is ParallelTransactionPlan;

/// Asserts that [plan] is a [ParallelTransactionPlan].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansUnexpectedTransactionPlan] if the plan
/// is not a parallel transaction plan.
void assertIsParallelTransactionPlan(TransactionPlan plan) {
  if (plan is! ParallelTransactionPlan) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansUnexpectedTransactionPlan,
      {'actualKind': plan.kind, 'expectedKind': 'parallel'},
    );
  }
}

// ---------------------------------------------------------------------------
// Tree helpers
// ---------------------------------------------------------------------------

/// Retrieves all individual [SingleTransactionPlan] instances from a
/// transaction plan tree.
List<SingleTransactionPlan> flattenTransactionPlan(
  TransactionPlan transactionPlan,
) => switch (transactionPlan) {
  SingleTransactionPlan() => [transactionPlan],
  SequentialTransactionPlan(:final plans) ||
  ParallelTransactionPlan(
    :final plans,
  ) => plans.expand(flattenTransactionPlan).toList(),
};

/// Finds the first transaction plan in the tree that matches the given
/// [predicate].
TransactionPlan? findTransactionPlan(
  TransactionPlan transactionPlan,
  bool Function(TransactionPlan) predicate,
) {
  if (predicate(transactionPlan)) {
    return transactionPlan;
  }
  return switch (transactionPlan) {
    SingleTransactionPlan() => null,
    SequentialTransactionPlan(:final plans) ||
    ParallelTransactionPlan(
      :final plans,
    ) => _findInTransactionPlans(plans, predicate),
  };
}

TransactionPlan? _findInTransactionPlans(
  List<TransactionPlan> plans,
  bool Function(TransactionPlan) predicate,
) {
  for (final subPlan in plans) {
    final found = findTransactionPlan(subPlan, predicate);
    if (found != null) {
      return found;
    }
  }
  return null;
}

/// Checks if every transaction plan in the tree satisfies the given
/// [predicate].
bool everyTransactionPlan(
  TransactionPlan transactionPlan,
  bool Function(TransactionPlan) predicate,
) {
  if (!predicate(transactionPlan)) {
    return false;
  }
  return switch (transactionPlan) {
    SingleTransactionPlan() => true,
    SequentialTransactionPlan(:final plans) ||
    ParallelTransactionPlan(
      :final plans,
    ) => plans.every((p) => everyTransactionPlan(p, predicate)),
  };
}

/// Transforms a transaction plan tree using a bottom-up approach.
TransactionPlan transformTransactionPlan(
  TransactionPlan transactionPlan,
  TransactionPlan Function(TransactionPlan) fn,
) => switch (transactionPlan) {
  SingleTransactionPlan() => fn(transactionPlan),
  SequentialTransactionPlan(:final plans, :final divisible) => fn(
    SequentialTransactionPlan(
      plans: List<TransactionPlan>.unmodifiable(
        plans.map((p) => transformTransactionPlan(p, fn)),
      ),
      divisible: divisible,
    ),
  ),
  ParallelTransactionPlan(:final plans) => fn(
    ParallelTransactionPlan(
      plans: List<TransactionPlan>.unmodifiable(
        plans.map((p) => transformTransactionPlan(p, fn)),
      ),
    ),
  ),
};
