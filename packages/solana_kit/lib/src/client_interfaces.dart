import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

// ignore_for_file: one_member_abstracts

/// Represents a client that provides a default identity signer.
///
/// The identity is the signer whose assets the application is acting upon. In
/// many applications the identity and payer are the same signer, but the roles
/// can differ when a service pays fees on behalf of a user.
abstract interface class ClientWithIdentity<TSigner extends Object> {
  /// The default identity signer.
  TSigner get identity;
}

/// Represents a client that provides a default transaction payer.
///
/// The payer is the signer responsible for transaction fees and account-rent
/// funding. It may differ from [ClientWithIdentity.identity].
abstract interface class ClientWithPayer<TSigner extends Object> {
  /// The default transaction payer signer.
  TSigner get payer;
}

/// Registers a listener for changes to a reactive client capability.
///
/// Returns an idempotent unsubscribe callback.
typedef SubscribeToFn = void Function() Function(void Function() listener);

/// Represents a client that advertises [ClientWithPayer.payer] as reactive.
abstract interface class ClientWithSubscribeToPayer {
  /// Registers [listener] to run when the payer may have changed.
  void Function() subscribeToPayer(void Function() listener);
}

/// Represents a client that advertises [ClientWithIdentity.identity] as reactive.
abstract interface class ClientWithSubscribeToIdentity {
  /// Registers [listener] to run when the identity may have changed.
  void Function() subscribeToIdentity(void Function() listener);
}

/// Represents a client that can compute the minimum balance for rent
/// exemption.
abstract interface class ClientWithGetMinimumBalance {
  /// Computes the minimum balance for rent exemption for the given [space].
  ///
  /// By default the 128-byte account header is included on top of [space];
  /// pass [withoutHeader] to compute the minimum balance for the data portion
  /// only.
  Future<BigInt> getMinimumBalance(int space, {bool withoutHeader = false});
}

/// Represents a client that can fetch the encoded content of accounts from
/// their addresses.
abstract interface class ClientWithFetchAccounts {
  /// Fetches the encoded content of accounts from their addresses.
  ///
  /// The returned list matches the provided addresses in length and order,
  /// using [MaybeEncodedAccount] to represent accounts that may not exist.
  Future<List<MaybeEncodedAccount>> fetchAccounts(
    List<Address> addresses, {
    FetchAccountConfig? config,
  });
}
