import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/compute_unit_limit.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/v1_transaction_config.dart';

/// A provisional loaded accounts data size limit used as a placeholder before
/// estimation.
const provisoryLoadedAccountsDataSizeLimit = 0;

const _setLoadedAccountsDataSizeLimitDiscriminator = 4;

/// An estimate of the resource limits for a transaction message.
class ResourceLimitsEstimate {
  /// Creates a new [ResourceLimitsEstimate].
  const ResourceLimitsEstimate({
    required this.computeUnitLimit,
    this.loadedAccountsDataSizeLimit,
  });

  /// The estimated compute unit limit.
  final int computeUnitLimit;

  /// The estimated loaded accounts data size limit, if available.
  ///
  /// Required for version 1 messages; optional for legacy/v0 messages when the
  /// RPC returns it.
  final int? loadedAccountsDataSizeLimit;
}

/// A function that estimates the resource limits for [transactionMessage].
typedef EstimateResourceLimits =
    Future<ResourceLimitsEstimate> Function(
      TransactionMessage transactionMessage,
    );

/// Returns the loaded accounts data size limit set on [transactionMessage], if
/// any.
int? getTransactionMessageLoadedAccountsDataSizeLimit(
  TransactionMessage transactionMessage,
) {
  if (transactionMessage.version == TransactionVersion.v1) {
    return transactionMessage.config?.loadedAccountsDataSizeLimit;
  }

  final instruction = transactionMessage.instructions
      .where(_isSetLoadedAccountsDataSizeLimitInstruction)
      .firstOrNull;
  if (instruction == null) return null;
  return _parseLoadedAccountsDataSizeLimitInstruction(instruction);
}

/// Sets or removes the loaded accounts data size limit on [transactionMessage].
///
/// For legacy and v0 messages this appends a Compute Budget
/// `SetLoadedAccountsDataSizeLimit` instruction, replaces the first existing
/// one, or removes the first existing one when [limit] is `null`.
TransactionMessage setTransactionMessageLoadedAccountsDataSizeLimit(
  int? limit,
  TransactionMessage transactionMessage,
) {
  if (transactionMessage.version == TransactionVersion.v1) {
    final nextConfig = limit == null
        ? transactionMessage.config?.copyWith(
            clearLoadedAccountsDataSizeLimit: true,
          )
        : setTransactionMessageConfig(
            V1TransactionConfig(loadedAccountsDataSizeLimit: limit),
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

  final existingIndex = transactionMessage.instructions.indexWhere(
    _isSetLoadedAccountsDataSizeLimitInstruction,
  );

  if (limit == null) {
    if (existingIndex == -1) return transactionMessage;
    return transactionMessage.copyWith(
      instructions: _withoutInstructionAt(
        transactionMessage.instructions,
        existingIndex,
      ),
    );
  }

  if (getTransactionMessageLoadedAccountsDataSizeLimit(transactionMessage) ==
      limit) {
    return transactionMessage;
  }

  final instruction = _getSetLoadedAccountsDataSizeLimitInstruction(
    limit: limit,
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

/// Returns [transactionMessage] with provisional compute unit and loaded
/// accounts data size limits if none are already present.
TransactionMessage fillTransactionMessageProvisoryResourceLimits(
  TransactionMessage transactionMessage,
) {
  var message = fillTransactionMessageProvisoryComputeUnitLimit(
    transactionMessage,
  );

  if (getTransactionMessageLoadedAccountsDataSizeLimit(message) != null) {
    return message;
  }

  if (message.version == TransactionVersion.v1) {
    message = setTransactionMessageLoadedAccountsDataSizeLimit(
      provisoryLoadedAccountsDataSizeLimit,
      message,
    );
  }

  return message;
}

/// Returns a function that estimates the resource limits for a transaction
/// message by simulating it via [estimateResourceLimits].
///
/// This factory wraps an [EstimateResourceLimits] function and returns a new
/// function that produces a [ResourceLimitsEstimate] for any given
/// [TransactionMessage].
EstimateResourceLimits estimateResourceLimitsFactory(
  EstimateResourceLimits estimateResourceLimits,
) {
  return estimateResourceLimits;
}

/// Returns a function that estimates and sets the resource limits on a
/// transaction message.
///
/// Existing non-provisional limits are preserved. Provisional limits (`0`) are
/// replaced with estimates.
Future<TransactionMessage> Function(TransactionMessage transactionMessage)
estimateAndSetResourceLimitsFactory(
  EstimateResourceLimits estimateResourceLimits,
) {
  return (transactionMessage) async {
    final existingComputeLimit = getTransactionMessageComputeUnitLimit(
      transactionMessage,
    );
    final existingLoadedAccountsLimit =
        getTransactionMessageLoadedAccountsDataSizeLimit(transactionMessage);

    final needsComputeEstimate =
        existingComputeLimit == null ||
        existingComputeLimit == provisoryComputeUnitLimit ||
        existingComputeLimit == maxComputeUnitLimit;
    final needsLoadedAccountsEstimate =
        existingLoadedAccountsLimit == null ||
        existingLoadedAccountsLimit == provisoryLoadedAccountsDataSizeLimit;

    if (!needsComputeEstimate && !needsLoadedAccountsEstimate) {
      return transactionMessage;
    }

    final estimate = await estimateResourceLimits(transactionMessage);

    var message = transactionMessage;
    if (needsComputeEstimate) {
      message = setTransactionMessageComputeUnitLimit(
        estimate.computeUnitLimit,
        message,
      );
    }

    if (needsLoadedAccountsEstimate &&
        estimate.loadedAccountsDataSizeLimit != null) {
      message = setTransactionMessageLoadedAccountsDataSizeLimit(
        estimate.loadedAccountsDataSizeLimit,
        message,
      );
    }

    return message;
  };
}

Instruction _getSetLoadedAccountsDataSizeLimitInstruction({
  required int limit,
}) {
  final data = Uint8List(5)
    ..first = _setLoadedAccountsDataSizeLimitDiscriminator;
  ByteData.sublistView(data).setUint32(1, limit, Endian.little);
  return Instruction(
    programAddress: computeBudgetProgramAddress,
    accounts: const [],
    data: data,
  );
}

bool _isSetLoadedAccountsDataSizeLimitInstruction(Instruction instruction) {
  if (instruction.programAddress != computeBudgetProgramAddress) return false;
  final data = instruction.data;
  return data != null &&
      data.length >= 5 &&
      data.first == _setLoadedAccountsDataSizeLimitDiscriminator;
}

int _parseLoadedAccountsDataSizeLimitInstruction(Instruction instruction) {
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
