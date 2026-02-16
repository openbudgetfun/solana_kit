import 'package:solana_kit_rpc_api/src/allowed_numeric_keypaths.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for creating a Solana RPC API.
///
/// This mirrors the `RequestTransformerConfig` from the TypeScript SDK.
class SolanaRpcApiConfig {
  /// Creates a new [SolanaRpcApiConfig].
  const SolanaRpcApiConfig({this.defaultCommitment, this.onIntegerOverflow});

  /// An optional default commitment to use when none is supplied.
  final Commitment? defaultCommitment;

  /// An optional handler called whenever a BigInt input exceeds what can be
  /// expressed using JavaScript numbers.
  final IntegerOverflowHandler? onIntegerOverflow;
}

/// The set of all Solana JSON-RPC method names available on all clusters.
const List<String> solanaRpcMethodsForAllClusters = [
  'getAccountInfo',
  'getBalance',
  'getBlock',
  'getBlockCommitment',
  'getBlockHeight',
  'getBlockProduction',
  'getBlocks',
  'getBlocksWithLimit',
  'getBlockTime',
  'getClusterNodes',
  'getEpochInfo',
  'getEpochSchedule',
  'getFeeForMessage',
  'getFirstAvailableBlock',
  'getGenesisHash',
  'getHealth',
  'getHighestSnapshotSlot',
  'getIdentity',
  'getInflationGovernor',
  'getInflationRate',
  'getInflationReward',
  'getLargestAccounts',
  'getLatestBlockhash',
  'getLeaderSchedule',
  'getMaxRetransmitSlot',
  'getMaxShredInsertSlot',
  'getMinimumBalanceForRentExemption',
  'getMultipleAccounts',
  'getProgramAccounts',
  'getRecentPerformanceSamples',
  'getRecentPrioritizationFees',
  'getSignaturesForAddress',
  'getSignatureStatuses',
  'getSlot',
  'getSlotLeader',
  'getSlotLeaders',
  'getStakeMinimumDelegation',
  'getSupply',
  'getTokenAccountBalance',
  'getTokenAccountsByDelegate',
  'getTokenAccountsByOwner',
  'getTokenLargestAccounts',
  'getTokenSupply',
  'getTransaction',
  'getTransactionCount',
  'getVersion',
  'getVoteAccounts',
  'isBlockhashValid',
  'minimumLedgerSlot',
  'sendTransaction',
  'simulateTransaction',
];

/// The set of all Solana JSON-RPC method names available on test clusters
/// (devnet, testnet).
///
/// This includes all methods from [solanaRpcMethodsForAllClusters] plus
/// `requestAirdrop`.
const List<String> solanaRpcMethodsForTestClusters = [
  ...solanaRpcMethodsForAllClusters,
  'requestAirdrop',
];

/// Creates a [JsonRpcApi] implementation of the Solana JSON RPC API with
/// sensible defaults.
///
/// The default behaviours include:
/// - A transform that converts BigInt inputs to int for compatibility with
///   version 1.0 of the Solana JSON RPC.
/// - A transform that calls the config's `onIntegerOverflow` handler whenever
///   a BigInt input would overflow a JavaScript IEEE 754 number.
/// - A transform that applies a default commitment wherever not specified.
JsonRpcApi createSolanaRpcApi([SolanaRpcApiConfig? config]) {
  return createJsonRpcApi(
    config: RpcApiConfig(
      requestTransformer: getDefaultRequestTransformerForSolanaRpc(
        RequestTransformerConfig(
          defaultCommitment: config?.defaultCommitment,
          onIntegerOverflow: config?.onIntegerOverflow,
        ),
      ),
      responseTransformer: getDefaultResponseTransformerForSolanaRpc(
        ResponseTransformerConfig(
          allowedNumericKeyPaths: getAllowedNumericKeypaths(),
        ),
      ),
    ),
  );
}

/// Creates a [JsonRpcApiAdapter] wrapping a Solana RPC API.
///
/// This provides an [RpcApi] that can be used with [createRpc].
RpcApi createSolanaRpcApiAdapter([SolanaRpcApiConfig? config]) {
  return JsonRpcApiAdapter(createSolanaRpcApi(config));
}

/// Returns `true` if [methodName] is a valid Solana RPC method for all
/// clusters (including mainnet).
bool isSolanaRpcMethodForAllClusters(String methodName) {
  return solanaRpcMethodsForAllClusters.contains(methodName);
}

/// Returns `true` if [methodName] is a valid Solana RPC method for test
/// clusters (devnet, testnet).
bool isSolanaRpcMethodForTestClusters(String methodName) {
  return solanaRpcMethodsForTestClusters.contains(methodName);
}

/// Returns `true` if [methodName] is available on mainnet.
///
/// Mainnet does not support `requestAirdrop`.
bool isSolanaRpcMethodForMainnet(String methodName) {
  return isSolanaRpcMethodForAllClusters(methodName);
}
