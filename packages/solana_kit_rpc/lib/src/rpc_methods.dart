import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Typed convenience methods for common Solana JSON-RPC calls.
///
/// These helpers wrap [Rpc.request] and method-specific params builders from
/// `solana_kit_rpc_api`, so callers do not need to manually assemble RPC
/// method names and positional params arrays.
extension SolanaRpcMethods on Rpc {
  /// {@template solanaKitRpcMethodPendingRequest}
  /// Returns a lazy [PendingRpcRequest].
  ///
  /// No network call is made until [PendingRpcRequest.send] is called.
  /// {@endtemplate}
  ///
  /// {@template solanaKitRpcMethodRawResponseShape}
  /// Response values preserve Solana JSON-RPC result shapes after default
  /// transformers are applied (error handling, `result` extraction, and BigInt
  /// upcasting).
  /// {@endtemplate}
  ///
  /// Fetches details for an account.
  ///
  /// This wraps the `getAccountInfo` RPC method.
  ///
  /// {@macro solanaKitRpcMethodPendingRequest}
  /// {@macro solanaKitRpcMethodRawResponseShape}
  PendingRpcRequest<Map<String, Object?>> getAccountInfo(
    Address address, [
    GetAccountInfoConfig? config,
  ]) {
    return request<Map<String, Object?>>(
      'getAccountInfo',
      getAccountInfoParams(address, config),
    );
  }

  /// Fetches account info and parses the result into a typed Solana RPC
  /// response wrapper.
  PendingRpcRequest<SolanaRpcResponse<Map<String, Object?>?>> getAccountInfoValue(
    Address address, [
    GetAccountInfoConfig? config,
  ]) {
    return _mapPendingRpcRequest(
      request<Object?>(
        'getAccountInfo',
        getAccountInfoParams(address, config),
      ),
      _parseNullableMapRpcResponse,
    );
  }

  /// Fetches account balance with context metadata.
  ///
  /// This wraps the `getBalance` RPC method.
  ///
  /// {@macro solanaKitRpcMethodPendingRequest}
  /// {@macro solanaKitRpcMethodRawResponseShape}
  PendingRpcRequest<Map<String, Object?>> getBalance(
    Address address, [
    GetBalanceConfig? config,
  ]) {
    return request<Map<String, Object?>>(
      'getBalance',
      getBalanceParams(address, config),
    );
  }

  /// Fetches balance and parses the result into a typed Solana RPC response
  /// wrapper.
  PendingRpcRequest<SolanaRpcResponse<Lamports>> getBalanceValue(
    Address address, [
    GetBalanceConfig? config,
  ]) {
    return _mapPendingRpcRequest(
      request<Object?>(
        'getBalance',
        getBalanceParams(address, config),
      ),
      _parseLamportsRpcResponse,
    );
  }

  /// Fetches the current block height.
  ///
  /// This wraps the `getBlockHeight` RPC method.
  ///
  /// {@macro solanaKitRpcMethodPendingRequest}
  PendingRpcRequest<Slot> getBlockHeight([GetBlockHeightConfig? config]) {
    return request<Slot>('getBlockHeight', getBlockHeightParams(config));
  }

  /// Fetches information about the current epoch.
  ///
  /// This wraps the `getEpochInfo` RPC method.
  ///
  /// {@macro solanaKitRpcMethodPendingRequest}
  /// {@macro solanaKitRpcMethodRawResponseShape}
  PendingRpcRequest<Map<String, Object?>> getEpochInfo([
    GetEpochInfoConfig? config,
  ]) {
    return request<Map<String, Object?>>(
      'getEpochInfo',
      getEpochInfoParams(config),
    );
  }

  /// Fetches the fee for a serialized transaction message.
  ///
  /// This wraps the `getFeeForMessage` RPC method.
  ///
  /// {@macro solanaKitRpcMethodPendingRequest}
  /// {@macro solanaKitRpcMethodRawResponseShape}
  PendingRpcRequest<Map<String, Object?>> getFeeForMessage(
    String message, [
    GetFeeForMessageConfig? config,
  ]) {
    return request<Map<String, Object?>>(
      'getFeeForMessage',
      getFeeForMessageParams(message, config),
    );
  }

  /// Fetches the latest blockhash and expiry metadata.
  ///
  /// This wraps the `getLatestBlockhash` RPC method.
  ///
  /// {@macro solanaKitRpcMethodPendingRequest}
  /// {@macro solanaKitRpcMethodRawResponseShape}
  PendingRpcRequest<Map<String, Object?>> getLatestBlockhash([
    GetLatestBlockhashConfig? config,
  ]) {
    return request<Map<String, Object?>>(
      'getLatestBlockhash',
      getLatestBlockhashParams(config),
    );
  }

  /// Fetches the latest blockhash and parses it into a typed response model.
  PendingRpcRequest<SolanaRpcResponse<LatestBlockhashValue>>
  getLatestBlockhashValue([
    GetLatestBlockhashConfig? config,
  ]) {
    return _mapPendingRpcRequest(
      request<Object?>(
        'getLatestBlockhash',
        getLatestBlockhashParams(config),
      ),
      _parseLatestBlockhashRpcResponse,
    );
  }

  /// Fetches details for multiple accounts.
  ///
  /// This wraps the `getMultipleAccounts` RPC method.
  PendingRpcRequest<Map<String, Object?>> getMultipleAccounts(
    List<Address> addresses, [
    GetMultipleAccountsConfig? config,
  ]) {
    return request<Map<String, Object?>>(
      'getMultipleAccounts',
      getMultipleAccountsParams(addresses, config),
    );
  }

  /// Fetches multiple account values and parses them into a typed Solana RPC
  /// response wrapper.
  PendingRpcRequest<SolanaRpcResponse<List<Map<String, Object?>?>>>
  getMultipleAccountsValue(
    List<Address> addresses, [
    GetMultipleAccountsConfig? config,
  ]) {
    return _mapPendingRpcRequest(
      request<Object?>(
        'getMultipleAccounts',
        getMultipleAccountsParams(addresses, config),
      ),
      _parseNullableMapListRpcResponse,
    );
  }

  /// Fetches status details for one or more signatures.
  ///
  /// This wraps the `getSignatureStatuses` RPC method.
  ///
  /// {@macro solanaKitRpcMethodPendingRequest}
  /// {@macro solanaKitRpcMethodRawResponseShape}
  PendingRpcRequest<Map<String, Object?>> getSignatureStatuses(
    List<Signature> signatures, [
    GetSignatureStatusesConfig? config,
  ]) {
    return request<Map<String, Object?>>(
      'getSignatureStatuses',
      getSignatureStatusesParams(signatures, config),
    );
  }

  /// Fetches the current slot.
  ///
  /// This wraps the `getSlot` RPC method.
  ///
  /// {@macro solanaKitRpcMethodPendingRequest}
  PendingRpcRequest<Slot> getSlot([GetSlotConfig? config]) {
    return request<Slot>('getSlot', getSlotParams(config));
  }

  /// Fetches transaction details for [signature].
  ///
  /// This wraps the `getTransaction` RPC method.
  ///
  /// Returns `null` when the transaction cannot be found.
  ///
  /// {@macro solanaKitRpcMethodPendingRequest}
  /// {@macro solanaKitRpcMethodRawResponseShape}
  PendingRpcRequest<Map<String, Object?>?> getTransaction(
    Signature signature, [
    GetTransactionConfig? config,
  ]) {
    return request<Map<String, Object?>?>(
      'getTransaction',
      getTransactionParams(signature, config),
    );
  }

  /// Requests an airdrop and returns the submitted transaction signature.
  ///
  /// This wraps the `requestAirdrop` RPC method.
  ///
  /// {@macro solanaKitRpcMethodPendingRequest}
  PendingRpcRequest<String> requestAirdrop(
    Address recipientAccount,
    Lamports lamports, [
    RequestAirdropConfig? config,
  ]) {
    return request<String>(
      'requestAirdrop',
      requestAirdropParams(recipientAccount, lamports, config),
    );
  }

  /// Sends a wire transaction and returns the transaction signature.
  ///
  /// This wraps the `sendTransaction` RPC method.
  ///
  /// [base64EncodedWireTransaction] should be a serialized transaction encoded
  /// as base64.
  ///
  /// {@macro solanaKitRpcMethodPendingRequest}
  PendingRpcRequest<String> sendTransaction(
    String base64EncodedWireTransaction, [
    SendTransactionConfig? config,
  ]) {
    return request<String>(
      'sendTransaction',
      sendTransactionParams(base64EncodedWireTransaction, config),
    );
  }
}

PendingRpcRequest<TOutput> _mapPendingRpcRequest<TInput, TOutput>(
  PendingRpcRequest<TInput> request,
  TOutput Function(TInput value) mapper,
) {
  return PendingRpcRequest<TOutput>(
    plan: RpcPlan<TOutput>(
      execute: (config) async => mapper(await request.plan.execute(config)),
    ),
    transport: request.transport,
  );
}

SolanaRpcResponse<Map<String, Object?>?> _parseNullableMapRpcResponse(
  Object? response,
) {
  return _parseSolanaRpcResponse(response, (value) {
    if (value == null) return null;
    final typedValue = value as Map;
    return typedValue.cast<String, Object?>();
  });
}

SolanaRpcResponse<List<Map<String, Object?>?>> _parseNullableMapListRpcResponse(
  Object? response,
) {
  return _parseSolanaRpcResponse(response, (value) {
    final typedValue = (value as List<Object?>?) ?? const <Object?>[];
    return typedValue.map((item) {
      if (item == null) return null;
      final typedItem = item as Map;
      return typedItem.cast<String, Object?>();
    }).toList(growable: false);
  });
}

SolanaRpcResponse<Lamports> _parseLamportsRpcResponse(
  Object? response,
) {
  return _parseSolanaRpcResponse(response, (value) {
    return lamports(value! as BigInt);
  });
}

SolanaRpcResponse<LatestBlockhashValue> _parseLatestBlockhashRpcResponse(
  Object? response,
) {
  return _parseSolanaRpcResponse(response, (value) {
    final typedValue = (value! as Map).cast<String, Object?>();
    return LatestBlockhashValue(
      blockhash: blockhash(typedValue['blockhash']! as String),
      lastValidBlockHeight: typedValue['lastValidBlockHeight']! as BigInt,
    );
  });
}

SolanaRpcResponse<TValue> _parseSolanaRpcResponse<TValue>(
  Object? response,
  TValue Function(Object? value) parseValue,
) {
  final typedResponse = switch (response) {
    Map() => response.cast<String, Object?>(),
    _ => <String, Object?>{},
  };
  final typedContext = switch (typedResponse['context']) {
    Map() => (typedResponse['context']! as Map).cast<String, Object?>(),
    _ => <String, Object?>{},
  };
  return SolanaRpcResponse<TValue>(
    context: RpcResponseContext(
      slot: (typedContext['slot'] as Slot?) ?? BigInt.zero,
    ),
    value: parseValue(typedResponse['value']),
  );
}
