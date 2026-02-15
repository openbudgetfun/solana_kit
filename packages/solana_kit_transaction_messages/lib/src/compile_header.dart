import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/compile_accounts.dart';
import 'package:solana_kit_transaction_messages/src/compiled_transaction_message.dart';

/// Computes the [MessageHeader] from the ordered accounts.
MessageHeader getCompiledMessageHeader(List<OrderedAccount> orderedAccounts) {
  var numReadonlyNonSignerAccounts = 0;
  var numReadonlySignerAccounts = 0;
  var numSignerAccounts = 0;

  for (final account in orderedAccounts) {
    if (account.isLookupTable) break;
    final accountIsWritable = isWritableRole(account.role);
    if (isSignerRole(account.role)) {
      numSignerAccounts++;
      if (!accountIsWritable) {
        numReadonlySignerAccounts++;
      }
    } else if (!accountIsWritable) {
      numReadonlyNonSignerAccounts++;
    }
  }

  return MessageHeader(
    numSignerAccounts: numSignerAccounts,
    numReadonlySignerAccounts: numReadonlySignerAccounts,
    numReadonlyNonSignerAccounts: numReadonlyNonSignerAccounts,
  );
}
