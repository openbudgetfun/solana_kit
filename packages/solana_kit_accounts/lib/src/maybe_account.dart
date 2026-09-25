import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/src/account.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Represents an account that may or may not exist on-chain.
///
/// When the account exists, it is represented as an [ExistingAccount] which
/// wraps an [Account] type with an additional `exists` flag set to `true`.
/// When it does not exist, it is represented as a [NonExistingAccount]
/// containing only the address and an `exists` flag set to `false`.
@immutable
sealed class MaybeAccount<TData> {
  const MaybeAccount();

  /// The address of this account.
  Address get address;

  /// Whether the account exists on-chain.
  bool get exists;
}

/// An account that exists on-chain.
///
/// Wraps the full [Account] with all of its properties.
@immutable
class ExistingAccount<TData> extends MaybeAccount<TData> {
  /// Creates an [ExistingAccount] wrapping the given [account].
  const ExistingAccount(this.account);

  /// The underlying account.
  final Account<TData> account;

  @override
  bool get exists => true;

  @override
  Address get address => account.address;

  /// The account data.
  TData get data => account.data;

  /// Whether the account contains a program.
  bool get executable => account.executable;

  /// Number of lamports assigned to this account.
  Lamports get lamports => account.lamports;

  /// Address of the program this account has been assigned to.
  Address get programAddress => account.programAddress;

  /// The size of the account data in bytes.
  BigInt get space => account.space;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExistingAccount<TData> &&
          runtimeType == other.runtimeType &&
          account == other.account;

  @override
  int get hashCode => account.hashCode;

  @override
  String toString() => 'ExistingAccount($account)';
}

/// An account that does not exist on-chain.
///
/// Contains only the address of the account.
@immutable
class NonExistingAccount<TData> extends MaybeAccount<TData> {
  /// Creates a [NonExistingAccount] with the given [address].
  const NonExistingAccount(this.address);

  @override
  final Address address;

  @override
  bool get exists => false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NonExistingAccount &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;

  @override
  String toString() => 'NonExistingAccount(address: $address)';
}

/// Represents an encoded account that may or may not exist on-chain.
///
/// When the account exists, its data is a [Uint8List]. When it does not exist,
/// only the address is available.
typedef MaybeEncodedAccount = MaybeAccount<Uint8List>;

/// Asserts that the given [MaybeAccount] exists on-chain.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.accountsAccountNotFound] if the account does not exist.
void assertAccountExists<TData>(MaybeAccount<TData> account) {
  if (!account.exists) {
    throw SolanaError(SolanaErrorCode.accountsAccountNotFound, {
      'address': account.address.value,
    });
  }
}

/// Asserts that all of the given [MaybeAccount]s exist on-chain.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.accountsOneOrMoreAccountsNotFound] if any of the
/// accounts do not exist.
void assertAccountsExist<TData>(List<MaybeAccount<TData>> accounts) {
  final missingAccounts = accounts.where((a) => !a.exists).toList();
  if (missingAccounts.isNotEmpty) {
    final missingAddresses = missingAccounts
        .map((a) => a.address.value)
        .toList();
    throw SolanaError(SolanaErrorCode.accountsOneOrMoreAccountsNotFound, {
      'addresses': missingAddresses,
    });
  }
}
