import 'package:solana_kit_rpc_transformers/src/tree_traversal.dart';

/// A mapping from API method names to the key paths whose values should
/// remain as [int] (rather than being upcast to [BigInt]).
typedef AllowedNumericKeypaths = Map<String, List<KeyPath>>;

/// Numeric values nested in `jsonParsed` token accounts.
final List<KeyPath> jsonParsedTokenAccountsConfigs = [
  // parsed Token/Token22 token account
  ['data', 'parsed', 'info', 'tokenAmount', 'decimals'],
  ['data', 'parsed', 'info', 'tokenAmount', 'uiAmount'],
  ['data', 'parsed', 'info', 'rentExemptReserve', 'decimals'],
  ['data', 'parsed', 'info', 'rentExemptReserve', 'uiAmount'],
  ['data', 'parsed', 'info', 'delegatedAmount', 'decimals'],
  ['data', 'parsed', 'info', 'delegatedAmount', 'uiAmount'],
  [
    'data',
    'parsed',
    'info',
    'extensions',
    KEYPATH_WILDCARD,
    'state',
    'olderTransferFee',
    'transferFeeBasisPoints',
  ],
  [
    'data',
    'parsed',
    'info',
    'extensions',
    KEYPATH_WILDCARD,
    'state',
    'newerTransferFee',
    'transferFeeBasisPoints',
  ],
  [
    'data',
    'parsed',
    'info',
    'extensions',
    KEYPATH_WILDCARD,
    'state',
    'preUpdateAverageRate',
  ],
  [
    'data',
    'parsed',
    'info',
    'extensions',
    KEYPATH_WILDCARD,
    'state',
    'currentRate',
  ],
];

/// Numeric values nested in `jsonParsed` accounts (includes token accounts).
final List<KeyPath> jsonParsedAccountsConfigs = [
  ...jsonParsedTokenAccountsConfigs,
  // parsed AddressTableLookup account
  ['data', 'parsed', 'info', 'lastExtendedSlotStartIndex'],
  // parsed Config account
  ['data', 'parsed', 'info', 'slashPenalty'],
  ['data', 'parsed', 'info', 'warmupCooldownRate'],
  // parsed Token/Token22 mint account
  ['data', 'parsed', 'info', 'decimals'],
  // parsed Token/Token22 multisig account
  ['data', 'parsed', 'info', 'numRequiredSigners'],
  ['data', 'parsed', 'info', 'numValidSigners'],
  // parsed Stake account
  ['data', 'parsed', 'info', 'stake', 'delegation', 'warmupCooldownRate'],
  // parsed Sysvar rent account
  ['data', 'parsed', 'info', 'exemptionThreshold'],
  ['data', 'parsed', 'info', 'burnPercent'],
  // parsed Vote account
  ['data', 'parsed', 'info', 'commission'],
  ['data', 'parsed', 'info', 'votes', KEYPATH_WILDCARD, 'confirmationCount'],
];

/// Numeric values in inner instructions.
final List<KeyPath> innerInstructionsConfigs = [
  ['index'],
  ['instructions', KEYPATH_WILDCARD, 'accounts', KEYPATH_WILDCARD],
  ['instructions', KEYPATH_WILDCARD, 'programIdIndex'],
  ['instructions', KEYPATH_WILDCARD, 'stackHeight'],
];

/// Numeric values in transaction messages.
final List<KeyPath> messageConfig = [
  [
    'addressTableLookups',
    KEYPATH_WILDCARD,
    'writableIndexes',
    KEYPATH_WILDCARD,
  ],
  [
    'addressTableLookups',
    KEYPATH_WILDCARD,
    'readonlyIndexes',
    KEYPATH_WILDCARD,
  ],
  ['header', 'numReadonlySignedAccounts'],
  ['header', 'numReadonlyUnsignedAccounts'],
  ['header', 'numRequiredSignatures'],
  ['instructions', KEYPATH_WILDCARD, 'accounts', KEYPATH_WILDCARD],
  ['instructions', KEYPATH_WILDCARD, 'programIdIndex'],
  ['instructions', KEYPATH_WILDCARD, 'stackHeight'],
];
