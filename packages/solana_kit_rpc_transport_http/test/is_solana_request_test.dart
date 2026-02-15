import 'package:solana_kit_rpc_transport_http/solana_kit_rpc_transport_http.dart';
import 'package:test/test.dart';

void main() {
  group('isSolanaRequest', () {
    const allSolanaRpcMethods = [
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
    ];

    for (final method in allSolanaRpcMethods) {
      test('returns true for Solana RPC method `$method`', () {
        final payload = <String, Object?>{
          'jsonrpc': '2.0',
          'method': method,
          'params': <Object?>['1234..5678'],
        };
        expect(isSolanaRequest(payload), isTrue);
      });
    }

    test('returns false for an unknown method', () {
      final payload = <String, Object?>{
        'jsonrpc': '2.0',
        'method': 'getAssetsByAuthority',
        'params': <Object?>['1234..5678'],
      };
      expect(isSolanaRequest(payload), isFalse);
    });

    test('returns false for a non-JSON-RPC payload (null)', () {
      expect(isSolanaRequest(null), isFalse);
    });

    test('returns false for a non-JSON-RPC payload (string)', () {
      expect(isSolanaRequest('hello'), isFalse);
    });

    test('returns false for a non-JSON-RPC payload (number)', () {
      expect(isSolanaRequest(42), isFalse);
    });

    test('returns false for a non-JSON-RPC payload (empty map)', () {
      expect(isSolanaRequest(<String, Object?>{}), isFalse);
    });

    test('returns false for a map missing the params key', () {
      final payload = <String, Object?>{
        'jsonrpc': '2.0',
        'method': 'getBalance',
      };
      expect(isSolanaRequest(payload), isFalse);
    });

    test('returns false for a map with wrong jsonrpc version', () {
      final payload = <String, Object?>{
        'jsonrpc': '1.0',
        'method': 'getBalance',
        'params': <Object?>[],
      };
      expect(isSolanaRequest(payload), isFalse);
    });
  });
}
