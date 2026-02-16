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
      [
        'transactions',
        KEYPATH_WILDCARD,
        'meta',
        'preTokenBalances',
        KEYPATH_WILDCARD,
        'accountIndex',
      ],
      [
        'transactions',
        KEYPATH_WILDCARD,
        'meta',
        'preTokenBalances',
        KEYPATH_WILDCARD,
        'uiTokenAmount',
        'decimals',
      ],
      [
        'transactions',
        KEYPATH_WILDCARD,
        'meta',
        'postTokenBalances',
        KEYPATH_WILDCARD,
        'accountIndex',
      ],
      [
        'transactions',
        KEYPATH_WILDCARD,
        'meta',
        'postTokenBalances',
        KEYPATH_WILDCARD,
        'uiTokenAmount',
        'decimals',
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
    'getTransaction': [
      ['meta', 'preTokenBalances', KEYPATH_WILDCARD, 'accountIndex'],
      [
        'meta',
        'preTokenBalances',
        KEYPATH_WILDCARD,
        'uiTokenAmount',
        'decimals',
      ],
      ['meta', 'postTokenBalances', KEYPATH_WILDCARD, 'accountIndex'],
      [
        'meta',
        'postTokenBalances',
        KEYPATH_WILDCARD,
        'uiTokenAmount',
        'decimals',
      ],
      ['meta', 'rewards', KEYPATH_WILDCARD, 'commission'],
      for (final c in innerInstructionsConfigs)
        ['meta', 'innerInstructions', KEYPATH_WILDCARD, ...c],
      for (final c in messageConfig) ['transaction', 'message', ...c],
    ],
    'getVersion': [
      ['feature-set'],
    ],
    'getVoteAccounts': [
      ['current', KEYPATH_WILDCARD, 'commission'],
      ['delinquent', KEYPATH_WILDCARD, 'commission'],
    ],
    'simulateTransaction': [
      ['value', 'loadedAccountsDataSize'],
      for (final c in jsonParsedAccountsConfigs)
        ['value', 'accounts', KEYPATH_WILDCARD, ...c],
      for (final c in innerInstructionsConfigs)
        ['value', 'innerInstructions', KEYPATH_WILDCARD, ...c],
    ],
  };

  return _memoizedKeypaths!;
}
