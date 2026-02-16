import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';
import 'package:test/test.dart';

void main() {
  group('getAllowedNumericKeypaths', () {
    late AllowedNumericKeypaths keypaths;

    setUp(() {
      keypaths = getAllowedNumericKeypaths();
    });

    test('returns a non-empty map', () {
      expect(keypaths, isNotEmpty);
    });

    test('is memoized', () {
      final first = getAllowedNumericKeypaths();
      final second = getAllowedNumericKeypaths();
      expect(identical(first, second), isTrue);
    });

    test('contains getAccountInfo keypaths', () {
      expect(keypaths, contains('getAccountInfo'));
      expect(keypaths['getAccountInfo'], isNotEmpty);
    });

    test('contains getBlock keypaths', () {
      expect(keypaths, contains('getBlock'));
      final blockKeypaths = keypaths['getBlock']!;
      expect(blockKeypaths, isNotEmpty);

      // Should contain token balance keypaths
      expect(
        blockKeypaths,
        contains(
          equals([
            'transactions',
            KEYPATH_WILDCARD,
            'meta',
            'preTokenBalances',
            KEYPATH_WILDCARD,
            'accountIndex',
          ]),
        ),
      );
    });

    test('contains getClusterNodes keypaths', () {
      expect(keypaths, contains('getClusterNodes'));
      expect(
        keypaths['getClusterNodes'],
        contains(equals([KEYPATH_WILDCARD, 'featureSet'])),
      );
      expect(
        keypaths['getClusterNodes'],
        contains(equals([KEYPATH_WILDCARD, 'shredVersion'])),
      );
    });

    test('contains getInflationGovernor keypaths', () {
      expect(keypaths, contains('getInflationGovernor'));
      expect(keypaths['getInflationGovernor'], contains(equals(['initial'])));
      expect(keypaths['getInflationGovernor'], contains(equals(['terminal'])));
    });

    test('contains getInflationRate keypaths', () {
      expect(keypaths, contains('getInflationRate'));
      expect(keypaths['getInflationRate'], contains(equals(['foundation'])));
      expect(keypaths['getInflationRate'], contains(equals(['total'])));
      expect(keypaths['getInflationRate'], contains(equals(['validator'])));
    });

    test('contains getInflationReward keypaths', () {
      expect(keypaths, contains('getInflationReward'));
      expect(
        keypaths['getInflationReward'],
        contains(equals([KEYPATH_WILDCARD, 'commission'])),
      );
    });

    test('contains getMultipleAccounts keypaths', () {
      expect(keypaths, contains('getMultipleAccounts'));
      expect(keypaths['getMultipleAccounts'], isNotEmpty);
    });

    test('contains getRecentPerformanceSamples keypaths', () {
      expect(keypaths, contains('getRecentPerformanceSamples'));
      expect(
        keypaths['getRecentPerformanceSamples'],
        contains(equals([KEYPATH_WILDCARD, 'samplePeriodSecs'])),
      );
    });

    test('contains getTokenAccountBalance keypaths', () {
      expect(keypaths, contains('getTokenAccountBalance'));
      expect(
        keypaths['getTokenAccountBalance'],
        contains(equals(['value', 'decimals'])),
      );
      expect(
        keypaths['getTokenAccountBalance'],
        contains(equals(['value', 'uiAmount'])),
      );
    });

    test('contains getTokenSupply keypaths', () {
      expect(keypaths, contains('getTokenSupply'));
      expect(
        keypaths['getTokenSupply'],
        contains(equals(['value', 'decimals'])),
      );
      expect(
        keypaths['getTokenSupply'],
        contains(equals(['value', 'uiAmount'])),
      );
    });

    test('contains getTransaction keypaths', () {
      expect(keypaths, contains('getTransaction'));
      expect(keypaths['getTransaction'], isNotEmpty);
    });

    test('contains getVersion keypaths', () {
      expect(keypaths, contains('getVersion'));
      expect(keypaths['getVersion'], contains(equals(['feature-set'])));
    });

    test('contains getVoteAccounts keypaths', () {
      expect(keypaths, contains('getVoteAccounts'));
      expect(
        keypaths['getVoteAccounts'],
        contains(equals(['current', KEYPATH_WILDCARD, 'commission'])),
      );
      expect(
        keypaths['getVoteAccounts'],
        contains(equals(['delinquent', KEYPATH_WILDCARD, 'commission'])),
      );
    });

    test('contains simulateTransaction keypaths', () {
      expect(keypaths, contains('simulateTransaction'));
      expect(
        keypaths['simulateTransaction'],
        contains(equals(['value', 'loadedAccountsDataSize'])),
      );
    });

    test('contains getProgramAccounts keypaths', () {
      expect(keypaths, contains('getProgramAccounts'));
      expect(keypaths['getProgramAccounts'], isNotEmpty);
    });

    test('contains getTokenAccountsByDelegate keypaths', () {
      expect(keypaths, contains('getTokenAccountsByDelegate'));
      expect(keypaths['getTokenAccountsByDelegate'], isNotEmpty);
    });

    test('contains getTokenAccountsByOwner keypaths', () {
      expect(keypaths, contains('getTokenAccountsByOwner'));
      expect(keypaths['getTokenAccountsByOwner'], isNotEmpty);
    });

    test('contains getTokenLargestAccounts keypaths', () {
      expect(keypaths, contains('getTokenLargestAccounts'));
      expect(
        keypaths['getTokenLargestAccounts'],
        contains(equals(['value', KEYPATH_WILDCARD, 'decimals'])),
      );
    });
  });
}
