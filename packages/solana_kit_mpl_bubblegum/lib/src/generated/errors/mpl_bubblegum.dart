// Auto-generated. Do not edit.
// ignore_for_file: type=lint

/// MPL Bubblegum error codes.
///
/// These error codes are returned by the Bubblegum program when
/// instructions fail. They can be matched against the hex error
/// code returned in the transaction logs.
class MplBubblegumError {
  MplBubblegumError._();

  /// The asset owner does not match.
  static const int assetOwnerMismatch = 0x1770;

  /// Public key mismatch.
  static const int publicKeyMismatch = 0x1771;

  /// Hashing mismatch within leaf schema.
  static const int hashingMismatch = 0x1772;

  /// Unsupported schema version.
  static const int unsupportedSchemaVersion = 0x1773;

  /// Creator shares must sum to 100.
  static const int creatorShareSum = 0x1774;

  /// No duplicate creator addresses in metadata.
  static const int duplicateCreatorAddress = 0x1775;

  /// Creator did not verify the metadata.
  static const int creatorNotVerified = 0x1776;

  /// Creator not found in creator Vec.
  static const int creatorNotFound = 0x1777;

  /// No creators in creator Vec.
  static const int noCreators = 0x1778;

  /// User-provided creator Vec must result in same user-provided creator hash.
  static const int creatorHashMismatch = 0x1779;

  /// User-provided metadata must result in same user-provided data hash.
  static const int dataHashMismatch = 0x177a;

  /// Creators list too long.
  static const int creatorsTooLong = 0x177b;

  /// Name in metadata is too long.
  static const int nameTooLong = 0x177c;

  /// Symbol in metadata is too long.
  static const int symbolTooLong = 0x177d;

  /// URI in metadata is too long.
  static const int uriTooLong = 0x177e;

  /// Basis points in metadata cannot exceed 10000.
  static const int basisPointsExceedMax = 0x177f;

  /// Tree creator or tree delegate must sign.
  static const int treeCreatorOrDelegateMustSign = 0x1780;

  /// Not enough unapproved mints left.
  static const int insufficientMintApprovals = 0x1781;

  /// Numerical overflow error.
  static const int numericalOverflow = 0x1782;

  /// Incorrect account owner.
  static const int incorrectOwner = 0x1783;

  /// Cannot verify collection in this instruction.
  static const int cannotVerifyCollection = 0x1784;

  /// Collection not found on metadata.
  static const int collectionNotFound = 0x1785;

  /// Collection item is already verified.
  static const int collectionAlreadyVerified = 0x1786;

  /// Collection item is already unverified.
  static const int collectionAlreadyUnverified = 0x1787;

  /// Incorrect leaf metadata update authority.
  static const int incorrectMetadataUpdateAuthority = 0x1788;

  /// This transaction must be signed by either the leaf owner or leaf delegate.
  static const int ownerOrDelegateMismatch = 0x1789;

  /// Collection must be a sized collection.
  static const int collectionMustBeSized = 0x178a;

  /// Metadata mint does not match collection mint.
  static const int metadataMintMismatch = 0x178b;

  /// Invalid collection authority.
  static const int invalidCollectionAuthority = 0x178c;

  /// Invalid delegate record PDA derivation.
  static const int invalidDelegateRecordPda = 0x178d;

  /// Edition account doesn't match collection.
  static const int editionMismatch = 0x178e;

  /// Collection must be a unique master edition v2.
  static const int collectionMustBeMasterEdition = 0x178f;

  /// Could not convert external error to BubblegumError.
  static const int externalErrorConversion = 0x1790;

  /// Decompression is disabled for this tree.
  static const int decompressionDisabled = 0x1791;

  /// Missing collection mint account.
  static const int missingCollectionMint = 0x1792;

  /// Missing collection metadata account.
  static const int missingCollectionMetadata = 0x1793;

  /// Collection mismatch.
  static const int collectionMismatch = 0x1794;

  /// Metadata not mutable.
  static const int metadataNotMutable = 0x1795;

  /// Can only update primary sale to true.
  static const int primarySaleCanOnlyBeFlipped = 0x1796;

  /// Creator did not unverify the metadata.
  static const int creatorDidNotUnverify = 0x1797;

  /// Only NonFungible standard is supported.
  static const int onlyNonFungibleSupported = 0x1798;

  /// Canopy size should be set bigger for this tree.
  static const int canopySizeTooSmall = 0x1799;

  /// Invalid log wrapper program.
  static const int invalidLogWrapper = 0x179a;

  /// Invalid compression program.
  static const int invalidCompressionProgram = 0x179b;

  /// Leaf must be delegated to someone other than the leaf owner.
  static const int leafMustBeDelegated = 0x179c;

  /// Asset is frozen.
  static const int assetFrozen = 0x179d;

  /// Asset is non-transferable.
  static const int assetNonTransferable = 0x179e;

  /// Invalid authority.
  static const int invalidAuthority = 0x179f;

  /// Collection is frozen.
  static const int collectionFrozen = 0x17a0;

  /// Core collections must have the Bubblegum V2 plugin on them.
  static const int coreCollectionsMustHavePlugin = 0x17a1;

  /// Feature not currently available.
  static const int featureNotAvailable = 0x17a2;

  /// Missing collection account.
  static const int missingCollectionAccount = 0x17a3;

  /// Asset data length too long.
  static const int assetDataTooLong = 0x17a4;

  /// Item is already in the collection.
  static const int alreadyInCollection = 0x17a5;

  /// Item is already not in a collection.
  static const int alreadyNotInCollection = 0x17a6;

  /// Missing mpl-core CPI signer account.
  static const int missingMplCoreCpiSigner = 0x17a7;

  /// Asset is not frozen.
  static const int assetNotFrozen = 0x17a8;
}

const Map<int, String> _mplBubblegumErrorMessages = {
  MplBubblegumError.assetOwnerMismatch: 'Asset owner does not match',
  MplBubblegumError.publicKeyMismatch: 'Public key mismatch',
  MplBubblegumError.hashingMismatch: 'Hashing mismatch within leaf schema',
  MplBubblegumError.unsupportedSchemaVersion: 'Unsupported schema version',
  MplBubblegumError.creatorShareSum: 'Creator shares must sum to 100',
  MplBubblegumError.duplicateCreatorAddress:
      'No duplicate creator addresses in metadata',
  MplBubblegumError.creatorNotVerified: 'Creator did not verify the metadata',
  MplBubblegumError.creatorNotFound: 'Creator not found in creator Vec',
  MplBubblegumError.noCreators: 'No creators in creator Vec',
  MplBubblegumError.creatorHashMismatch:
      'User-provided creator Vec must result in same user-provided creator hash',
  MplBubblegumError.dataHashMismatch:
      'User-provided metadata must result in same user-provided data hash',
  MplBubblegumError.creatorsTooLong: 'Creators list too long',
  MplBubblegumError.nameTooLong: 'Name in metadata is too long',
  MplBubblegumError.symbolTooLong: 'Symbol in metadata is too long',
  MplBubblegumError.uriTooLong: 'URI in metadata is too long',
  MplBubblegumError.basisPointsExceedMax:
      'Basis points in metadata cannot exceed 10000',
  MplBubblegumError.treeCreatorOrDelegateMustSign:
      'Tree creator or tree delegate must sign',
  MplBubblegumError.insufficientMintApprovals:
      'Not enough unapproved mints left',
  MplBubblegumError.numericalOverflow: 'Numerical overflow error',
  MplBubblegumError.incorrectOwner: 'Incorrect account owner',
  MplBubblegumError.cannotVerifyCollection:
      'Cannot verify collection in this instruction',
  MplBubblegumError.collectionNotFound: 'Collection not found on metadata',
  MplBubblegumError.collectionAlreadyVerified:
      'Collection item is already verified',
  MplBubblegumError.collectionAlreadyUnverified:
      'Collection item is already unverified',
  MplBubblegumError.incorrectMetadataUpdateAuthority:
      'Incorrect leaf metadata update authority',
  MplBubblegumError.ownerOrDelegateMismatch:
      'This transaction must be signed by either the leaf owner or leaf delegate',
  MplBubblegumError.collectionMustBeSized:
      'Collection must be a sized collection',
  MplBubblegumError.metadataMintMismatch:
      'Metadata mint does not match collection mint',
  MplBubblegumError.invalidCollectionAuthority: 'Invalid collection authority',
  MplBubblegumError.invalidDelegateRecordPda:
      'Invalid delegate record PDA derivation',
  MplBubblegumError.editionMismatch: "Edition account doesn't match collection",
  MplBubblegumError.collectionMustBeMasterEdition:
      'Collection must be a unique master edition v2',
  MplBubblegumError.externalErrorConversion:
      'Could not convert external error to BubblegumError',
  MplBubblegumError.decompressionDisabled:
      'Decompression is disabled for this tree',
  MplBubblegumError.missingCollectionMint: 'Missing collection mint account',
  MplBubblegumError.missingCollectionMetadata:
      'Missing collection metadata account',
  MplBubblegumError.collectionMismatch: 'Collection mismatch',
  MplBubblegumError.metadataNotMutable: 'Metadata not mutable',
  MplBubblegumError.primarySaleCanOnlyBeFlipped:
      'Can only update primary sale to true',
  MplBubblegumError.creatorDidNotUnverify:
      'Creator did not unverify the metadata',
  MplBubblegumError.onlyNonFungibleSupported:
      'Only NonFungible standard is supported',
  MplBubblegumError.canopySizeTooSmall:
      'Canopy size should be set bigger for this tree',
  MplBubblegumError.invalidLogWrapper: 'Invalid log wrapper program',
  MplBubblegumError.invalidCompressionProgram: 'Invalid compression program',
  MplBubblegumError.leafMustBeDelegated:
      'Leaf must be delegated to someone other than the leaf owner',
  MplBubblegumError.assetFrozen: 'Asset is frozen',
  MplBubblegumError.assetNonTransferable: 'Asset is non-transferable',
  MplBubblegumError.invalidAuthority: 'Invalid authority',
  MplBubblegumError.collectionFrozen: 'Collection is frozen',
  MplBubblegumError.coreCollectionsMustHavePlugin:
      'Core collections must have the Bubblegum V2 plugin on them',
  MplBubblegumError.featureNotAvailable: 'Feature not currently available',
  MplBubblegumError.missingCollectionAccount: 'Missing collection account',
  MplBubblegumError.assetDataTooLong: 'Asset data length too long',
  MplBubblegumError.alreadyInCollection: 'Item is already in the collection',
  MplBubblegumError.alreadyNotInCollection:
      'Item is already not in a collection',
  MplBubblegumError.missingMplCoreCpiSigner:
      'Missing mpl-core CPI signer account',
  MplBubblegumError.assetNotFrozen: 'Asset is not frozen',
};

/// Gets the error message for a given MPL Bubblegum error code.
///
/// Returns `null` if the error code is not a Bubblegum error.
String? getMplBubblegumErrorMessage(int errorCode) =>
    _mplBubblegumErrorMessages[errorCode];

/// Returns `true` if the given error code is an MPL Bubblegum error.
bool isMplBubblegumError(int errorCode) =>
    errorCode >= MplBubblegumError.assetOwnerMismatch &&
    errorCode <= MplBubblegumError.assetNotFrozen;
