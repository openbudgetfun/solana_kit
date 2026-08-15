import 'package:solana_kit/src/client_interfaces.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

/// Creates a [ClientWithGetMinimumBalance] from a raw [Rpc] object.
///
/// The returned client computes the minimum balance for rent exemption using
/// the `getMinimumBalanceForRentExemption` RPC method. By default, the
/// 128-byte account header is included on top of the provided `space`; pass
/// `withoutHeader: true` to compute the minimum balance for the data portion
/// only.
///
/// This is a convenience helper for consumers that only have a raw [Rpc]
/// object rather than a full Kit client.
ClientWithGetMinimumBalance createClientWithGetMinimumBalanceFromRpc(
  Rpc rpc,
) {
  return _GetMinimumBalanceClient(rpc);
}

/// Creates a [ClientWithFetchAccounts] from a raw [Rpc] object.
///
/// The returned client fetches the encoded content of accounts from their
/// addresses, dispatching on the number of requested addresses: a single
/// account is fetched via the `getAccountInfo` RPC method, whilst multiple
/// accounts are fetched in a single round-trip via the `getMultipleAccounts`
/// RPC method. Fetching an empty list short-circuits to an empty array
/// without issuing any RPC call.
///
/// This is a convenience helper for consumers that only have a raw [Rpc]
/// object rather than a full Kit client.
ClientWithFetchAccounts createClientWithFetchAccountsFromRpc(Rpc rpc) {
  return _FetchAccountsClient(rpc);
}

/// Creates a client from a raw [Rpc] object, filling in whichever client
/// interfaces the RPC supports.
///
/// The returned object implements [ClientWithGetMinimumBalance] and
/// [ClientWithFetchAccounts]. Because a raw [Rpc] object's capabilities
/// cannot be detected at runtime, the returned object always carries both
/// methods; invoking one the RPC does not actually support will fail when
/// the underlying RPC method is called.
///
/// Note that this does not create a fully-fledged Kit client — it only wraps
/// the RPC in the account interfaces above.
({ClientWithGetMinimumBalance getMinimumBalance, ClientWithFetchAccounts fetchAccounts})
    createClientWithInterfacesFromRpc(Rpc rpc) {
  return (
    getMinimumBalance: _GetMinimumBalanceClient(rpc),
    fetchAccounts: _FetchAccountsClient(rpc),
  );
}

final class _GetMinimumBalanceClient implements ClientWithGetMinimumBalance {
  _GetMinimumBalanceClient(this._rpc);

  final Rpc _rpc;

  @override
  Future<BigInt> getMinimumBalance(
    int space, {
    bool withoutHeader = false,
  }) async {
    if (withoutHeader) {
      // The runtime computes rent as `rate * (baseAccountSize + space)`,
      // where `rate` folds in the per-byte cost and the exemption threshold.
      // Querying `space = 0` therefore returns `rate * 128`, which divides
      // evenly by `baseAccountSize` to recover `rate` exactly.
      final headerBalance = await _rpc
          .request<BigInt>(
            'getMinimumBalanceForRentExemption',
            getMinimumBalanceForRentExemptionParams(BigInt.zero),
          )
          .send();
      final lamportsPerByte = headerBalance ~/ BigInt.from(baseAccountSize);
      return lamportsPerByte * BigInt.from(space);
    }
    return _rpc
        .request<BigInt>(
          'getMinimumBalanceForRentExemption',
          getMinimumBalanceForRentExemptionParams(BigInt.from(space)),
        )
        .send();
  }
}

final class _FetchAccountsClient implements ClientWithFetchAccounts {
  _FetchAccountsClient(this._rpc);

  final Rpc _rpc;

  @override
  Future<List<MaybeEncodedAccount>> fetchAccounts(
    List<Address> addresses, {
    FetchAccountConfig? config,
  }) async {
    if (addresses.isEmpty) return [];
    if (addresses.length == 1) {
      return [
        await fetchEncodedAccount(_rpc, addresses[0], config: config),
      ];
    }
    return fetchEncodedAccounts(_rpc, addresses, config: config);
  }
}
