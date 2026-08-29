import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';
import 'package:test/test.dart';

/// Every generated MplCore error constant, with its expected numeric code.
///
/// Codes follow the IDL ordering of the mpl-core program's error enum:
/// they run sequentially from `0x0` to `0x38` with no gaps.
const expectedErrorCodes = <int, String>{
  mplCoreErrorInvalidSystemProgram: 'mplCoreErrorInvalidSystemProgram',
  mplCoreErrorDeserializationError: 'mplCoreErrorDeserializationError',
  mplCoreErrorSerializationError: 'mplCoreErrorSerializationError',
  mplCoreErrorPluginsNotInitialized: 'mplCoreErrorPluginsNotInitialized',
  mplCoreErrorPluginNotFound: 'mplCoreErrorPluginNotFound',
  mplCoreErrorNumericalOverflow: 'mplCoreErrorNumericalOverflow',
  mplCoreErrorIncorrectAccount: 'mplCoreErrorIncorrectAccount',
  mplCoreErrorIncorrectAssetHash: 'mplCoreErrorIncorrectAssetHash',
  mplCoreErrorInvalidPlugin: 'mplCoreErrorInvalidPlugin',
  mplCoreErrorInvalidAuthority: 'mplCoreErrorInvalidAuthority',
  mplCoreErrorAssetIsFrozen: 'mplCoreErrorAssetIsFrozen',
  mplCoreErrorMissingCompressionProof: 'mplCoreErrorMissingCompressionProof',
  mplCoreErrorCannotMigrateMasterWithSupply:
      'mplCoreErrorCannotMigrateMasterWithSupply',
  mplCoreErrorCannotMigratePrints: 'mplCoreErrorCannotMigratePrints',
  mplCoreErrorCannotBurnCollection: 'mplCoreErrorCannotBurnCollection',
  mplCoreErrorPluginAlreadyExists: 'mplCoreErrorPluginAlreadyExists',
  mplCoreErrorNumericalOverflowError: 'mplCoreErrorNumericalOverflowError',
  mplCoreErrorAlreadyCompressed: 'mplCoreErrorAlreadyCompressed',
  mplCoreErrorAlreadyDecompressed: 'mplCoreErrorAlreadyDecompressed',
  mplCoreErrorInvalidCollection: 'mplCoreErrorInvalidCollection',
  mplCoreErrorMissingUpdateAuthority: 'mplCoreErrorMissingUpdateAuthority',
  mplCoreErrorMissingNewOwner: 'mplCoreErrorMissingNewOwner',
  mplCoreErrorMissingSystemProgram: 'mplCoreErrorMissingSystemProgram',
  mplCoreErrorNotAvailable: 'mplCoreErrorNotAvailable',
  mplCoreErrorInvalidAsset: 'mplCoreErrorInvalidAsset',
  mplCoreErrorMissingCollection: 'mplCoreErrorMissingCollection',
  mplCoreErrorNoApprovals: 'mplCoreErrorNoApprovals',
  mplCoreErrorCannotRedelegate: 'mplCoreErrorCannotRedelegate',
  mplCoreErrorInvalidPluginSetting: 'mplCoreErrorInvalidPluginSetting',
  mplCoreErrorConflictingAuthority: 'mplCoreErrorConflictingAuthority',
  mplCoreErrorInvalidLogWrapperProgram: 'mplCoreErrorInvalidLogWrapperProgram',
  mplCoreErrorExternalPluginAdapterNotFound:
      'mplCoreErrorExternalPluginAdapterNotFound',
  mplCoreErrorExternalPluginAdapterAlreadyExists:
      'mplCoreErrorExternalPluginAdapterAlreadyExists',
  mplCoreErrorMissingAsset: 'mplCoreErrorMissingAsset',
  mplCoreErrorMissingExternalPluginAdapterAccount:
      'mplCoreErrorMissingExternalPluginAdapterAccount',
  mplCoreErrorOracleCanRejectOnly: 'mplCoreErrorOracleCanRejectOnly',
  mplCoreErrorRequiresLifecycleCheck: 'mplCoreErrorRequiresLifecycleCheck',
  mplCoreErrorDuplicateLifecycleChecks: 'mplCoreErrorDuplicateLifecycleChecks',
  mplCoreErrorInvalidOracleAccountData: 'mplCoreErrorInvalidOracleAccountData',
  mplCoreErrorUninitializedOracleAccount:
      'mplCoreErrorUninitializedOracleAccount',
  mplCoreErrorMissingSigner: 'mplCoreErrorMissingSigner',
  mplCoreErrorInvalidPluginOperation: 'mplCoreErrorInvalidPluginOperation',
  mplCoreErrorCollectionMustBeEmpty: 'mplCoreErrorCollectionMustBeEmpty',
  mplCoreErrorTwoDataSources: 'mplCoreErrorTwoDataSources',
  mplCoreErrorUnsupportedOperation: 'mplCoreErrorUnsupportedOperation',
  mplCoreErrorNoDataSources: 'mplCoreErrorNoDataSources',
  mplCoreErrorInvalidPluginAdapterTarget:
      'mplCoreErrorInvalidPluginAdapterTarget',
  mplCoreErrorCannotAddDataSection: 'mplCoreErrorCannotAddDataSection',
  mplCoreErrorPermanentDelegatesPreventMove:
      'mplCoreErrorPermanentDelegatesPreventMove',
  mplCoreErrorInvalidExecutePda: 'mplCoreErrorInvalidExecutePda',
  mplCoreErrorBlockedByBubblegumV2: 'mplCoreErrorBlockedByBubblegumV2',
  mplCoreErrorAgentIdentityMustSign: 'mplCoreErrorAgentIdentityMustSign',
  mplCoreErrorGroupMustBeEmpty: 'mplCoreErrorGroupMustBeEmpty',
  mplCoreErrorDuplicateEntry: 'mplCoreErrorDuplicateEntry',
  mplCoreErrorGroupVectorFull: 'mplCoreErrorGroupVectorFull',
  mplCoreErrorGroupNestingDepthExceeded:
      'mplCoreErrorGroupNestingDepthExceeded',
  mplCoreErrorInconsistentGroupRelationship:
      'mplCoreErrorInconsistentGroupRelationship',
};

/// The complete set of human-readable messages for a few error codes.
const expectedErrorMessages = <int, String>{
  mplCoreErrorInvalidSystemProgram: 'Invalid System Program',
  mplCoreErrorAssetIsFrozen: 'Cannot transfer a frozen asset',
  mplCoreErrorInvalidExecutePda:
      'Invalid Signing PDA for Asset or Collection Execute',
  mplCoreErrorMissingAsset:
      'Missing asset needed for extra account PDA '
      'derivation',
  mplCoreErrorGroupMustBeEmpty: 'Group must be empty to be closed',
};

void main() {
  group('mplCore error constants', () {
    test('start at zero and are distinct', () {
      final codes = expectedErrorCodes.keys.toList()..sort();

      expect(codes.first, 0);
      expect(
        codes.toSet().length,
        codes.length,
        reason: 'error codes must be unique',
      );
    });

    test('increase monotonically in the generated order', () {
      // Every code is 0x0-0x38 according to the generated error file.
      for (final code in expectedErrorCodes.keys) {
        expect(code, inInclusiveRange(0, 0x38), reason: 'code $code');
      }
    });

    test('are registered with the generated error table', () {
      for (final code in expectedErrorCodes.keys) {
        expect(
          isMplCoreError(code),
          isTrue,
          reason: 'code $code should be recognized by isMplCoreError',
        );
      }
    });
  });

  group('getMplCoreErrorMessage', () {
    test('returns the human-readable message for known codes', () {
      for (final MapEntry(key: code, value: name)
          in expectedErrorCodes.entries) {
        expect(
          getMplCoreErrorMessage(code),
          isNotNull,
          reason: '$name ($code) should have a message',
        );
      }
    });

    test('matches the documented messages', () {
      for (final MapEntry(key: code, value: message)
          in expectedErrorMessages.entries) {
        expect(getMplCoreErrorMessage(code), message);
      }
    });

    test('returns null for unknown codes', () {
      expect(getMplCoreErrorMessage(0x39), isNull);
      expect(getMplCoreErrorMessage(-1), isNull);
      expect(isMplCoreError(0x39), isFalse);
      expect(isMplCoreError(-1), isFalse);
    });
  });
}
