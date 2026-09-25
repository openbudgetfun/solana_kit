import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/addresses_by_lookup_table_address.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// Looks up the address in lookup tables, returning an [AccountLookupMeta] if
/// found.
AccountLookupMeta? _findAddressInLookupTables(
  Address address,
  AccountRole role,
  AddressesByLookupTableAddress addressesByLookupTableAddress,
) {
  for (final entry in addressesByLookupTableAddress.entries) {
    final lookupTableAddress = entry.key;
    final addresses = entry.value;
    for (var i = 0; i < addresses.length; i++) {
      if (address == addresses[i]) {
        return AccountLookupMeta(
          address: address,
          addressIndex: i,
          lookupTableAddress: lookupTableAddress,
          role: role,
        );
      }
    }
  }
  return null;
}

/// Given a transaction message and a mapping of lookup tables to the addresses
/// stored in them, this function will return a new transaction message with the
/// same instructions but with all non-signer accounts that are found in the
/// given lookup tables represented by an [AccountLookupMeta] instead of an
/// [AccountMeta].
///
/// Returns the original message if nothing changed (identity optimization).
TransactionMessage compressTransactionMessageUsingAddressLookupTables(
  TransactionMessage transactionMessage,
  AddressesByLookupTableAddress addressesByLookupTableAddress,
) {
  final programAddresses = <Address>{};
  for (final ix in transactionMessage.instructions) {
    programAddresses.add(ix.programAddress);
  }

  final eligibleLookupAddresses = <Address>{};
  for (final addresses in addressesByLookupTableAddress.values) {
    for (final address in addresses) {
      if (!programAddresses.contains(address)) {
        eligibleLookupAddresses.add(address);
      }
    }
  }

  final newInstructions = <Instruction>[];
  var updatedAnyInstructions = false;

  for (final instruction in transactionMessage.instructions) {
    if (instruction.accounts == null) {
      newInstructions.add(instruction);
      continue;
    }

    final newAccounts = <AccountMeta>[];
    var updatedAnyAccounts = false;

    for (final account in instruction.accounts!) {
      // If the account is already a lookup, is not in any lookup tables,
      // or is a signer role, keep it as-is.
      if (account is AccountLookupMeta ||
          !eligibleLookupAddresses.contains(account.address) ||
          isSignerRole(account.role)) {
        newAccounts.add(account);
        continue;
      }

      final lookupMetaAccount = _findAddressInLookupTables(
        account.address,
        account.role,
        addressesByLookupTableAddress,
      );
      if (lookupMetaAccount != null) {
        newAccounts.add(lookupMetaAccount);
        updatedAnyAccounts = true;
        updatedAnyInstructions = true;
      } else {
        newAccounts.add(account);
      }
    }

    if (updatedAnyAccounts) {
      newInstructions.add(
        Instruction(
          programAddress: instruction.programAddress,
          accounts: List<AccountMeta>.unmodifiable(newAccounts),
          data: instruction.data,
        ),
      );
    } else {
      newInstructions.add(instruction);
    }
  }

  if (updatedAnyInstructions) {
    return transactionMessage.copyWith(
      instructions: List<Instruction>.unmodifiable(newInstructions),
    );
  }
  return transactionMessage;
}
