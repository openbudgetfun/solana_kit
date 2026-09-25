import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_introspection/src/get_inner_instructions.dart';
import 'package:solana_kit_transaction_introspection/src/get_instructions.dart';
import 'package:solana_kit_transaction_introspection/src/loaded_addresses.dart';
import 'package:solana_kit_transaction_introspection/src/types.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

/// Returns every instruction in a confirmed transaction as
/// [TracedInstruction]s, in the order an explorer displays them: each outer
/// instruction followed immediately by the inner instructions its CPIs
/// produced.
///
/// Each returned instruction has its account indices resolved to
/// `AccountMeta`s and its data exposed as a `Uint8List` (omitted when empty),
/// making it directly usable with the auto-generated
/// `@solana-program/*` `identifyXInstruction` and `parseXInstruction`
/// functions, and with `isInstructionForProgram` from
/// `solana_kit_instructions`.
///
/// If [meta] is `null`, only outer instructions are returned. If
/// [loadedAddresses] is `null`, only static accounts are used to resolve
/// indices; pass `meta['loadedAddresses']` for v0 transactions that load
/// accounts from address lookup tables.
List<TracedInstruction> walkInstructions({
  required CompiledTransactionMessage compiledMessage,
  LoadedAddresses? loadedAddresses,
  Map<String, Object?>? meta,
}) {
  final accountMetas = getAccountMetasFromCompiledTransactionMessage(
    compiledMessage,
    loadedAddresses: loadedAddresses,
  );
  final outerInstructions =
      getInstructionsFromCompiledTransactionMessageWithMetas(
        compiledMessage,
        accountMetas,
      );

  final innerByOuterIndex = <int, List<TracedInstruction>>{};
  if (meta != null) {
    for (final inner in getInnerInstructionsFromMeta(meta, accountMetas)) {
      final trace = inner.trace;
      if (trace is! InnerInstructionTrace) continue;
      final group = innerByOuterIndex[trace.outerIndex];
      if (group != null) {
        group.add(inner);
      } else {
        innerByOuterIndex[trace.outerIndex] = [inner];
      }
    }
  }

  final result = <TracedInstruction>[];
  for (var index = 0; index < outerInstructions.length; index++) {
    final instruction = outerInstructions[index];
    result.add(
      TracedInstruction(
        programAddress: instruction.programAddress,
        accounts: instruction.accounts,
        data: instruction.data,
        trace: OuterInstructionTrace(index: index),
      ),
    );
    final group = innerByOuterIndex.remove(index);
    if (group != null) {
      result.addAll(group);
    }
  }
  // An unmatched group means `meta` is malformed or belongs to another
  // transaction. Fail closed instead of presenting those CPIs as if they were
  // associated with this message.
  if (innerByOuterIndex.isNotEmpty) {
    throw SolanaError(
      SolanaErrorCode
          .transactionIntrospectionUnrecognizedGetTransactionResponse,
    );
  }
  return result;
}
