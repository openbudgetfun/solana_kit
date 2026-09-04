import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:test/test.dart';

void main() {
  group('SolanaRpcApi', () {
    group('solanaRpcMethodsForAllClusters', () {
      test('contains all expected methods', () {
        expect(
          solanaRpcMethodsForAllClusters,
          containsAll(<String>[
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
            'getTransactionsForAddress',
            'getVersion',
            'getVoteAccounts',
            'isBlockhashValid',
            'minimumLedgerSlot',
            'sendTransaction',
            'simulateTransaction',
          ]),
        );
      });

      test('does not contain requestAirdrop', () {
        expect(
          solanaRpcMethodsForAllClusters,
          isNot(contains('requestAirdrop')),
        );
      });

      test('has 53 methods', () {
        expect(solanaRpcMethodsForAllClusters, hasLength(53));
      });
    });

    group('solanaRpcMethodsForTestClusters', () {
      test('includes requestAirdrop', () {
        expect(solanaRpcMethodsForTestClusters, contains('requestAirdrop'));
      });

      test('includes all methods from allClusters', () {
        for (final method in solanaRpcMethodsForAllClusters) {
          expect(
            solanaRpcMethodsForTestClusters,
            contains(method),
            reason: 'Test clusters should include $method',
          );
        }
      });

      test('has 54 methods', () {
        expect(solanaRpcMethodsForTestClusters, hasLength(54));
      });
    });

    group('cluster variant helpers', () {
      test('isSolanaRpcMethodForMainnet excludes requestAirdrop', () {
        expect(isSolanaRpcMethodForMainnet('requestAirdrop'), isFalse);
        expect(isSolanaRpcMethodForMainnet('getBalance'), isTrue);
      });

      test('isSolanaRpcMethodForTestClusters includes requestAirdrop', () {
        expect(isSolanaRpcMethodForTestClusters('requestAirdrop'), isTrue);
        expect(isSolanaRpcMethodForTestClusters('getBalance'), isTrue);
      });

      test('isSolanaRpcMethodForAllClusters rejects unknown methods', () {
        expect(isSolanaRpcMethodForAllClusters('unknownMethod'), isFalse);
      });
    });

    group('createSolanaRpcApi', () {
      test('creates a JsonRpcApi without config', () {
        final api = createSolanaRpcApi();
        expect(api, isNotNull);
      });

      test('creates a JsonRpcApi with config', () {
        final api = createSolanaRpcApi(const SolanaRpcApiConfig());
        expect(api, isNotNull);
      });
    });

    group('createSolanaRpcApiAdapter', () {
      test('creates an RpcApi adapter', () {
        final api = createSolanaRpcApiAdapter();
        expect(api, isNotNull);
      });
    });
  });
}
