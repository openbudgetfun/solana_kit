import 'package:solana_kit_accounts/src/account_client.dart';
import 'package:solana_kit_accounts/src/fetch_account_config.dart';
import 'package:solana_kit_accounts/src/maybe_account.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

/// Fetches a [MaybeEncodedAccount] from the provided RPC client and address.
///
/// It uses the `getAccountInfo` RPC method under the hood with base64
/// encoding.
///
/// ```dart
/// final myAccount = await fetchEncodedAccount(rpc, myAddress);
/// ```
Future<MaybeEncodedAccount> fetchEncodedAccount(
  Rpc rpc,
  Address address, {
  FetchAccountConfig? config,
}) {
  return createSolanaAccountClient(rpc).fetchEncodedAccount(
    address,
    config: config,
  );
}

/// Fetches an array of [MaybeEncodedAccount]s from the provided RPC client
/// and an array of addresses.
///
/// It uses the `getMultipleAccounts` RPC method under the hood with base64
/// encoding.
///
/// ```dart
/// final [accountA, accountB] = await fetchEncodedAccounts(
///   rpc,
///   [addressA, addressB],
/// );
/// ```
Future<List<MaybeEncodedAccount>> fetchEncodedAccounts(
  Rpc rpc,
  List<Address> addresses, {
  FetchAccountConfig? config,
}) {
  return createSolanaAccountClient(rpc).fetchEncodedAccounts(
    addresses,
    config: config,
  );
}

/// Fetches a [MaybeAccount] from the provided RPC client and address by
/// using `getAccountInfo` under the hood with the `jsonParsed` encoding.
///
/// It may also return a [MaybeEncodedAccount] if the RPC client does not
/// know how to parse the account at the requested address.
///
/// ```dart
/// final myAccount = await fetchJsonParsedAccount(rpc, myAddress);
/// ```
Future<MaybeAccount<Object>> fetchJsonParsedAccount(
  Rpc rpc,
  Address address, {
  FetchAccountConfig? config,
}) {
  return createSolanaAccountClient(rpc).fetchJsonParsedAccount(
    address,
    config: config,
  );
}

/// Fetches an array of [MaybeAccount]s from the provided RPC client and
/// an array of addresses by using `getMultipleAccounts` under the hood
/// with the `jsonParsed` encoding.
///
/// It may also return [MaybeEncodedAccount]s for accounts that the RPC
/// client does not know how to parse.
///
/// ```dart
/// final [accountA, accountB] = await fetchJsonParsedAccounts(
///   rpc,
///   [addressA, addressB],
/// );
/// ```
Future<List<MaybeAccount<Object>>> fetchJsonParsedAccounts(
  Rpc rpc,
  List<Address> addresses, {
  FetchAccountConfig? config,
}) {
  return createSolanaAccountClient(rpc).fetchJsonParsedAccounts(
    addresses,
    config: config,
  );
}
