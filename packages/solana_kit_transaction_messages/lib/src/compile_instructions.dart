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
