import 'package:solana_kit_accounts/src/maybe_account.dart';
import 'package:solana_kit_accounts/src/parse_account.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Optional configuration for fetching accounts.
class FetchAccountConfig {
  /// Creates a new [FetchAccountConfig].
  const FetchAccountConfig({this.commitment, this.minContextSlot});

  /// Fetch the details of the account as of the highest slot that has reached
  /// this level of commitment.
  final Commitment? commitment;

  /// Prevents accessing stale data by enforcing that the RPC node has
  /// processed transactions up to this slot.
  final Slot? minContextSlot;
}

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
}) async {
  final params = <String, dynamic>{'encoding': 'base64'};
  if (config?.commitment case final commitment?) {
    params['commitment'] = commitment.name;
  }
  if (config?.minContextSlot case final minContextSlot?) {
    params['minContextSlot'] = minContextSlot;
  }

  final response = await rpc.request('getAccountInfo', [
    address.value,
    params,
  ]).send();

  final responseMap = response as Map<String, dynamic>?;
  if (responseMap == null) {
    return parseBase64RpcAccount(address, null);
  }

  final value = responseMap['value'] as Map<String, dynamic>?;
  return parseBase64RpcAccount(address, value);
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
}) async {
  final params = <String, dynamic>{'encoding': 'base64'};
  if (config?.commitment case final commitment?) {
    params['commitment'] = commitment.name;
  }
  if (config?.minContextSlot case final minContextSlot?) {
    params['minContextSlot'] = minContextSlot;
  }

  final addressStrings = addresses.map((a) => a.value).toList();
  final response = await rpc.request('getMultipleAccounts', [
    addressStrings,
    params,
  ]).send();

  final responseMap = response as Map<String, dynamic>?;
  if (responseMap == null) {
    return addresses.map((addr) => parseBase64RpcAccount(addr, null)).toList();
  }

  final value = responseMap['value'] as List;
  return List.generate(value.length, (index) {
    final accountData = value[index] as Map<String, dynamic>?;
    return parseBase64RpcAccount(addresses[index], accountData);
  });
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
}) async {
  final params = <String, dynamic>{'encoding': 'jsonParsed'};
  if (config?.commitment case final commitment?) {
    params['commitment'] = commitment.name;
  }
  if (config?.minContextSlot case final minContextSlot?) {
    params['minContextSlot'] = minContextSlot;
  }

  final response = await rpc.request('getAccountInfo', [
    address.value,
    params,
  ]).send();

  final responseMap = response as Map<String, dynamic>?;
  if (responseMap == null) {
    return parseBase64RpcAccount(address, null);
  }

  final value = responseMap['value'] as Map<String, dynamic>?;
  if (value == null) {
    return parseBase64RpcAccount(address, null);
  }

  final data = value['data'];
  if (data is Map<String, dynamic> && data.containsKey('parsed')) {
    return parseJsonRpcAccount(address, value);
  }

  return parseBase64RpcAccount(address, value);
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
}) async {
  final params = <String, dynamic>{'encoding': 'jsonParsed'};
  if (config?.commitment case final commitment?) {
    params['commitment'] = commitment.name;
  }
  if (config?.minContextSlot case final minContextSlot?) {
    params['minContextSlot'] = minContextSlot;
  }

  final addressStrings = addresses.map((a) => a.value).toList();
  final response = await rpc.request('getMultipleAccounts', [
    addressStrings,
    params,
  ]).send();

  final responseMap = response as Map<String, dynamic>?;
  if (responseMap == null) {
    return addresses
        .map(
          (addr) => parseBase64RpcAccount(addr, null) as MaybeAccount<Object>,
        )
        .toList();
  }

  final value = responseMap['value'] as List;
  return List.generate(value.length, (index) {
    final accountData = value[index] as Map<String, dynamic>?;
    if (accountData == null) {
      return parseBase64RpcAccount(addresses[index], null);
    }

    final data = accountData['data'];
    if (data is Map<String, dynamic> && data.containsKey('parsed')) {
      return parseJsonRpcAccount(addresses[index], accountData);
    }

    return parseBase64RpcAccount(addresses[index], accountData);
  });
}
