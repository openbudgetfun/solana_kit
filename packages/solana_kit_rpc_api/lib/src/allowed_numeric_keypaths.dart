import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';

/// Cached keypaths instance.
AllowedNumericKeypaths? _memoizedKeypaths;

/// Returns the allowed numeric keypaths for the Solana RPC API.
///
/// These are keypaths at the end of which you will find a numeric value that
/// should *not* be upcast to a [BigInt]. These are values that are
/// legitimately defined as `u8` or `usize` on the backend.
AllowedNumericKeypaths getAllowedNumericKeypaths() {
  if (_memoizedKeypaths != null) return _memoizedKeypaths!;

  _memoizedKeypaths = {
    'getAccountInfo': [
      for (final c in jsonParsedAccountsConfigs) ['value', ...c],
    ],
    'getBlock': [
      for (final c in tokenBalancesConfigs) ...[
        [
          'transactions',
          KEYPATH_WILDCARD,
          'meta',
          'preTokenBalances',
          KEYPATH_WILDCARD,
          ...c,
        ],
        [
          'transactions',
          KEYPATH_WILDCARD,
          'meta',
          'postTokenBalances',
          KEYPATH_WILDCARD,
          ...c,
        ],
      ],
      [
        'transactions',
        KEYPATH_WILDCARD,
        'meta',
        'rewards',
        KEYPATH_WILDCARD,
        'commission',
      ],
      for (final c in innerInstructionsConfigs)
        [
          'transactions',
          KEYPATH_WILDCARD,
          'meta',
          'innerInstructions',
          KEYPATH_WILDCARD,
          ...c,
        ],
      for (final c in messageConfig)
        ['transactions', KEYPATH_WILDCARD, 'transaction', 'message', ...c],
      ['transactions', KEYPATH_WILDCARD, 'version'],
      ['rewards', KEYPATH_WILDCARD, 'commission'],
    ],
    'getClusterNodes': [
      [KEYPATH_WILDCARD, 'featureSet'],
      [KEYPATH_WILDCARD, 'shredVersion'],
    ],
    'getInflationGovernor': [
      ['initial'],
      ['foundation'],
      ['foundationTerm'],
      ['taper'],
      ['terminal'],
    ],
    'getInflationRate': [
      ['foundation'],
      ['total'],
      ['validator'],
    ],
    'getInflationReward': [
      [KEYPATH_WILDCARD, 'commission'],
    ],
    'getMultipleAccounts': [
      for (final c in jsonParsedAccountsConfigs)
        ['value', KEYPATH_WILDCARD, ...c],
    ],
    'getProgramAccounts': [
      for (final c in jsonParsedAccountsConfigs) ...[
        ['value', KEYPATH_WILDCARD, 'account', ...c],
        [KEYPATH_WILDCARD, 'account', ...c],
      ],
    ],
    'getRecentPerformanceSamples': [
      [KEYPATH_WILDCARD, 'samplePeriodSecs'],
    ],
    'getTokenAccountBalance': [
      ['value', 'decimals'],
      ['value', 'uiAmount'],
    ],
    'getTokenAccountsByDelegate': [
      for (final c in jsonParsedTokenAccountsConfigs)
        ['value', KEYPATH_WILDCARD, 'account', ...c],
    ],
    'getTokenAccountsByOwner': [
      for (final c in jsonParsedTokenAccountsConfigs)
        ['value', KEYPATH_WILDCARD, 'account', ...c],
    ],
    'getTokenLargestAccounts': [
      ['value', KEYPATH_WILDCARD, 'decimals'],
      ['value', KEYPATH_WILDCARD, 'uiAmount'],
    ],
    'getTokenSupply': [
      ['value', 'decimals'],
      ['value', 'uiAmount'],
    ],
    'getTransactionsForAddress': [
      ['data', KEYPATH_WILDCARD, 'transactionIndex'],
      for (final c in tokenBalancesConfigs) ...[
        [
          'data',
          KEYPATH_WILDCARD,
          'meta',
          'preTokenBalances',
          KEYPATH_WILDCARD,
          ...c,
        ],
        [
          'data',
          KEYPATH_WILDCARD,
          'meta',
          'postTokenBalances',
          KEYPATH_WILDCARD,
          ...c,
        ],
      ],
      [
        'data',
        KEYPATH_WILDCARD,
        'meta',
        'rewards',
        KEYPATH_WILDCARD,
        'commission',
      ],
      for (final c in innerInstructionsConfigs)
        [
          'data',
          KEYPATH_WILDCARD,
          'meta',
          'innerInstructions',
          KEYPATH_WILDCARD,
          ...c,
        ],
      for (final c in messageConfig)
        ['data', KEYPATH_WILDCARD, 'transaction', 'message', ...c],
      ['data', KEYPATH_WILDCARD, 'version'],
    ],
    'getTransaction': [
      for (final c in tokenBalancesConfigs) ...[
        ['meta', 'preTokenBalances', KEYPATH_WILDCARD, ...c],
        ['meta', 'postTokenBalances', KEYPATH_WILDCARD, ...c],
      ],
      ['meta', 'rewards', KEYPATH_WILDCARD, 'commission'],
      for (final c in innerInstructionsConfigs)
        ['meta', 'innerInstructions', KEYPATH_WILDCARD, ...c],
      for (final c in messageConfig) ['transaction', 'message', ...c],
      ['version'],
    ],
    'getVersion': [
      ['feature-set'],
    ],
    'getVoteAccounts': [
      ['current', KEYPATH_WILDCARD, 'commission'],
      ['delinquent', KEYPATH_WILDCARD, 'commission'],
      // Added in @solana/kit v7.0.0 (Agave 4.1.0): keep vote commissions and
      // latency as `int` rather than upcasting to `BigInt`.
      ['current', KEYPATH_WILDCARD, 'blockRevenueCommissionBps'],
      ['current', KEYPATH_WILDCARD, 'inflationRewardsCommissionBps'],
      [
        'current',
        KEYPATH_WILDCARD,
        'votes',
        KEYPATH_WILDCARD,
        'latency',
      ],
      ['delinquent', KEYPATH_WILDCARD, 'blockRevenueCommissionBps'],
      ['delinquent', KEYPATH_WILDCARD, 'inflationRewardsCommissionBps'],
      [
        'delinquent',
        KEYPATH_WILDCARD,
        'votes',
        KEYPATH_WILDCARD,
        'latency',
      ],
    ],
    'simulateTransaction': [
      ['value', 'loadedAccountsDataSize'],
      for (final c in jsonParsedAccountsConfigs)
        ['value', 'accounts', KEYPATH_WILDCARD, ...c],
      for (final c in innerInstructionsConfigs)
        ['value', 'innerInstructions', KEYPATH_WILDCARD, ...c],
      for (final c in tokenBalancesConfigs) ...[
        ['value', 'preTokenBalances', KEYPATH_WILDCARD, ...c],
        ['value', 'postTokenBalances', KEYPATH_WILDCARD, ...c],
      ],
    ],
  };

  return _memoizedKeypaths!;
}
