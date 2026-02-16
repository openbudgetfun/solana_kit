import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instruction_plans/src/instruction_plan.dart';
import 'package:solana_kit_instruction_plans/src/transaction_plan.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Plans one or more transactions according to the provided instruction plan.
typedef TransactionPlanner =
    Future<TransactionPlan> Function(InstructionPlan instructionPlan);

/// A function that creates a new transaction message.
typedef CreateTransactionMessage = Future<TransactionMessage> Function();

/// A function called whenever a transaction message is updated.
typedef OnTransactionMessageUpdated =
    Future<TransactionMessage> Function(TransactionMessage message);

/// Configuration object for creating a new transaction planner.
class TransactionPlannerConfig {
  /// Creates a [TransactionPlannerConfig].
  const TransactionPlannerConfig({
    required this.createTransactionMessage,
    this.onTransactionMessageUpdated,
  });

  /// Called whenever a new transaction message is needed.
  final CreateTransactionMessage createTransactionMessage;

  /// Called whenever a transaction message is updated.
  final OnTransactionMessageUpdated? onTransactionMessageUpdated;
}

/// Creates a new transaction planner based on the provided configuration.
///
/// At the very least, the [TransactionPlannerConfig.createTransactionMessage]
/// function must be provided.
TransactionPlanner createTransactionPlanner(TransactionPlannerConfig config) {
  return (InstructionPlan instructionPlan) async {
    final plan = await _traverse(
      instructionPlan,
      _TraverseContext(
        createTransactionMessage: config.createTransactionMessage,
        onTransactionMessageUpdated:
            config.onTransactionMessageUpdated ?? (msg) async => msg,
        parent: null,
        parentCandidates: [],
      ),
    );

    if (plan == null) {
      throw SolanaError(SolanaErrorCode.instructionPlansEmptyInstructionPlan);
    }

    return _freezeTransactionPlan(plan);
  };
}

class _MutableSingleTransactionPlan {
  _MutableSingleTransactionPlan({required this.message});
  TransactionMessage message;
}

class _TraverseContext {
  _TraverseContext({
    required this.createTransactionMessage,
    required this.onTransactionMessageUpdated,
    required this.parent,
    required this.parentCandidates,
  });

  final CreateTransactionMessage createTransactionMessage;
  final OnTransactionMessageUpdated onTransactionMessageUpdated;
  final InstructionPlan? parent;
  final List<_MutableSingleTransactionPlan> parentCandidates;
}

sealed class _MutableTransactionPlan {}

class _MutableSingle extends _MutableTransactionPlan {
  _MutableSingle({required this.candidate});
  final _MutableSingleTransactionPlan candidate;
}

class _MutableSequential extends _MutableTransactionPlan {
  _MutableSequential({required this.plans, required this.divisible});
  final List<_MutableTransactionPlan> plans;
  final bool divisible;
}

class _MutableParallel extends _MutableTransactionPlan {
  _MutableParallel({required this.plans});
  final List<_MutableTransactionPlan> plans;
}

Future<_MutableTransactionPlan?> _traverse(
  InstructionPlan instructionPlan,
  _TraverseContext context,
) async {
  switch (instructionPlan) {
    case SequentialInstructionPlan():
      return _traverseSequential(instructionPlan, context);
    case ParallelInstructionPlan():
      return _traverseParallel(instructionPlan, context);
    case SingleInstructionPlan():
      return _traverseSingle(instructionPlan, context);
    case MessagePackerInstructionPlan():
      return _traverseMessagePacker(instructionPlan, context);
  }
}

Future<_MutableTransactionPlan?> _traverseSequential(
  SequentialInstructionPlan instructionPlan,
  _TraverseContext context,
) async {
  _MutableSingleTransactionPlan? candidate;

  // Check if the sequential plan must fit entirely in its parent candidates
  // due to constraints like being inside a parallel plan or not being
  // divisible.
  final mustEntirelyFitInParentCandidate =
      context.parent != null &&
      (context.parent is ParallelInstructionPlan || !instructionPlan.divisible);

  if (mustEntirelyFitInParentCandidate) {
    final selectedCandidate = await _selectAndMutateCandidate(
      context,
      context.parentCandidates,
      (message) => _fitEntirePlanInsideMessage(instructionPlan, message),
    );
    if (selectedCandidate != null) {
      return null;
    }
  } else {
    candidate = context.parentCandidates.isNotEmpty
        ? context.parentCandidates[0]
        : null;
  }

  final transactionPlans = <_MutableTransactionPlan>[];
  for (final plan in instructionPlan.plans) {
    final transactionPlan = await _traverse(
      plan,
      _TraverseContext(
        createTransactionMessage: context.createTransactionMessage,
        onTransactionMessageUpdated: context.onTransactionMessageUpdated,
        parent: instructionPlan,
        parentCandidates: candidate != null ? [candidate] : [],
      ),
    );
    if (transactionPlan != null) {
      candidate = _getSequentialCandidate(transactionPlan);
      final isFlattened =
          transactionPlan is _MutableSequential &&
          (transactionPlan.divisible || !instructionPlan.divisible);
      if (isFlattened) {
        transactionPlans.addAll(transactionPlan.plans);
      } else {
        transactionPlans.add(transactionPlan);
      }
    }
  }

  if (transactionPlans.length == 1) {
    return transactionPlans[0];
  }
  if (transactionPlans.isEmpty) {
    return null;
  }
  return _MutableSequential(
    plans: transactionPlans,
    divisible: instructionPlan.divisible,
  );
}

Future<_MutableTransactionPlan?> _traverseParallel(
  ParallelInstructionPlan instructionPlan,
  _TraverseContext context,
) async {
  final candidates = <_MutableSingleTransactionPlan>[
    ...context.parentCandidates,
  ];
  final transactionPlans = <_MutableTransactionPlan>[];

  // Reorder children so message packer plans are last.
  final sortedChildren = List<InstructionPlan>.from(instructionPlan.plans)
    ..sort(
      (a, b) =>
          (a is MessagePackerInstructionPlan ? 1 : 0) -
          (b is MessagePackerInstructionPlan ? 1 : 0),
    );

  for (final plan in sortedChildren) {
    final transactionPlan = await _traverse(
      plan,
      _TraverseContext(
        createTransactionMessage: context.createTransactionMessage,
        onTransactionMessageUpdated: context.onTransactionMessageUpdated,
        parent: instructionPlan,
        parentCandidates: candidates,
      ),
    );
    if (transactionPlan != null) {
      candidates.addAll(_getParallelCandidates(transactionPlan));
      if (transactionPlan is _MutableParallel) {
        transactionPlans.addAll(transactionPlan.plans);
      } else {
        transactionPlans.add(transactionPlan);
      }
    }
  }

  if (transactionPlans.length == 1) {
    return transactionPlans[0];
  }
  if (transactionPlans.isEmpty) {
    return null;
  }
  return _MutableParallel(plans: transactionPlans);
}

Future<_MutableTransactionPlan?> _traverseSingle(
  SingleInstructionPlan instructionPlan,
  _TraverseContext context,
) async {
  TransactionMessage predicate(TransactionMessage message) =>
      appendTransactionMessageInstructions([
        instructionPlan.instruction,
      ], message);

  final candidate = await _selectAndMutateCandidate(
    context,
    context.parentCandidates,
    predicate,
  );
  if (candidate != null) {
    return null;
  }
  final message = await _createNewMessage(context, predicate);
  return _MutableSingle(
    candidate: _MutableSingleTransactionPlan(message: message),
  );
}

Future<_MutableTransactionPlan?> _traverseMessagePacker(
  MessagePackerInstructionPlan instructionPlan,
  _TraverseContext context,
) async {
  final messagePacker = instructionPlan.getMessagePacker();
  final transactionPlans = <_MutableSingle>[];
  final candidates = <_MutableSingleTransactionPlan>[
    ...context.parentCandidates,
  ];

  while (!messagePacker.done()) {
    final candidate = await _selectAndMutateCandidate(
      context,
      candidates,
      messagePacker.packMessageToCapacity,
    );
    if (candidate == null) {
      final message = await _createNewMessage(
        context,
        messagePacker.packMessageToCapacity,
      );
      final newCandidate = _MutableSingleTransactionPlan(message: message);
      final newPlan = _MutableSingle(candidate: newCandidate);
      transactionPlans.add(newPlan);
    }
  }

  if (transactionPlans.length == 1) {
    return transactionPlans[0];
  }
  if (transactionPlans.isEmpty) {
    return null;
  }
  if (context.parent is ParallelInstructionPlan) {
    return _MutableParallel(plans: transactionPlans);
  }
  return _MutableSequential(
    plans: transactionPlans,
    divisible:
        context.parent is! SequentialInstructionPlan ||
        (context.parent! as SequentialInstructionPlan).divisible,
  );
}

_MutableSingleTransactionPlan? _getSequentialCandidate(
  _MutableTransactionPlan latestPlan,
) {
  if (latestPlan is _MutableSingle) {
    return latestPlan.candidate;
  }
  if (latestPlan is _MutableSequential && latestPlan.plans.isNotEmpty) {
    return _getSequentialCandidate(
      latestPlan.plans[latestPlan.plans.length - 1],
    );
  }
  return null;
}

List<_MutableSingleTransactionPlan> _getParallelCandidates(
  _MutableTransactionPlan latestPlan,
) {
  if (latestPlan is _MutableSingle) {
    return [latestPlan.candidate];
  }
  if (latestPlan is _MutableSequential) {
    return latestPlan.plans.expand(_getParallelCandidates).toList();
  }
  if (latestPlan is _MutableParallel) {
    return latestPlan.plans.expand(_getParallelCandidates).toList();
  }
  return [];
}

Future<_MutableSingleTransactionPlan?> _selectAndMutateCandidate(
  _TraverseContext context,
  List<_MutableSingleTransactionPlan> candidates,
  TransactionMessage Function(TransactionMessage) predicate,
) async {
  for (final candidate in candidates) {
    try {
      final updatedMessage = predicate(candidate.message);
      final message = await context.onTransactionMessageUpdated(updatedMessage);
      if (getTransactionMessageSize(message) <= transactionSizeLimit) {
        candidate.message = message;
        return candidate;
      }
    } on Object catch (error) {
      if (isSolanaError(
        error,
        SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan,
      )) {
        // Try the next candidate.
        continue;
      }
      rethrow;
    }
  }
  return null;
}

Future<TransactionMessage> _createNewMessage(
  _TraverseContext context,
  TransactionMessage Function(TransactionMessage) predicate,
) async {
  final newMessage = await context.createTransactionMessage();
  final updatedMessage = await context.onTransactionMessageUpdated(
    predicate(newMessage),
  );
  final updatedMessageSize = getTransactionMessageSize(updatedMessage);
  if (updatedMessageSize > transactionSizeLimit) {
    final newMessageSize = getTransactionMessageSize(newMessage);
    throw SolanaError(
      SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan,
      {
        'numBytesRequired': updatedMessageSize - newMessageSize,
        'numFreeBytes': transactionSizeLimit - newMessageSize,
      },
    );
  }
  return updatedMessage;
}

TransactionPlan _freezeTransactionPlan(_MutableTransactionPlan plan) {
  switch (plan) {
    case _MutableSingle(:final candidate):
      return singleTransactionPlan(candidate.message);
    case _MutableSequential(:final plans, :final divisible):
      final frozenPlans = plans.map(_freezeTransactionPlan).toList();
      return divisible
          ? sequentialTransactionPlan(frozenPlans)
          : nonDivisibleSequentialTransactionPlan(frozenPlans);
    case _MutableParallel(:final plans):
      return parallelTransactionPlan(
        plans.map(_freezeTransactionPlan).toList(),
      );
  }
}

TransactionMessage _fitEntirePlanInsideMessage(
  InstructionPlan instructionPlan,
  TransactionMessage message,
) {
  switch (instructionPlan) {
    case SequentialInstructionPlan(:final plans):
    case ParallelInstructionPlan(:final plans):
      var newMessage = message;
      for (final plan in plans) {
        newMessage = _fitEntirePlanInsideMessage(plan, newMessage);
      }
      return newMessage;
    case SingleInstructionPlan(:final instruction):
      final newMessage = appendTransactionMessageInstructions([
        instruction,
      ], message);
      final newMessageSize = getTransactionMessageSize(newMessage);
      if (newMessageSize > transactionSizeLimit) {
        final baseMessageSize = getTransactionMessageSize(message);
        throw SolanaError(
          SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan,
          {
            'numBytesRequired': newMessageSize - baseMessageSize,
            'numFreeBytes': transactionSizeLimit - baseMessageSize,
          },
        );
      }
      return newMessage;
    case MessagePackerInstructionPlan(:final getMessagePacker):
      final packer = getMessagePacker();
      var newMessage = message;
      while (!packer.done()) {
        newMessage = packer.packMessageToCapacity(newMessage);
      }
      return newMessage;
  }
}
