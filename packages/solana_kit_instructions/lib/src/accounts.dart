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
class AccountLookupMeta {
  /// Creates an [AccountLookupMeta].
  const AccountLookupMeta({
    required this.address,
    required this.addressIndex,
    required this.lookupTableAddress,
    required this.role,
  });

  /// The base58-encoded address of the account.
  final Address address;

  /// The index of the account address within the lookup table.
  final int addressIndex;

  /// The base58-encoded address of the lookup table account.
  final Address lookupTableAddress;

  /// The role of the account in the transaction.
  ///
  /// Must be either [AccountRole.readonly] or [AccountRole.writable] since
  /// accounts obtained via lookups may not act as signers.
  final AccountRole role;
}
