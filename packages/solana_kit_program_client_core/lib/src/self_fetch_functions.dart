import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

/// Methods that allow a decoder to fetch and decode accounts directly.
///
/// These methods are provided via [addSelfFetchFunctions], enabling a fluent
/// API where you can call `.fetch()` directly on a wrapper to retrieve and
/// decode accounts in one step.
///
/// Example:
/// ```dart
/// final fetchable = addSelfFetchFunctions(rpc, myDecoder);
/// final account = await fetchable.fetch(address);
/// // account.data is of type TData.
/// ```
class SelfFetchFunctions<TData> {
  /// Creates a [SelfFetchFunctions] wrapping the given [decoder] and [rpc].
  SelfFetchFunctions({required Decoder<TData> decoder, required Rpc rpc})
    : _decoder = decoder,
      _rpc = rpc;

  final Decoder<TData> _decoder;
  final Rpc _rpc;

  /// Fetches and decodes a single account, throwing if it does not exist.
  ///
  /// Throws a `SolanaError` with code
  /// `SolanaErrorCode.accountsAccountNotFound` if the account does not exist.
  Future<Account<TData>> fetch(
    Address address, {
    FetchAccountConfig? config,
  }) async {
    final maybeAccount = await fetchMaybe(address, config: config);
    assertAccountExists(maybeAccount);
    return (maybeAccount as ExistingAccount<TData>).account;
  }

  /// Fetches and decodes a single account, returning a [MaybeAccount].
  ///
  /// Does not throw if the account does not exist; instead returns a
  /// [NonExistingAccount].
  Future<MaybeAccount<TData>> fetchMaybe(
    Address address, {
    FetchAccountConfig? config,
  }) async {
    final maybeEncodedAccount = await fetchEncodedAccount(
      _rpc,
      address,
      config: config,
    );
    return decodeMaybeAccount(maybeEncodedAccount, _decoder);
  }

  /// Fetches and decodes multiple accounts, throwing if any do not exist.
  ///
  /// Throws a `SolanaError` with code
  /// `SolanaErrorCode.accountsOneOrMoreAccountsNotFound` if any of the
  /// accounts do not exist.
  Future<List<Account<TData>>> fetchAll(
    List<Address> addresses, {
    FetchAccountConfig? config,
  }) async {
    final maybeAccounts = await fetchAllMaybe(addresses, config: config);
    assertAccountsExist(maybeAccounts);
    return maybeAccounts
        .cast<ExistingAccount<TData>>()
        .map((e) => e.account)
        .toList();
  }

  /// Fetches and decodes multiple accounts, returning [MaybeAccount] for each.
  ///
  /// Does not throw if some accounts do not exist; instead returns
  /// [NonExistingAccount] for missing accounts.
  Future<List<MaybeAccount<TData>>> fetchAllMaybe(
    List<Address> addresses, {
    FetchAccountConfig? config,
  }) async {
    final maybeEncodedAccounts = await fetchEncodedAccounts(
      _rpc,
      addresses,
      config: config,
    );
    return maybeEncodedAccounts
        .map((maybeAccount) => decodeMaybeAccount(maybeAccount, _decoder))
        .toList();
  }
}

/// Augments a [Decoder] with self-fetch methods by wrapping it in a
/// [SelfFetchFunctions] instance.
///
/// This enables a fluent API where you can call methods like `.fetch()`
/// directly on the returned object to retrieve and decode accounts in one
/// step.
///
/// Example:
/// ```dart
/// final fetchable = addSelfFetchFunctions(rpc, myDecoder);
///
/// // Fetch and decode an account in one step.
/// final account = await fetchable.fetch(accountAddress);
///
/// // Handle accounts that may not exist.
/// final maybeAccount = await fetchable.fetchMaybe(accountAddress);
/// if (maybeAccount.exists) {
///   // Use maybeAccount.
/// }
///
/// // Fetch multiple accounts at once (throws if any are missing).
/// final accounts = await fetchable.fetchAll([addressA, addressB]);
///
/// // Fetch multiple accounts, allowing some to be missing.
/// final maybeAccounts = await fetchable.fetchAllMaybe([addressA, addressB]);
/// ```
SelfFetchFunctions<TData> addSelfFetchFunctions<TData>(
  Rpc rpc,
  Decoder<TData> decoder,
) {
  return SelfFetchFunctions<TData>(decoder: decoder, rpc: rpc);
}
