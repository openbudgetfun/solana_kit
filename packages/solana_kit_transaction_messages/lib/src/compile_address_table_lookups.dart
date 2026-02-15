import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/compile_accounts.dart';
import 'package:solana_kit_transaction_messages/src/compiled_transaction_message.dart';

/// Extracts [AddressTableLookup] entries from the ordered accounts.
List<AddressTableLookup> getCompiledAddressTableLookups(
  List<OrderedAccount> orderedAccounts,
) {
  final index =
      <String, ({List<int> writableIndexes, List<int> readonlyIndexes})>{};

  for (final account in orderedAccounts) {
    if (!account.isLookupTable) continue;

    final key = account.lookupTableAddress!.value;
    final entry = index.putIfAbsent(
      key,
      () => (writableIndexes: <int>[], readonlyIndexes: <int>[]),
    );

    if (account.role == AccountRole.writable) {
      entry.writableIndexes.add(account.addressIndex!);
    } else {
      entry.readonlyIndexes.add(account.addressIndex!);
    }
  }

  final addressComparator = getAddressComparator();
  final keys = index.keys.toList()
    ..sort((a, b) => addressComparator(Address(a), Address(b)));

  return keys.map((key) {
    final entry = index[key]!;
    return AddressTableLookup(
      lookupTableAddress: Address(key),
      writableIndexes: entry.writableIndexes,
      readonlyIndexes: entry.readonlyIndexes,
    );
  }).toList();
}
