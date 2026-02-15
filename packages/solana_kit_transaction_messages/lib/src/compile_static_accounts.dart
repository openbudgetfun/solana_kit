import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_transaction_messages/src/compile_accounts.dart';

/// Extracts the static (non-lookup) accounts from the ordered accounts.
List<Address> getCompiledStaticAccounts(List<OrderedAccount> orderedAccounts) {
  final firstLookupIndex = orderedAccounts.indexWhere((a) => a.isLookupTable);
  final staticAccounts = firstLookupIndex == -1
      ? orderedAccounts
      : orderedAccounts.sublist(0, firstLookupIndex);
  return staticAccounts.map((a) => a.address).toList();
}
