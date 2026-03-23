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
