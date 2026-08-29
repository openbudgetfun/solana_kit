// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the MplCore program.

/// InvalidSystemProgram: Invalid System Program
/// Message: "Invalid System Program"
const int mplCoreErrorInvalidSystemProgram = 0x0; // 0

/// DeserializationError: Error deserializing account
/// Message: "Error deserializing account"
const int mplCoreErrorDeserializationError = 0x1; // 1

/// SerializationError: Error serializing account
/// Message: "Error serializing account"
const int mplCoreErrorSerializationError = 0x2; // 2

/// PluginsNotInitialized: Plugins not initialized
/// Message: "Plugins not initialized"
const int mplCoreErrorPluginsNotInitialized = 0x3; // 3

/// PluginNotFound: Plugin not found
/// Message: "Plugin not found"
const int mplCoreErrorPluginNotFound = 0x4; // 4

/// NumericalOverflow: Numerical Overflow
/// Message: "Numerical Overflow"
const int mplCoreErrorNumericalOverflow = 0x5; // 5

/// IncorrectAccount: Incorrect account
/// Message: "Incorrect account"
const int mplCoreErrorIncorrectAccount = 0x6; // 6

/// IncorrectAssetHash: Incorrect asset hash
/// Message: "Incorrect asset hash"
const int mplCoreErrorIncorrectAssetHash = 0x7; // 7

/// InvalidPlugin: Invalid Plugin
/// Message: "Invalid Plugin"
const int mplCoreErrorInvalidPlugin = 0x8; // 8

/// InvalidAuthority: Invalid Authority
/// Message: "Invalid Authority"
const int mplCoreErrorInvalidAuthority = 0x9; // 9

/// AssetIsFrozen: Cannot transfer a frozen asset
/// Message: "Cannot transfer a frozen asset"
const int mplCoreErrorAssetIsFrozen = 0xa; // 10

/// MissingCompressionProof: Missing compression proof
/// Message: "Missing compression proof"
const int mplCoreErrorMissingCompressionProof = 0xb; // 11

/// CannotMigrateMasterWithSupply: Cannot migrate a master edition used for prints
/// Message: "Cannot migrate a master edition used for prints"
const int mplCoreErrorCannotMigrateMasterWithSupply = 0xc; // 12

/// CannotMigratePrints: Cannot migrate a print edition
/// Message: "Cannot migrate a print edition"
const int mplCoreErrorCannotMigratePrints = 0xd; // 13

/// CannotBurnCollection: Cannot burn a collection NFT
/// Message: "Cannot burn a collection NFT"
const int mplCoreErrorCannotBurnCollection = 0xe; // 14

/// PluginAlreadyExists: Plugin already exists
/// Message: "Plugin already exists"
const int mplCoreErrorPluginAlreadyExists = 0xf; // 15

/// NumericalOverflowError: Numerical overflow
/// Message: "Numerical overflow"
const int mplCoreErrorNumericalOverflowError = 0x10; // 16

/// AlreadyCompressed: Already compressed account
/// Message: "Already compressed account"
const int mplCoreErrorAlreadyCompressed = 0x11; // 17

/// AlreadyDecompressed: Already decompressed account
/// Message: "Already decompressed account"
const int mplCoreErrorAlreadyDecompressed = 0x12; // 18

/// InvalidCollection: Invalid Collection passed in
/// Message: "Invalid Collection passed in"
const int mplCoreErrorInvalidCollection = 0x13; // 19

/// MissingUpdateAuthority: Missing update authority
/// Message: "Missing update authority"
const int mplCoreErrorMissingUpdateAuthority = 0x14; // 20

/// MissingNewOwner: Missing new owner
/// Message: "Missing new owner"
const int mplCoreErrorMissingNewOwner = 0x15; // 21

/// MissingSystemProgram: Missing system program
/// Message: "Missing system program"
const int mplCoreErrorMissingSystemProgram = 0x16; // 22

/// NotAvailable: Feature not available
/// Message: "Feature not available"
const int mplCoreErrorNotAvailable = 0x17; // 23

/// InvalidAsset: Invalid Asset passed in
/// Message: "Invalid Asset passed in"
const int mplCoreErrorInvalidAsset = 0x18; // 24

/// MissingCollection: Missing collection
/// Message: "Missing collection"
const int mplCoreErrorMissingCollection = 0x19; // 25

/// NoApprovals: Neither the asset or any plugins have approved this operation
/// Message: "Neither the asset or any plugins have approved this operation"
const int mplCoreErrorNoApprovals = 0x1a; // 26

/// CannotRedelegate: Plugin Manager cannot redelegate a delegated plugin without revoking first
/// Message: "Plugin Manager cannot redelegate a delegated plugin without revoking first"
const int mplCoreErrorCannotRedelegate = 0x1b; // 27

/// InvalidPluginSetting: Invalid setting for plugin
/// Message: "Invalid setting for plugin"
const int mplCoreErrorInvalidPluginSetting = 0x1c; // 28

/// ConflictingAuthority: Cannot specify both an update authority and collection on an asset
/// Message: "Cannot specify both an update authority and collection on an asset"
const int mplCoreErrorConflictingAuthority = 0x1d; // 29

/// InvalidLogWrapperProgram: Invalid Log Wrapper Program
/// Message: "Invalid Log Wrapper Program"
const int mplCoreErrorInvalidLogWrapperProgram = 0x1e; // 30

/// ExternalPluginAdapterNotFound: External Plugin Adapter not found
/// Message: "External Plugin Adapter not found"
const int mplCoreErrorExternalPluginAdapterNotFound = 0x1f; // 31

/// ExternalPluginAdapterAlreadyExists: External Plugin Adapter already exists
/// Message: "External Plugin Adapter already exists"
const int mplCoreErrorExternalPluginAdapterAlreadyExists = 0x20; // 32

/// MissingAsset: Missing asset needed for extra account PDA derivation
/// Message: "Missing asset needed for extra account PDA derivation"
const int mplCoreErrorMissingAsset = 0x21; // 33

/// MissingExternalPluginAdapterAccount: Missing account needed for external plugin adapter
/// Message: "Missing account needed for external plugin adapter"
const int mplCoreErrorMissingExternalPluginAdapterAccount = 0x22; // 34

/// OracleCanRejectOnly: Oracle external plugin adapter can only be configured to reject
/// Message: "Oracle external plugin adapter can only be configured to reject"
const int mplCoreErrorOracleCanRejectOnly = 0x23; // 35

/// RequiresLifecycleCheck: External plugin adapter must have at least one lifecycle check
/// Message: "External plugin adapter must have at least one lifecycle check"
const int mplCoreErrorRequiresLifecycleCheck = 0x24; // 36

/// DuplicateLifecycleChecks: Duplicate lifecycle checks were provided for external plugin adapter
/// Message: "Duplicate lifecycle checks were provided for external plugin adapter "
const int mplCoreErrorDuplicateLifecycleChecks = 0x25; // 37

/// InvalidOracleAccountData: Could not read from oracle account
/// Message: "Could not read from oracle account"
const int mplCoreErrorInvalidOracleAccountData = 0x26; // 38

/// UninitializedOracleAccount: Oracle account is uninitialized
/// Message: "Oracle account is uninitialized"
const int mplCoreErrorUninitializedOracleAccount = 0x27; // 39

/// MissingSigner: Missing required signer for operation
/// Message: "Missing required signer for operation"
const int mplCoreErrorMissingSigner = 0x28; // 40

/// InvalidPluginOperation: Invalid plugin operation
/// Message: "Invalid plugin operation"
const int mplCoreErrorInvalidPluginOperation = 0x29; // 41

/// CollectionMustBeEmpty: Collection must be empty to be burned
/// Message: "Collection must be empty to be burned"
const int mplCoreErrorCollectionMustBeEmpty = 0x2a; // 42

/// TwoDataSources: Two data sources provided, only one is allowed
/// Message: "Two data sources provided, only one is allowed"
const int mplCoreErrorTwoDataSources = 0x2b; // 43

/// UnsupportedOperation: External Plugin does not support this operation
/// Message: "External Plugin does not support this operation"
const int mplCoreErrorUnsupportedOperation = 0x2c; // 44

/// NoDataSources: No data sources provided, one is required
/// Message: "No data sources provided, one is required"
const int mplCoreErrorNoDataSources = 0x2d; // 45

/// InvalidPluginAdapterTarget: This plugin adapter cannot be added to an Asset
/// Message: "This plugin adapter cannot be added to an Asset"
const int mplCoreErrorInvalidPluginAdapterTarget = 0x2e; // 46

/// CannotAddDataSection: Cannot add a Data Section without a linked external plugin
/// Message: "Cannot add a Data Section without a linked external plugin"
const int mplCoreErrorCannotAddDataSection = 0x2f; // 47

/// PermanentDelegatesPreventMove: Cannot move asset to collection with permanent delegates
/// Message: "Cannot move asset to collection with permanent delegates"
const int mplCoreErrorPermanentDelegatesPreventMove = 0x30; // 48

/// InvalidExecutePda: Invalid Signing PDA for Asset or Collection Execute
/// Message: "Invalid Signing PDA for Asset or Collection Execute"
const int mplCoreErrorInvalidExecutePda = 0x31; // 49

/// BlockedByBubblegumV2: Bubblegum V2 Plugin limits other plugins
/// Message: "Bubblegum V2 Plugin limits other plugins"
const int mplCoreErrorBlockedByBubblegumV2 = 0x32; // 50

/// AgentIdentityMustSign: Agent Identity Program must sign
/// Message: "Agent Identity Program must sign"
const int mplCoreErrorAgentIdentityMustSign = 0x33; // 51

/// GroupMustBeEmpty: Group must be empty to be closed
/// Message: "Group must be empty to be closed"
const int mplCoreErrorGroupMustBeEmpty = 0x34; // 52

/// DuplicateEntry: Duplicate entry provided when adding relationships to a group
/// Message: "Duplicate entry provided when adding relationships to a group"
const int mplCoreErrorDuplicateEntry = 0x35; // 53

/// GroupVectorFull: Group vector is at maximum capacity
/// Message: "Group vector is at maximum capacity"
const int mplCoreErrorGroupVectorFull = 0x36; // 54

/// GroupNestingDepthExceeded: Group nesting depth exceeded
/// Message: "Group nesting depth exceeded"
const int mplCoreErrorGroupNestingDepthExceeded = 0x37; // 55

/// InconsistentGroupRelationship: Bidirectional group relationship is inconsistent
/// Message: "Bidirectional group relationship is inconsistent"
const int mplCoreErrorInconsistentGroupRelationship = 0x38; // 56

/// Map of error codes to human-readable messages.
const Map<int, String> _mplCoreErrorMessages = {
  mplCoreErrorInvalidSystemProgram: 'Invalid System Program',
  mplCoreErrorDeserializationError: 'Error deserializing account',
  mplCoreErrorSerializationError: 'Error serializing account',
  mplCoreErrorPluginsNotInitialized: 'Plugins not initialized',
  mplCoreErrorPluginNotFound: 'Plugin not found',
  mplCoreErrorNumericalOverflow: 'Numerical Overflow',
  mplCoreErrorIncorrectAccount: 'Incorrect account',
  mplCoreErrorIncorrectAssetHash: 'Incorrect asset hash',
  mplCoreErrorInvalidPlugin: 'Invalid Plugin',
  mplCoreErrorInvalidAuthority: 'Invalid Authority',
  mplCoreErrorAssetIsFrozen: 'Cannot transfer a frozen asset',
  mplCoreErrorMissingCompressionProof: 'Missing compression proof',
  mplCoreErrorCannotMigrateMasterWithSupply:
      'Cannot migrate a master edition used for prints',
  mplCoreErrorCannotMigratePrints: 'Cannot migrate a print edition',
  mplCoreErrorCannotBurnCollection: 'Cannot burn a collection NFT',
  mplCoreErrorPluginAlreadyExists: 'Plugin already exists',
  mplCoreErrorNumericalOverflowError: 'Numerical overflow',
  mplCoreErrorAlreadyCompressed: 'Already compressed account',
  mplCoreErrorAlreadyDecompressed: 'Already decompressed account',
  mplCoreErrorInvalidCollection: 'Invalid Collection passed in',
  mplCoreErrorMissingUpdateAuthority: 'Missing update authority',
  mplCoreErrorMissingNewOwner: 'Missing new owner',
  mplCoreErrorMissingSystemProgram: 'Missing system program',
  mplCoreErrorNotAvailable: 'Feature not available',
  mplCoreErrorInvalidAsset: 'Invalid Asset passed in',
  mplCoreErrorMissingCollection: 'Missing collection',
  mplCoreErrorNoApprovals:
      'Neither the asset or any plugins have approved this operation',
  mplCoreErrorCannotRedelegate:
      'Plugin Manager cannot redelegate a delegated plugin without revoking first',
  mplCoreErrorInvalidPluginSetting: 'Invalid setting for plugin',
  mplCoreErrorConflictingAuthority:
      'Cannot specify both an update authority and collection on an asset',
  mplCoreErrorInvalidLogWrapperProgram: 'Invalid Log Wrapper Program',
  mplCoreErrorExternalPluginAdapterNotFound:
      'External Plugin Adapter not found',
  mplCoreErrorExternalPluginAdapterAlreadyExists:
      'External Plugin Adapter already exists',
  mplCoreErrorMissingAsset:
      'Missing asset needed for extra account PDA derivation',
  mplCoreErrorMissingExternalPluginAdapterAccount:
      'Missing account needed for external plugin adapter',
  mplCoreErrorOracleCanRejectOnly:
      'Oracle external plugin adapter can only be configured to reject',
  mplCoreErrorRequiresLifecycleCheck:
      'External plugin adapter must have at least one lifecycle check',
  mplCoreErrorDuplicateLifecycleChecks:
      'Duplicate lifecycle checks were provided for external plugin adapter ',
  mplCoreErrorInvalidOracleAccountData: 'Could not read from oracle account',
  mplCoreErrorUninitializedOracleAccount: 'Oracle account is uninitialized',
  mplCoreErrorMissingSigner: 'Missing required signer for operation',
  mplCoreErrorInvalidPluginOperation: 'Invalid plugin operation',
  mplCoreErrorCollectionMustBeEmpty: 'Collection must be empty to be burned',
  mplCoreErrorTwoDataSources: 'Two data sources provided, only one is allowed',
  mplCoreErrorUnsupportedOperation:
      'External Plugin does not support this operation',
  mplCoreErrorNoDataSources: 'No data sources provided, one is required',
  mplCoreErrorInvalidPluginAdapterTarget:
      'This plugin adapter cannot be added to an Asset',
  mplCoreErrorCannotAddDataSection:
      'Cannot add a Data Section without a linked external plugin',
  mplCoreErrorPermanentDelegatesPreventMove:
      'Cannot move asset to collection with permanent delegates',
  mplCoreErrorInvalidExecutePda:
      'Invalid Signing PDA for Asset or Collection Execute',
  mplCoreErrorBlockedByBubblegumV2: 'Bubblegum V2 Plugin limits other plugins',
  mplCoreErrorAgentIdentityMustSign: 'Agent Identity Program must sign',
  mplCoreErrorGroupMustBeEmpty: 'Group must be empty to be closed',
  mplCoreErrorDuplicateEntry:
      'Duplicate entry provided when adding relationships to a group',
  mplCoreErrorGroupVectorFull: 'Group vector is at maximum capacity',
  mplCoreErrorGroupNestingDepthExceeded: 'Group nesting depth exceeded',
  mplCoreErrorInconsistentGroupRelationship:
      'Bidirectional group relationship is inconsistent',
};

/// Get the error message for a MplCore program error code.
String? getMplCoreErrorMessage(int code) {
  return _mplCoreErrorMessages[code];
}

/// Check if an error code belongs to the MplCore program.
bool isMplCoreError(int code) {
  return _mplCoreErrorMessages.containsKey(code);
}
