import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_introspection/src/types.dart';

/// A single inner instruction as it appears in a `getTransaction` response
/// `meta.innerInstructions` group, before normalization.
class _RpcInnerInstruction {
  const _RpcInnerInstruction({
    required this.accounts,
    required this.data,
    required this.programIdIndex,
    required this.stackHeight,
  });

  final List<int> accounts;
  final String data;
  final int programIdIndex;
  final int? stackHeight;
}

/// A group of inner instructions returned by the JSON-RPC `getTransaction`
/// endpoint.
class _RpcInnerInstructionsGroup {
  const _RpcInnerInstructionsGroup({
    required this.index,
    required this.instructions,
  });

  final int index;
  final List<_RpcInnerInstruction> instructions;
}

/// Parses the `innerInstructions` array out of a raw `getTransaction` `meta`
/// map into the normalized group shape this helper uses.
List<_RpcInnerInstructionsGroup> _parseInnerInstructions(
  Map<String, Object?>? meta,
) {
  if (meta == null) return const [];
  final rawInner = meta['innerInstructions'];
  if (rawInner is! List) return const [];
  final groups = <_RpcInnerInstructionsGroup>[];
  for (final rawGroup in rawInner) {
    if (rawGroup is! Map) continue;
    final index = rawGroup['index'];
    final rawInstructions = rawGroup['instructions'];
    if (index is! int || rawInstructions is! List) continue;
    final instructions = <_RpcInnerInstruction>[];
    for (final rawIx in rawInstructions) {
      if (rawIx is! Map) continue;
      final programIdIndex = rawIx['programIdIndex'];
      final accountsRaw = rawIx['accounts'];
      final data = rawIx['data'];
      final stackHeight = rawIx['stackHeight'];
      if (programIdIndex is! int || data is! String) continue;
      instructions.add(
        _RpcInnerInstruction(
          accounts: accountsRaw is List
              ? accountsRaw.whereType<int>().toList()
              : const [],
          data: data,
          programIdIndex: programIdIndex,
          stackHeight: stackHeight is int ? stackHeight : null,
        ),
      );
    }
    groups.add(
      _RpcInnerInstructionsGroup(index: index, instructions: instructions),
    );
  }
  return groups;
}

/// Returns the inner instructions in a `getTransaction` response as
/// [TracedInstruction]s.
///
/// The RPC returns inner instructions in a different shape from the wire
/// format: indices reference the same flat account list as the outer
/// instructions, but `data` is a base58-encoded string. This helper decodes
/// the data, resolves the indices against the supplied [accountMetas] list, and
/// tags each instruction with an `inner` trace.
///
/// Throws a [SolanaError] if any `programIdIndex` or account index falls
/// outside the supplied [accountMetas] list.
List<TracedInstruction> getInnerInstructionsFromMeta(
  Map<String, Object?>? meta,
  List<AccountMeta> accountMetas,
) {
  final groups = _parseInnerInstructions(meta);
  final base58 = getBase58Encoder();
  final result = <TracedInstruction>[];
  for (final group in groups) {
    for (
      var innerIndex = 0;
      innerIndex < group.instructions.length;
      innerIndex++
    ) {
      final ix = group.instructions[innerIndex];
      if (ix.programIdIndex < 0 || ix.programIdIndex >= accountMetas.length) {
        throw SolanaError(
          SolanaErrorCode
              .transactionFailedToDecompileInstructionProgramAddressNotFound,
          {'index': ix.programIdIndex},
        );
      }
      final programMeta = accountMetas[ix.programIdIndex];
      final accounts = <AccountMeta>[];
      for (final i in ix.accounts) {
        if (i < 0 || i >= accountMetas.length) {
          throw SolanaError(
            SolanaErrorCode
                .transactionFailedToDecompileInstructionAccountIndexOutOfRange,
            {'index': i},
          );
        }
        accounts.add(accountMetas[i]);
      }
      final data = base58.encode(ix.data);
      result.add(
        TracedInstruction(
          programAddress: programMeta.address,
          accounts: accounts.isEmpty ? null : accounts,
          data: data.isEmpty ? null : data,
          trace: InnerInstructionTrace(
            outerIndex: group.index,
            innerIndex: innerIndex,
            stackHeight: ix.stackHeight,
          ),
        ),
      );
    }
  }
  return result;
}
