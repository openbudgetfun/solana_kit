import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

/// The set of all known Solana RPC method names.
const _solanaRpcMethods = <String>{
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
  'index',
  'isBlockhashValid',
  'minimumLedgerSlot',
  'requestAirdrop',
  'sendTransaction',
  'simulateTransaction',
};

/// Returns `true` if the given [payload] is a JSON-RPC 2.0 request for a
/// known Solana RPC method.
///
/// This checks that:
/// 1. The payload is a valid JSON-RPC 2.0 payload (via [isJsonRpcPayload]).
/// 2. The `method` field is one of the known Solana RPC method names.
///
/// ```dart
/// final payload = {
///   'jsonrpc': '2.0',
///   'method': 'getBalance',
///   'params': ['1234..5678'],
/// };
/// print(isSolanaRequest(payload)); // true
/// ```
bool isSolanaRequest(Object? payload) {
  if (!isJsonRpcPayload(payload)) {
    return false;
  }
  final method = (payload! as Map<String, Object?>)['method']! as String;
  return _solanaRpcMethods.contains(method);
}
