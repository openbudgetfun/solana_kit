import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_instructions/src/roles.dart';

/// Represents an account's address and metadata about its mutability and
/// whether it must be a signer of the transaction.
class AccountMeta {
  /// Creates an [AccountMeta] with the given [address] and [role].
  const AccountMeta({required this.address, required this.role});

  /// The base58-encoded address of the account.
  final Address address;

  /// The role of the account in the transaction.
  final AccountRole role;
}

/// Represents a lookup of the account's address in an address lookup table.
///
/// It specifies which lookup table account in which to perform the lookup, the
/// index of the desired account address in that table, and metadata about its
/// mutability. Notably, account addresses obtained via lookups may not act as
/// signers.
///
/// Extends [AccountMeta] so that it can be used anywhere an [AccountMeta] is
/// expected (e.g., in an instruction's accounts list).
class AccountLookupMeta extends AccountMeta {
  /// Creates an [AccountLookupMeta].
  const AccountLookupMeta({
    required super.address,
    required this.addressIndex,
    required this.lookupTableAddress,
    required super.role,
  });

  /// The index of the account address within the lookup table.
  final int addressIndex;

  /// The base58-encoded address of the lookup table account.
  final Address lookupTableAddress;
}
