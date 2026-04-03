import 'package:solana_kit_accounts/src/fetch_account_config.dart';
import 'package:solana_kit_accounts/src/maybe_account.dart';
import 'package:solana_kit_accounts/src/parse_account.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Higher-level account client layered on top of a typed [Rpc].
class SolanaAccountClient {
  /// Creates a [SolanaAccountClient].
  const SolanaAccountClient(this._rpc);

  final Rpc _rpc;

  /// Fetches an encoded account using `getAccountInfo` with base64 encoding.
  Future<MaybeEncodedAccount> fetchEncodedAccount(
    Address address, {
    FetchAccountConfig? config,
  }) async {
    final response = await _rpc
        .getAccountInfoValue(
          address,
          _getAccountInfoConfig(config, AccountEncoding.base64),
        )
        .send();
    return parseBase64RpcAccount(address, _castRpcAccount(response.value));
  }

  /// Fetches encoded accounts using `getMultipleAccounts` with base64
  /// encoding.
  Future<List<MaybeEncodedAccount>> fetchEncodedAccounts(
    List<Address> addresses, {
    FetchAccountConfig? config,
  }) async {
    final response = await _rpc
        .getMultipleAccountsValue(
          addresses,
          _getMultipleAccountsConfig(config, AccountEncoding.base64),
        )
        .send();

    return List.generate(addresses.length, (index) {
      final accountData = index < response.value.length ? response.value[index] : null;
      return parseBase64RpcAccount(
        addresses[index],
        _castRpcAccount(accountData),
      );
    });
  }

  /// Fetches a single `jsonParsed` account when available, with a base64
  /// fallback when the RPC does not return parsed data.
  Future<MaybeAccount<Object>> fetchJsonParsedAccount(
    Address address, {
    FetchAccountConfig? config,
  }) async {
    final response = await _rpc
        .getAccountInfoValue(
          address,
          _getAccountInfoConfig(config, AccountEncoding.jsonParsed),
        )
        .send();

    final value = _castRpcAccount(response.value);
    if (value == null) {
      return parseBase64RpcAccount(address, null);
    }

    final data = value['data'];
    if (data is Map<String, Object?> && data.containsKey('parsed')) {
      return parseJsonRpcAccount(address, value);
    }

    return parseBase64RpcAccount(address, value);
  }

  /// Fetches multiple `jsonParsed` accounts when available, with base64
  /// fallbacks when the RPC does not return parsed data.
  Future<List<MaybeAccount<Object>>> fetchJsonParsedAccounts(
    List<Address> addresses, {
    FetchAccountConfig? config,
  }) async {
    final response = await _rpc
        .getMultipleAccountsValue(
          addresses,
          _getMultipleAccountsConfig(config, AccountEncoding.jsonParsed),
        )
        .send();

    return List.generate(addresses.length, (index) {
      final accountData = _castRpcAccount(
        index < response.value.length ? response.value[index] : null,
      );
      if (accountData == null) {
        return parseBase64RpcAccount(addresses[index], null)
            as MaybeAccount<Object>;
      }

      final data = accountData['data'];
      if (data is Map<String, Object?> && data.containsKey('parsed')) {
        return parseJsonRpcAccount(addresses[index], accountData);
      }

      return parseBase64RpcAccount(addresses[index], accountData);
    });
  }
}

/// Creates a higher-level account client layered on top of [rpc].
SolanaAccountClient createSolanaAccountClient(Rpc rpc) {
  return SolanaAccountClient(rpc);
}

GetAccountInfoConfig _getAccountInfoConfig(
  FetchAccountConfig? config,
  AccountEncoding encoding,
) {
  return GetAccountInfoConfig(
    commitment: config?.commitment,
    encoding: encoding,
    minContextSlot: config?.minContextSlot,
  );
}

GetMultipleAccountsConfig _getMultipleAccountsConfig(
  FetchAccountConfig? config,
  AccountEncoding encoding,
) {
  return GetMultipleAccountsConfig(
    commitment: config?.commitment,
    encoding: encoding,
    minContextSlot: config?.minContextSlot,
  );
}

Map<String, dynamic>? _castRpcAccount(Map<String, Object?>? account) {
  return account?.cast<String, dynamic>();
}
