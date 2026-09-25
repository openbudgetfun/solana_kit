import 'dart:typed_data';

import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/compile_accounts.dart';
import 'package:solana_kit_transaction_messages/src/compiled_transaction_message.dart';

Map<String, int> _getAccountIndex(List<OrderedAccount> orderedAccounts) {
  final out = <String, int>{};
  for (var i = 0; i < orderedAccounts.length; i++) {
    out[orderedAccounts[i].address.value] = i;
  }
  return out;
}

/// Returns an address-to-index lookup for [orderedAccounts].
Map<String, int> getAccountIndex(List<OrderedAccount> orderedAccounts) =>
    _getAccountIndex(orderedAccounts);

/// Compiles instructions into [CompiledInstruction] list using the ordered
/// accounts.
List<CompiledInstruction> getCompiledInstructions(
  List<Instruction> instructions,
  List<OrderedAccount> orderedAccounts,
) {
  final accountIndex = _getAccountIndex(orderedAccounts);
  return instructions.map((instruction) {
    final accounts = instruction.accounts;
    final data = instruction.data;
    return CompiledInstruction(
      programAddressIndex: accountIndex[instruction.programAddress.value]!,
      accountIndices: accounts
          ?.map((a) => accountIndex[a.address.value]!)
          .toList(),
      data: data,
    );
  }).toList();
}

/// Returns a v1 instruction header for [instruction].
V1InstructionHeader getInstructionHeader(
  Instruction instruction,
  Map<String, int> accountIndex,
) {
  final accounts = instruction.accounts;
  final data = instruction.data;
  return V1InstructionHeader(
    programAccountIndex: accountIndex[instruction.programAddress.value]!,
    numInstructionAccounts: accounts?.length ?? 0,
    numInstructionDataBytes: data?.length ?? 0,
  );
}

/// Returns a v1 instruction payload for [instruction].
V1InstructionPayload getInstructionPayload(
  Instruction instruction,
  Map<String, int> accountIndex,
) {
  return V1InstructionPayload(
    instructionAccountIndices:
        instruction.accounts
            ?.map((account) => accountIndex[account.address.value]!)
            .toList() ??
        const <int>[],
    instructionData: instruction.data ?? Uint8List(0),
  );
}
