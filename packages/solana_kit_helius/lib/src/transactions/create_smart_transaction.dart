import 'dart:math' as math;

import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/priority_fee/get_priority_fee_estimate.dart';
import 'package:solana_kit_helius/src/transactions/create_tx_message.dart';
import 'package:solana_kit_helius/src/transactions/get_compute_units.dart';
import 'package:solana_kit_helius/src/transactions/priority_fee.dart';
import 'package:solana_kit_helius/src/transactions/validate_tx_message.dart';
import 'package:solana_kit_helius/src/types/priority_fee_types.dart';
import 'package:solana_kit_helius/src/types/smart_transaction_types.dart';

/// The maximum compute unit limit the runtime honours, mirroring Agave.
const int maxSmartTransactionComputeUnits = 1400000;

/// A smart transaction assembled and priced by [txCreateSmartTransaction].
///
/// Upstream's `makeCreateSmartTransaction` returns a signed transaction plus the
/// metadata it discovered while building it. This port assembles and prices the
/// transaction but leaves signing to the caller: the Dart Helius client carries
/// signer *addresses* rather than signer instances, so it holds no private key
/// to sign with.
class SmartTransaction {
  /// Creates a smart transaction.
  const SmartTransaction({
    required this.blockhash,
    required this.lastValidBlockHeight,
    required this.computeUnits,
    required this.priorityFee,
    required this.priorityFeeLamports,
    required this.instructions,
    required this.version,
    required this.feePayer,
    required this.accountKeys,
  });

  /// Recent blockhash the transaction should be built against.
  final String blockhash;

  /// Last block height for which [blockhash] is valid.
  final int lastValidBlockHeight;

  /// Compute unit limit to request, including the floor and safety buffer.
  final int computeUnits;

  /// Priority fee rate in microLamports per compute unit.
  ///
  /// Legacy and version 0 transactions request this rate through a
  /// `SetComputeUnitPrice` instruction.
  final int priorityFee;

  /// Total priority fee in lamports.
  ///
  /// Version 1 transactions carry this total in their message config instead of
  /// a per-unit rate (SIMD-0385).
  final BigInt priorityFeeLamports;

  /// Instructions to include, with any compute budget instructions removed.
  ///
  /// The transaction carries the resolved limits through [computeUnits],
  /// [priorityFee], and [priorityFeeLamports] instead.
  final List<Object?> instructions;

  /// Transaction version this transaction was priced for.
  final int version;

  /// Fee payer address.
  final String feePayer;

  /// Every account the transaction references, deduplicated.
  ///
  /// Version 1 transactions are priced by account key, because the Helius fee
  /// API reads the v0 wire format and cannot interpret a v1 transaction.
  final List<String> accountKeys;
}

/// Builds a smart transaction by estimating its compute units and priority fee.
///
/// Follows upstream's order of operations:
///
/// 1. Validate before spending round trips: version 1 rejects address lookup
///    tables, and an explicit compute unit limit must be positive.
/// 2. Assemble a draft message and simulate it to estimate compute units.
/// 3. Sample the priority fee, priced by account key.
/// 4. Refresh the blockhash so the lifetime handed back is not the one the
///    simulation consumed.
///
/// Compute budget instructions supplied by the caller are stripped first,
/// because the returned [SmartTransaction] carries the resolved limits instead.
/// On version 1 a `ComputeBudgetProgram` instruction is a no-op that still
/// costs bytes and compute units (SIMD-0385); on legacy and version 0 the
/// standard price-then-limit instruction pair applies.
Future<SmartTransaction> txCreateSmartTransaction(
  JsonRpcClient rpcClient,
  CreateSmartTransactionInput input,
) async {
  const version = 0;

  final userInstructions = input.instructions
      .where((instruction) => !_isComputeBudgetInstruction(instruction))
      .toList(growable: false);

  // Fail before spending round trips on a transaction that cannot be built.
  assertNoAddressLookupsOnV1(version, userInstructions);
  _assertValidComputeUnitLimit(input.computeUnitLimit);

  final feePayer = input.feePayer ?? _firstSigner(input);

  final draft = createTxMessage(
    CreateTxMessageInput(
      version: version,
      feePayer: feePayer,
      instructions: userInstructions,
    ),
  );
  final accountKeys = _collectAccountKeys(draft.feePayer, userInstructions);

  final estimate = await txGetComputeUnits(
    rpcClient,
    CreateSmartTransactionInput(
      instructions: userInstructions,
      signers: input.signers,
      feePayer: draft.feePayer,
      computeUnitLimit: input.computeUnitLimit,
      computeUnitPrice: input.computeUnitPrice,
      lookupTableAddresses: input.lookupTableAddresses,
    ),
  );

  // An explicit limit wins over the estimate; otherwise the simulated value is
  // buffered so a transaction that under-reports still lands.
  final computeUnits =
      input.computeUnitLimit ?? bufferComputeUnits(estimate.units);

  final feeEstimate = await priorityFeeGetEstimate(
    rpcClient,
    GetPriorityFeeEstimateRequest(
      accountKeys: accountKeys,
      options: const PriorityFeeOptions(recommended: true),
    ),
  );

  final recommendedFee = feeEstimate.priorityFeeEstimate;
  if (recommendedFee == null) {
    throw StateError(
      'Priority fee estimate not available. Error creating smart transaction.',
    );
  }

  final resolvedFee = resolvePriorityFee(
    ResolvePriorityFeeInput(
      estimate: recommendedFee,
      units: computeUnits,
    ),
  );

  final latest = await rpcClient.call('getLatestBlockhash');
  final latestValue =
      (latest! as Map<String, Object?>)['value']! as Map<String, Object?>;

  return SmartTransaction(
    blockhash: latestValue['blockhash']! as String,
    lastValidBlockHeight: _toInt(latestValue['lastValidBlockHeight']),
    computeUnits: computeUnits,
    priorityFee: resolvedFee.rate,
    priorityFeeLamports: resolvedFee.lamports,
    instructions: List<Object?>.unmodifiable(userInstructions),
    version: version,
    feePayer: draft.feePayer,
    accountKeys: List<String>.unmodifiable(accountKeys),
  );
}

/// Applies a floor and percentage buffer to a raw compute unit estimate.
///
/// Mirrors upstream's `makeGetComputeUnits`: the result is never below
/// [minimum] (a literal zero budget fails on-chain) and never above the 1.4M
/// request cap the runtime enforces.
int bufferComputeUnits(
  int rawUnits, {
  int minimum = 1000,
  double bufferPercent = 0.1,
}) {
  final buffered = (rawUnits * (1 + bufferPercent)).ceil();
  return math.min(
    maxSmartTransactionComputeUnits,
    math.max(1, math.max(minimum, buffered)),
  );
}

/// The compute budget program address whose instructions are resolved into the
/// returned transaction metadata.
const _computeBudgetProgramAddress =
    'ComputeBudget111111111111111111111111111111';

/// Returns `true` when [instruction] targets the compute budget program.
bool _isComputeBudgetInstruction(Object? instruction) =>
    _programAddressOf(instruction) == _computeBudgetProgramAddress;

/// Returns the program address of [instruction] as a string, or `null` when it
/// cannot be read.
String? _programAddressOf(Object? instruction) {
  if (instruction is Map<String, Object?>) {
    return instruction['programAddress']?.toString();
  }
  try {
    return (instruction! as dynamic).programAddress?.toString();
  } on Object {
    return null;
  }
}

/// Collects the account addresses every instruction references, with the fee
/// payer first and duplicates removed, matching the `accountKeys` the fee API
/// expects.
List<String> _collectAccountKeys(
  String feePayer,
  List<Object?> instructions,
) {
  final keys = <String>[feePayer];
  final seen = <String>{feePayer};

  for (final instruction in instructions) {
    for (final address in _accountAddressesOf(instruction)) {
      if (seen.add(address)) keys.add(address);
    }
  }

  return keys;
}

/// Yields the account addresses an instruction references.
///
/// Accepts either a real `Instruction` or a structurally similar map, matching
/// how `validate_tx_message.dart` inspects instructions: a map has no
/// `accounts` getter, so it must be read by key.
Iterable<String> _accountAddressesOf(Object? instruction) sync* {
  final Object? accounts;
  if (instruction is Map<String, Object?>) {
    accounts = instruction['accounts'];
  } else {
    try {
      accounts = (instruction! as dynamic).accounts;
    } on Object {
      return;
    }
  }
  if (accounts is! List) return;

  for (final account in accounts) {
    if (account is Map<String, Object?>) {
      final address = account['address'];
      if (address != null) yield address.toString();
      continue;
    }
    try {
      final address = (account! as dynamic).address;
      if (address != null) yield address.toString();
    } on Object {
      continue;
    }
  }
}

/// Returns the first configured signer address.
String _firstSigner(CreateSmartTransactionInput input) {
  final signers = input.signers;
  if (signers == null || signers.isEmpty) {
    throw StateError(
      'createSmartTransaction: expected at least one signer or an explicit '
      'feePayer.',
    );
  }
  return signers.first;
}

/// Rejects an explicit compute unit limit that is not a positive number.
void _assertValidComputeUnitLimit(int? limit) {
  if (limit != null && limit <= 0) {
    throw StateError(
      'createSmartTransaction: computeUnitLimit must be a positive number of '
      'compute units, got $limit.',
    );
  }
}

/// Converts a JSON-RPC integer that may have been upcast to [BigInt].
int _toInt(Object? value) => switch (value) {
  final int number => number,
  final BigInt number => number.toInt(),
  final String number => int.parse(number),
  _ => throw StateError('Expected an integer for a block height, got $value'),
};
