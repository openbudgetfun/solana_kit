// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the MplTokenMetadata program.

/// InstructionUnpackError
const int mplTokenMetadataErrorInstructionUnpackError = 0x0; // 0

/// InstructionPackError
const int mplTokenMetadataErrorInstructionPackError = 0x1; // 1

/// NotRentExempt: Lamport balance below rent-exempt threshold
/// Message: "Lamport balance below rent-exempt threshold"
const int mplTokenMetadataErrorNotRentExempt = 0x2; // 2

/// AlreadyInitialized: Already initialized
/// Message: "Already initialized"
const int mplTokenMetadataErrorAlreadyInitialized = 0x3; // 3

/// Uninitialized: Uninitialized
/// Message: "Uninitialized"
const int mplTokenMetadataErrorUninitialized = 0x4; // 4

/// InvalidMetadataKey:  Metadata's key must match seed of ['metadata', program id, mint] provided
/// Message: " Metadata's key must match seed of ['metadata', program id, mint] provided"
const int mplTokenMetadataErrorInvalidMetadataKey = 0x5; // 5

/// InvalidEditionKey: Edition's key must match seed of ['metadata', program id, name, 'edition'] provided
/// Message: "Edition's key must match seed of ['metadata', program id, name, 'edition'] provided"
const int mplTokenMetadataErrorInvalidEditionKey = 0x6; // 6

/// UpdateAuthorityIncorrect: Update Authority given does not match
/// Message: "Update Authority given does not match"
const int mplTokenMetadataErrorUpdateAuthorityIncorrect = 0x7; // 7

/// UpdateAuthorityIsNotSigner: Update Authority needs to be signer to update metadata
/// Message: "Update Authority needs to be signer to update metadata"
const int mplTokenMetadataErrorUpdateAuthorityIsNotSigner = 0x8; // 8

/// NotMintAuthority: You must be the mint authority and signer on this transaction
/// Message: "You must be the mint authority and signer on this transaction"
const int mplTokenMetadataErrorNotMintAuthority = 0x9; // 9

/// InvalidMintAuthority: Mint authority provided does not match the authority on the mint
/// Message: "Mint authority provided does not match the authority on the mint"
const int mplTokenMetadataErrorInvalidMintAuthority = 0xa; // 10

/// NameTooLong: Name too long
/// Message: "Name too long"
const int mplTokenMetadataErrorNameTooLong = 0xb; // 11

/// SymbolTooLong: Symbol too long
/// Message: "Symbol too long"
const int mplTokenMetadataErrorSymbolTooLong = 0xc; // 12

/// UriTooLong: URI too long
/// Message: "URI too long"
const int mplTokenMetadataErrorUriTooLong = 0xd; // 13

/// UpdateAuthorityMustBeEqualToMetadataAuthorityAndSigner
const int
mplTokenMetadataErrorUpdateAuthorityMustBeEqualToMetadataAuthorityAndSigner =
    0xe; // 14

/// MintMismatch: Mint given does not match mint on Metadata
/// Message: "Mint given does not match mint on Metadata"
const int mplTokenMetadataErrorMintMismatch = 0xf; // 15

/// EditionsMustHaveExactlyOneToken: Editions must have exactly one token
/// Message: "Editions must have exactly one token"
const int mplTokenMetadataErrorEditionsMustHaveExactlyOneToken = 0x10; // 16

/// MaxEditionsMintedAlready
const int mplTokenMetadataErrorMaxEditionsMintedAlready = 0x11; // 17

/// TokenMintToFailed
const int mplTokenMetadataErrorTokenMintToFailed = 0x12; // 18

/// MasterRecordMismatch
const int mplTokenMetadataErrorMasterRecordMismatch = 0x13; // 19

/// DestinationMintMismatch
const int mplTokenMetadataErrorDestinationMintMismatch = 0x14; // 20

/// EditionAlreadyMinted
const int mplTokenMetadataErrorEditionAlreadyMinted = 0x15; // 21

/// PrintingMintDecimalsShouldBeZero
const int mplTokenMetadataErrorPrintingMintDecimalsShouldBeZero = 0x16; // 22

/// OneTimePrintingAuthorizationMintDecimalsShouldBeZero
const int
mplTokenMetadataErrorOneTimePrintingAuthorizationMintDecimalsShouldBeZero =
    0x17; // 23

/// EditionMintDecimalsShouldBeZero: EditionMintDecimalsShouldBeZero
/// Message: "EditionMintDecimalsShouldBeZero"
const int mplTokenMetadataErrorEditionMintDecimalsShouldBeZero = 0x18; // 24

/// TokenBurnFailed
const int mplTokenMetadataErrorTokenBurnFailed = 0x19; // 25

/// TokenAccountOneTimeAuthMintMismatch
const int mplTokenMetadataErrorTokenAccountOneTimeAuthMintMismatch = 0x1a; // 26

/// DerivedKeyInvalid: Derived key invalid
/// Message: "Derived key invalid"
const int mplTokenMetadataErrorDerivedKeyInvalid = 0x1b; // 27

/// PrintingMintMismatch: The Printing mint does not match that on the master edition!
/// Message: "The Printing mint does not match that on the master edition!"
const int mplTokenMetadataErrorPrintingMintMismatch = 0x1c; // 28

/// OneTimePrintingAuthMintMismatch: The One Time Printing Auth mint does not match that on the master edition!
/// Message: "The One Time Printing Auth mint does not match that on the master edition!"
const int mplTokenMetadataErrorOneTimePrintingAuthMintMismatch = 0x1d; // 29

/// TokenAccountMintMismatch: The mint of the token account does not match the Printing mint!
/// Message: "The mint of the token account does not match the Printing mint!"
const int mplTokenMetadataErrorTokenAccountMintMismatch = 0x1e; // 30

/// TokenAccountMintMismatchV2: The mint of the token account does not match the master metadata mint!
/// Message: "The mint of the token account does not match the master metadata mint!"
const int mplTokenMetadataErrorTokenAccountMintMismatchV2 = 0x1f; // 31

/// NotEnoughTokens: Not enough tokens to mint a limited edition
/// Message: "Not enough tokens to mint a limited edition"
const int mplTokenMetadataErrorNotEnoughTokens = 0x20; // 32

/// PrintingMintAuthorizationAccountMismatch
const int mplTokenMetadataErrorPrintingMintAuthorizationAccountMismatch =
    0x21; // 33

/// AuthorizationTokenAccountOwnerMismatch
const int mplTokenMetadataErrorAuthorizationTokenAccountOwnerMismatch =
    0x22; // 34

/// Disabled
const int mplTokenMetadataErrorDisabled = 0x23; // 35

/// CreatorsTooLong: Creators list too long
/// Message: "Creators list too long"
const int mplTokenMetadataErrorCreatorsTooLong = 0x24; // 36

/// CreatorsMustBeAtleastOne: Creators must be at least one if set
/// Message: "Creators must be at least one if set"
const int mplTokenMetadataErrorCreatorsMustBeAtleastOne = 0x25; // 37

/// MustBeOneOfCreators
const int mplTokenMetadataErrorMustBeOneOfCreators = 0x26; // 38

/// NoCreatorsPresentOnMetadata: This metadata does not have creators
/// Message: "This metadata does not have creators"
const int mplTokenMetadataErrorNoCreatorsPresentOnMetadata = 0x27; // 39

/// CreatorNotFound: This creator address was not found
/// Message: "This creator address was not found"
const int mplTokenMetadataErrorCreatorNotFound = 0x28; // 40

/// InvalidBasisPoints: Basis points cannot be more than 10000
/// Message: "Basis points cannot be more than 10000"
const int mplTokenMetadataErrorInvalidBasisPoints = 0x29; // 41

/// PrimarySaleCanOnlyBeFlippedToTrue: Primary sale can only be flipped to true and is immutable
/// Message: "Primary sale can only be flipped to true and is immutable"
const int mplTokenMetadataErrorPrimarySaleCanOnlyBeFlippedToTrue = 0x2a; // 42

/// OwnerMismatch: Owner does not match that on the account given
/// Message: "Owner does not match that on the account given"
const int mplTokenMetadataErrorOwnerMismatch = 0x2b; // 43

/// NoBalanceInAccountForAuthorization: This account has no tokens to be used for authorization
/// Message: "This account has no tokens to be used for authorization"
const int mplTokenMetadataErrorNoBalanceInAccountForAuthorization = 0x2c; // 44

/// ShareTotalMustBe100: Share total must equal 100 for creator array
/// Message: "Share total must equal 100 for creator array"
const int mplTokenMetadataErrorShareTotalMustBe100 = 0x2d; // 45

/// ReservationExists
const int mplTokenMetadataErrorReservationExists = 0x2e; // 46

/// ReservationDoesNotExist
const int mplTokenMetadataErrorReservationDoesNotExist = 0x2f; // 47

/// ReservationNotSet
const int mplTokenMetadataErrorReservationNotSet = 0x30; // 48

/// ReservationAlreadyMade
const int mplTokenMetadataErrorReservationAlreadyMade = 0x31; // 49

/// BeyondMaxAddressSize
const int mplTokenMetadataErrorBeyondMaxAddressSize = 0x32; // 50

/// NumericalOverflowError: NumericalOverflowError
/// Message: "NumericalOverflowError"
const int mplTokenMetadataErrorNumericalOverflowError = 0x33; // 51

/// ReservationBreachesMaximumSupply
const int mplTokenMetadataErrorReservationBreachesMaximumSupply = 0x34; // 52

/// AddressNotInReservation
const int mplTokenMetadataErrorAddressNotInReservation = 0x35; // 53

/// CannotVerifyAnotherCreator: You cannot unilaterally verify another creator, they must sign
/// Message: "You cannot unilaterally verify another creator, they must sign"
const int mplTokenMetadataErrorCannotVerifyAnotherCreator = 0x36; // 54

/// CannotUnverifyAnotherCreator: You cannot unilaterally unverify another creator
/// Message: "You cannot unilaterally unverify another creator"
const int mplTokenMetadataErrorCannotUnverifyAnotherCreator = 0x37; // 55

/// SpotMismatch
const int mplTokenMetadataErrorSpotMismatch = 0x38; // 56

/// IncorrectOwner: Incorrect account owner
/// Message: "Incorrect account owner"
const int mplTokenMetadataErrorIncorrectOwner = 0x39; // 57

/// PrintingWouldBreachMaximumSupply
const int mplTokenMetadataErrorPrintingWouldBreachMaximumSupply = 0x3a; // 58

/// DataIsImmutable: Data is immutable
/// Message: "Data is immutable"
const int mplTokenMetadataErrorDataIsImmutable = 0x3b; // 59

/// DuplicateCreatorAddress: No duplicate creator addresses
/// Message: "No duplicate creator addresses"
const int mplTokenMetadataErrorDuplicateCreatorAddress = 0x3c; // 60

/// ReservationSpotsRemainingShouldMatchTotalSpotsAtStart
const int
mplTokenMetadataErrorReservationSpotsRemainingShouldMatchTotalSpotsAtStart =
    0x3d; // 61

/// InvalidTokenProgram: Invalid token program
/// Message: "Invalid token program"
const int mplTokenMetadataErrorInvalidTokenProgram = 0x3e; // 62

/// DataTypeMismatch: Data type mismatch
/// Message: "Data type mismatch"
const int mplTokenMetadataErrorDataTypeMismatch = 0x3f; // 63

/// BeyondAlottedAddressSize
const int mplTokenMetadataErrorBeyondAlottedAddressSize = 0x40; // 64

/// ReservationNotComplete
const int mplTokenMetadataErrorReservationNotComplete = 0x41; // 65

/// TriedToReplaceAnExistingReservation
const int mplTokenMetadataErrorTriedToReplaceAnExistingReservation = 0x42; // 66

/// InvalidOperation: Invalid operation
/// Message: "Invalid operation"
const int mplTokenMetadataErrorInvalidOperation = 0x43; // 67

/// InvalidOwner: Invalid Owner
/// Message: "Invalid Owner"
const int mplTokenMetadataErrorInvalidOwner = 0x44; // 68

/// PrintingMintSupplyMustBeZeroForConversion: Printing mint supply must be zero for conversion
/// Message: "Printing mint supply must be zero for conversion"
const int mplTokenMetadataErrorPrintingMintSupplyMustBeZeroForConversion =
    0x45; // 69

/// OneTimeAuthMintSupplyMustBeZeroForConversion: One Time Auth mint supply must be zero for conversion
/// Message: "One Time Auth mint supply must be zero for conversion"
const int mplTokenMetadataErrorOneTimeAuthMintSupplyMustBeZeroForConversion =
    0x46; // 70

/// InvalidEditionIndex: You tried to insert one edition too many into an edition mark pda
/// Message: "You tried to insert one edition too many into an edition mark pda"
const int mplTokenMetadataErrorInvalidEditionIndex = 0x47; // 71

/// ReservationArrayShouldBeSizeOne
const int mplTokenMetadataErrorReservationArrayShouldBeSizeOne = 0x48; // 72

/// IsMutableCanOnlyBeFlippedToFalse: Is Mutable can only be flipped to false
/// Message: "Is Mutable can only be flipped to false"
const int mplTokenMetadataErrorIsMutableCanOnlyBeFlippedToFalse = 0x49; // 73

/// CollectionCannotBeVerifiedInThisInstruction: Collection cannot be verified in this instruction
/// Message: "Collection cannot be verified in this instruction"
const int mplTokenMetadataErrorCollectionCannotBeVerifiedInThisInstruction =
    0x4a; // 74

/// Removed: This instruction was deprecated in a previous release and is now removed
/// Message: "This instruction was deprecated in a previous release and is now removed"
const int mplTokenMetadataErrorRemoved = 0x4b; // 75

/// MustBeBurned
const int mplTokenMetadataErrorMustBeBurned = 0x4c; // 76

/// InvalidUseMethod: This use method is invalid
/// Message: "This use method is invalid"
const int mplTokenMetadataErrorInvalidUseMethod = 0x4d; // 77

/// CannotChangeUseMethodAfterFirstUse: Cannot Change Use Method after the first use
/// Message: "Cannot Change Use Method after the first use"
const int mplTokenMetadataErrorCannotChangeUseMethodAfterFirstUse = 0x4e; // 78

/// CannotChangeUsesAfterFirstUse: Cannot Change Remaining or Available uses after the first use
/// Message: "Cannot Change Remaining or Available uses after the first use"
const int mplTokenMetadataErrorCannotChangeUsesAfterFirstUse = 0x4f; // 79

/// CollectionNotFound: Collection Not Found on Metadata
/// Message: "Collection Not Found on Metadata"
const int mplTokenMetadataErrorCollectionNotFound = 0x50; // 80

/// InvalidCollectionUpdateAuthority: Collection Update Authority is invalid
/// Message: "Collection Update Authority is invalid"
const int mplTokenMetadataErrorInvalidCollectionUpdateAuthority = 0x51; // 81

/// CollectionMustBeAUniqueMasterEdition: Collection Must Be a Unique Master Edition v2
/// Message: "Collection Must Be a Unique Master Edition v2"
const int mplTokenMetadataErrorCollectionMustBeAUniqueMasterEdition =
    0x52; // 82

/// UseAuthorityRecordAlreadyExists: The Use Authority Record Already Exists, to modify it Revoke, then Approve
/// Message: "The Use Authority Record Already Exists, to modify it Revoke, then Approve"
const int mplTokenMetadataErrorUseAuthorityRecordAlreadyExists = 0x53; // 83

/// UseAuthorityRecordAlreadyRevoked: The Use Authority Record is empty or already revoked
/// Message: "The Use Authority Record is empty or already revoked"
const int mplTokenMetadataErrorUseAuthorityRecordAlreadyRevoked = 0x54; // 84

/// Unusable: This token has no uses
/// Message: "This token has no uses"
const int mplTokenMetadataErrorUnusable = 0x55; // 85

/// NotEnoughUses: There are not enough Uses left on this token.
/// Message: "There are not enough Uses left on this token."
const int mplTokenMetadataErrorNotEnoughUses = 0x56; // 86

/// CollectionAuthorityRecordAlreadyExists: This Collection Authority Record Already Exists.
/// Message: "This Collection Authority Record Already Exists."
const int mplTokenMetadataErrorCollectionAuthorityRecordAlreadyExists =
    0x57; // 87

/// CollectionAuthorityDoesNotExist: This Collection Authority Record Does Not Exist.
/// Message: "This Collection Authority Record Does Not Exist."
const int mplTokenMetadataErrorCollectionAuthorityDoesNotExist = 0x58; // 88

/// InvalidUseAuthorityRecord: This Use Authority Record is invalid.
/// Message: "This Use Authority Record is invalid."
const int mplTokenMetadataErrorInvalidUseAuthorityRecord = 0x59; // 89

/// InvalidCollectionAuthorityRecord
const int mplTokenMetadataErrorInvalidCollectionAuthorityRecord = 0x5a; // 90

/// InvalidFreezeAuthority: Metadata does not match the freeze authority on the mint
/// Message: "Metadata does not match the freeze authority on the mint"
const int mplTokenMetadataErrorInvalidFreezeAuthority = 0x5b; // 91

/// InvalidDelegate: All tokens in this account have not been delegated to this user.
/// Message: "All tokens in this account have not been delegated to this user."
const int mplTokenMetadataErrorInvalidDelegate = 0x5c; // 92

/// CannotAdjustVerifiedCreator
const int mplTokenMetadataErrorCannotAdjustVerifiedCreator = 0x5d; // 93

/// CannotRemoveVerifiedCreator: Verified creators cannot be removed.
/// Message: "Verified creators cannot be removed."
const int mplTokenMetadataErrorCannotRemoveVerifiedCreator = 0x5e; // 94

/// CannotWipeVerifiedCreators
const int mplTokenMetadataErrorCannotWipeVerifiedCreators = 0x5f; // 95

/// NotAllowedToChangeSellerFeeBasisPoints
const int mplTokenMetadataErrorNotAllowedToChangeSellerFeeBasisPoints =
    0x60; // 96

/// EditionOverrideCannotBeZero: Edition override cannot be zero
/// Message: "Edition override cannot be zero"
const int mplTokenMetadataErrorEditionOverrideCannotBeZero = 0x61; // 97

/// InvalidUser: Invalid User
/// Message: "Invalid User"
const int mplTokenMetadataErrorInvalidUser = 0x62; // 98

/// RevokeCollectionAuthoritySignerIncorrect: Revoke Collection Authority signer is incorrect
/// Message: "Revoke Collection Authority signer is incorrect"
const int mplTokenMetadataErrorRevokeCollectionAuthoritySignerIncorrect =
    0x63; // 99

/// TokenCloseFailed
const int mplTokenMetadataErrorTokenCloseFailed = 0x64; // 100

/// UnsizedCollection: Can't use this function on unsized collection
/// Message: "Can't use this function on unsized collection"
const int mplTokenMetadataErrorUnsizedCollection = 0x65; // 101

/// SizedCollection: Can't use this function on a sized collection
/// Message: "Can't use this function on a sized collection"
const int mplTokenMetadataErrorSizedCollection = 0x66; // 102

/// MissingCollectionMetadata: Missing collection metadata account
/// Message: "Missing collection metadata account"
const int mplTokenMetadataErrorMissingCollectionMetadata = 0x67; // 103

/// NotAMemberOfCollection: This NFT is not a member of the specified collection.
/// Message: "This NFT is not a member of the specified collection."
const int mplTokenMetadataErrorNotAMemberOfCollection = 0x68; // 104

/// NotVerifiedMemberOfCollection: This NFT is not a verified member of the specified collection.
/// Message: "This NFT is not a verified member of the specified collection."
const int mplTokenMetadataErrorNotVerifiedMemberOfCollection = 0x69; // 105

/// NotACollectionParent: This NFT is not a collection parent NFT.
/// Message: "This NFT is not a collection parent NFT."
const int mplTokenMetadataErrorNotACollectionParent = 0x6a; // 106

/// CouldNotDetermineTokenStandard: Could not determine a TokenStandard type.
/// Message: "Could not determine a TokenStandard type."
const int mplTokenMetadataErrorCouldNotDetermineTokenStandard = 0x6b; // 107

/// MissingEditionAccount: This mint account has an edition but none was provided.
/// Message: "This mint account has an edition but none was provided."
const int mplTokenMetadataErrorMissingEditionAccount = 0x6c; // 108

/// NotAMasterEdition: This edition is not a Master Edition
/// Message: "This edition is not a Master Edition"
const int mplTokenMetadataErrorNotAMasterEdition = 0x6d; // 109

/// MasterEditionHasPrints: This Master Edition has existing prints
/// Message: "This Master Edition has existing prints"
const int mplTokenMetadataErrorMasterEditionHasPrints = 0x6e; // 110

/// BorshDeserializationError
const int mplTokenMetadataErrorBorshDeserializationError = 0x6f; // 111

/// CannotUpdateVerifiedCollection: Cannot update a verified collection in this command
/// Message: "Cannot update a verified collection in this command"
const int mplTokenMetadataErrorCannotUpdateVerifiedCollection = 0x70; // 112

/// CollectionMasterEditionAccountInvalid: Edition account doesnt match collection
/// Message: "Edition account doesnt match collection "
const int mplTokenMetadataErrorCollectionMasterEditionAccountInvalid =
    0x71; // 113

/// AlreadyVerified: Item is already verified.
/// Message: "Item is already verified."
const int mplTokenMetadataErrorAlreadyVerified = 0x72; // 114

/// AlreadyUnverified
const int mplTokenMetadataErrorAlreadyUnverified = 0x73; // 115

/// NotAPrintEdition: This edition is not a Print Edition
/// Message: "This edition is not a Print Edition"
const int mplTokenMetadataErrorNotAPrintEdition = 0x74; // 116

/// InvalidMasterEdition: Invalid Master Edition
/// Message: "Invalid Master Edition"
const int mplTokenMetadataErrorInvalidMasterEdition = 0x75; // 117

/// InvalidPrintEdition: Invalid Print Edition
/// Message: "Invalid Print Edition"
const int mplTokenMetadataErrorInvalidPrintEdition = 0x76; // 118

/// InvalidEditionMarker: Invalid Edition Marker
/// Message: "Invalid Edition Marker"
const int mplTokenMetadataErrorInvalidEditionMarker = 0x77; // 119

/// ReservationListDeprecated: Reservation List is Deprecated
/// Message: "Reservation List is Deprecated"
const int mplTokenMetadataErrorReservationListDeprecated = 0x78; // 120

/// PrintEditionDoesNotMatchMasterEdition: Print Edition does not match Master Edition
/// Message: "Print Edition does not match Master Edition"
const int mplTokenMetadataErrorPrintEditionDoesNotMatchMasterEdition =
    0x79; // 121

/// EditionNumberGreaterThanMaxSupply: Edition Number greater than max supply
/// Message: "Edition Number greater than max supply"
const int mplTokenMetadataErrorEditionNumberGreaterThanMaxSupply = 0x7a; // 122

/// MustUnverify: Must unverify before migrating collections.
/// Message: "Must unverify before migrating collections."
const int mplTokenMetadataErrorMustUnverify = 0x7b; // 123

/// InvalidEscrowBumpSeed: Invalid Escrow Account Bump Seed
/// Message: "Invalid Escrow Account Bump Seed"
const int mplTokenMetadataErrorInvalidEscrowBumpSeed = 0x7c; // 124

/// MustBeEscrowAuthority: Must Escrow Authority
/// Message: "Must Escrow Authority"
const int mplTokenMetadataErrorMustBeEscrowAuthority = 0x7d; // 125

/// InvalidSystemProgram: Invalid System Program
/// Message: "Invalid System Program"
const int mplTokenMetadataErrorInvalidSystemProgram = 0x7e; // 126

/// MustBeNonFungible: Must be a Non Fungible Token
/// Message: "Must be a Non Fungible Token"
const int mplTokenMetadataErrorMustBeNonFungible = 0x7f; // 127

/// InsufficientTokens: Insufficient tokens for transfer
/// Message: "Insufficient tokens for transfer"
const int mplTokenMetadataErrorInsufficientTokens = 0x80; // 128

/// BorshSerializationError: Borsh Serialization Error
/// Message: "Borsh Serialization Error"
const int mplTokenMetadataErrorBorshSerializationError = 0x81; // 129

/// NoFreezeAuthoritySet: Cannot create NFT with no Freeze Authority.
/// Message: "Cannot create NFT with no Freeze Authority."
const int mplTokenMetadataErrorNoFreezeAuthoritySet = 0x82; // 130

/// InvalidCollectionSizeChange: Invalid collection size change
/// Message: "Invalid collection size change"
const int mplTokenMetadataErrorInvalidCollectionSizeChange = 0x83; // 131

/// InvalidBubblegumSigner: Invalid bubblegum signer
/// Message: "Invalid bubblegum signer"
const int mplTokenMetadataErrorInvalidBubblegumSigner = 0x84; // 132

/// EscrowParentHasDelegate: Escrow parent cannot have a delegate
/// Message: "Escrow parent cannot have a delegate"
const int mplTokenMetadataErrorEscrowParentHasDelegate = 0x85; // 133

/// MintIsNotSigner: Mint needs to be signer to initialize the account
/// Message: "Mint needs to be signer to initialize the account"
const int mplTokenMetadataErrorMintIsNotSigner = 0x86; // 134

/// InvalidTokenStandard: Invalid token standard
/// Message: "Invalid token standard"
const int mplTokenMetadataErrorInvalidTokenStandard = 0x87; // 135

/// InvalidMintForTokenStandard: Invalid mint account for specified token standard
/// Message: "Invalid mint account for specified token standard"
const int mplTokenMetadataErrorInvalidMintForTokenStandard = 0x88; // 136

/// InvalidAuthorizationRules: Invalid authorization rules account
/// Message: "Invalid authorization rules account"
const int mplTokenMetadataErrorInvalidAuthorizationRules = 0x89; // 137

/// MissingAuthorizationRules: Missing authorization rules account
/// Message: "Missing authorization rules account"
const int mplTokenMetadataErrorMissingAuthorizationRules = 0x8a; // 138

/// MissingProgrammableConfig: Missing programmable configuration
/// Message: "Missing programmable configuration"
const int mplTokenMetadataErrorMissingProgrammableConfig = 0x8b; // 139

/// InvalidProgrammableConfig: Invalid programmable configuration
/// Message: "Invalid programmable configuration"
const int mplTokenMetadataErrorInvalidProgrammableConfig = 0x8c; // 140

/// DelegateAlreadyExists: Delegate already exists
/// Message: "Delegate already exists"
const int mplTokenMetadataErrorDelegateAlreadyExists = 0x8d; // 141

/// DelegateNotFound: Delegate not found
/// Message: "Delegate not found"
const int mplTokenMetadataErrorDelegateNotFound = 0x8e; // 142

/// MissingAccountInBuilder: Required account not set in instruction builder
/// Message: "Required account not set in instruction builder"
const int mplTokenMetadataErrorMissingAccountInBuilder = 0x8f; // 143

/// MissingArgumentInBuilder: Required argument not set in instruction builder
/// Message: "Required argument not set in instruction builder"
const int mplTokenMetadataErrorMissingArgumentInBuilder = 0x90; // 144

/// FeatureNotSupported: Feature not supported currently
/// Message: "Feature not supported currently"
const int mplTokenMetadataErrorFeatureNotSupported = 0x91; // 145

/// InvalidSystemWallet: Invalid system wallet
/// Message: "Invalid system wallet"
const int mplTokenMetadataErrorInvalidSystemWallet = 0x92; // 146

/// OnlySaleDelegateCanTransfer: Only the sale delegate can transfer while its set
/// Message: "Only the sale delegate can transfer while its set"
const int mplTokenMetadataErrorOnlySaleDelegateCanTransfer = 0x93; // 147

/// MissingTokenAccount: Missing token account
/// Message: "Missing token account"
const int mplTokenMetadataErrorMissingTokenAccount = 0x94; // 148

/// MissingSplTokenProgram: Missing SPL token program
/// Message: "Missing SPL token program"
const int mplTokenMetadataErrorMissingSplTokenProgram = 0x95; // 149

/// MissingAuthorizationRulesProgram: Missing authorization rules program
/// Message: "Missing authorization rules program"
const int mplTokenMetadataErrorMissingAuthorizationRulesProgram = 0x96; // 150

/// InvalidDelegateRoleForTransfer: Invalid delegate role for transfer
/// Message: "Invalid delegate role for transfer"
const int mplTokenMetadataErrorInvalidDelegateRoleForTransfer = 0x97; // 151

/// InvalidTransferAuthority: Invalid transfer authority
/// Message: "Invalid transfer authority"
const int mplTokenMetadataErrorInvalidTransferAuthority = 0x98; // 152

/// InstructionNotSupported: Instruction not supported for ProgrammableNonFungible assets
/// Message: "Instruction not supported for ProgrammableNonFungible assets"
const int mplTokenMetadataErrorInstructionNotSupported = 0x99; // 153

/// KeyMismatch: Public key does not match expected value
/// Message: "Public key does not match expected value"
const int mplTokenMetadataErrorKeyMismatch = 0x9a; // 154

/// LockedToken: Token is locked
/// Message: "Token is locked"
const int mplTokenMetadataErrorLockedToken = 0x9b; // 155

/// UnlockedToken: Token is unlocked
/// Message: "Token is unlocked"
const int mplTokenMetadataErrorUnlockedToken = 0x9c; // 156

/// MissingDelegateRole: Missing delegate role
/// Message: "Missing delegate role"
const int mplTokenMetadataErrorMissingDelegateRole = 0x9d; // 157

/// InvalidAuthorityType: Invalid authority type
/// Message: "Invalid authority type"
const int mplTokenMetadataErrorInvalidAuthorityType = 0x9e; // 158

/// MissingTokenRecord: Missing token record account
/// Message: "Missing token record account"
const int mplTokenMetadataErrorMissingTokenRecord = 0x9f; // 159

/// MintSupplyMustBeZero: Mint supply must be zero for programmable assets
/// Message: "Mint supply must be zero for programmable assets"
const int mplTokenMetadataErrorMintSupplyMustBeZero = 0xa0; // 160

/// DataIsEmptyOrZeroed: Data is empty or zeroed
/// Message: "Data is empty or zeroed"
const int mplTokenMetadataErrorDataIsEmptyOrZeroed = 0xa1; // 161

/// MissingTokenOwnerAccount: Missing token owner
/// Message: "Missing token owner"
const int mplTokenMetadataErrorMissingTokenOwnerAccount = 0xa2; // 162

/// InvalidMasterEditionAccountLength: Master edition account has an invalid length
/// Message: "Master edition account has an invalid length"
const int mplTokenMetadataErrorInvalidMasterEditionAccountLength = 0xa3; // 163

/// IncorrectTokenState: Incorrect token state
/// Message: "Incorrect token state"
const int mplTokenMetadataErrorIncorrectTokenState = 0xa4; // 164

/// InvalidDelegateRole: Invalid delegate role
/// Message: "Invalid delegate role"
const int mplTokenMetadataErrorInvalidDelegateRole = 0xa5; // 165

/// MissingPrintSupply: Print supply is required for non-fungibles
/// Message: "Print supply is required for non-fungibles"
const int mplTokenMetadataErrorMissingPrintSupply = 0xa6; // 166

/// MissingMasterEditionAccount: Missing master edition account
/// Message: "Missing master edition account"
const int mplTokenMetadataErrorMissingMasterEditionAccount = 0xa7; // 167

/// AmountMustBeGreaterThanZero: Amount must be greater than zero
/// Message: "Amount must be greater than zero"
const int mplTokenMetadataErrorAmountMustBeGreaterThanZero = 0xa8; // 168

/// InvalidDelegateArgs: Invalid delegate args
/// Message: "Invalid delegate args"
const int mplTokenMetadataErrorInvalidDelegateArgs = 0xa9; // 169

/// MissingLockedTransferAddress: Missing address for locked transfer
/// Message: "Missing address for locked transfer"
const int mplTokenMetadataErrorMissingLockedTransferAddress = 0xaa; // 170

/// InvalidLockedTransferAddress: Invalid destination address for locked transfer
/// Message: "Invalid destination address for locked transfer"
const int mplTokenMetadataErrorInvalidLockedTransferAddress = 0xab; // 171

/// DataIncrementLimitExceeded: Exceeded account realloc increase limit
/// Message: "Exceeded account realloc increase limit"
const int mplTokenMetadataErrorDataIncrementLimitExceeded = 0xac; // 172

/// CannotUpdateAssetWithDelegate: Cannot update the rule set of a programmable asset that has a delegate
/// Message: "Cannot update the rule set of a programmable asset that has a delegate"
const int mplTokenMetadataErrorCannotUpdateAssetWithDelegate = 0xad; // 173

/// InvalidAmount: Invalid token amount for this operation or token standard
/// Message: "Invalid token amount for this operation or token standard"
const int mplTokenMetadataErrorInvalidAmount = 0xae; // 174

/// MissingMasterEditionMintAccount: Missing master edition mint account
/// Message: "Missing master edition mint account"
const int mplTokenMetadataErrorMissingMasterEditionMintAccount = 0xaf; // 175

/// MissingMasterEditionTokenAccount: Missing master edition token account
/// Message: "Missing master edition token account"
const int mplTokenMetadataErrorMissingMasterEditionTokenAccount = 0xb0; // 176

/// MissingEditionMarkerAccount: Missing edition marker account
/// Message: "Missing edition marker account"
const int mplTokenMetadataErrorMissingEditionMarkerAccount = 0xb1; // 177

/// CannotBurnWithDelegate: Cannot burn while persistent delegate is set
/// Message: "Cannot burn while persistent delegate is set"
const int mplTokenMetadataErrorCannotBurnWithDelegate = 0xb2; // 178

/// MissingEdition: Missing edition account
/// Message: "Missing edition account"
const int mplTokenMetadataErrorMissingEdition = 0xb3; // 179

/// InvalidAssociatedTokenAccountProgram: Invalid Associated Token Account Program
/// Message: "Invalid Associated Token Account Program"
const int mplTokenMetadataErrorInvalidAssociatedTokenAccountProgram =
    0xb4; // 180

/// InvalidInstructionsSysvar: Invalid InstructionsSysvar
/// Message: "Invalid InstructionsSysvar"
const int mplTokenMetadataErrorInvalidInstructionsSysvar = 0xb5; // 181

/// InvalidParentAccounts: Invalid or Unneeded parent accounts
/// Message: "Invalid or Unneeded parent accounts"
const int mplTokenMetadataErrorInvalidParentAccounts = 0xb6; // 182

/// InvalidUpdateArgs: Authority cannot apply all update args
/// Message: "Authority cannot apply all update args"
const int mplTokenMetadataErrorInvalidUpdateArgs = 0xb7; // 183

/// InsufficientTokenBalance: Token account does not have enough tokens
/// Message: "Token account does not have enough tokens"
const int mplTokenMetadataErrorInsufficientTokenBalance = 0xb8; // 184

/// MissingCollectionMint: Missing collection account
/// Message: "Missing collection account"
const int mplTokenMetadataErrorMissingCollectionMint = 0xb9; // 185

/// MissingCollectionMasterEdition: Missing collection master edition account
/// Message: "Missing collection master edition account"
const int mplTokenMetadataErrorMissingCollectionMasterEdition = 0xba; // 186

/// InvalidTokenRecord: Invalid token record account
/// Message: "Invalid token record account"
const int mplTokenMetadataErrorInvalidTokenRecord = 0xbb; // 187

/// InvalidCloseAuthority: The close authority needs to be revoked by the Utility Delegate
/// Message: "The close authority needs to be revoked by the Utility Delegate"
const int mplTokenMetadataErrorInvalidCloseAuthority = 0xbc; // 188

/// InvalidInstruction: Invalid or removed instruction
/// Message: "Invalid or removed instruction"
const int mplTokenMetadataErrorInvalidInstruction = 0xbd; // 189

/// MissingDelegateRecord: Missing delegate record
/// Message: "Missing delegate record"
const int mplTokenMetadataErrorMissingDelegateRecord = 0xbe; // 190

/// InvalidFeeAccount
const int mplTokenMetadataErrorInvalidFeeAccount = 0xbf; // 191

/// InvalidMetadataFlags
const int mplTokenMetadataErrorInvalidMetadataFlags = 0xc0; // 192

/// CannotChangeUpdateAuthorityWithDelegate: Cannot change the update authority with a delegate
/// Message: "Cannot change the update authority with a delegate"
const int mplTokenMetadataErrorCannotChangeUpdateAuthorityWithDelegate =
    0xc1; // 193

/// InvalidMintExtensionType: Invalid mint extension type
/// Message: "Invalid mint extension type"
const int mplTokenMetadataErrorInvalidMintExtensionType = 0xc2; // 194

/// InvalidMintCloseAuthority: Invalid mint close authority
/// Message: "Invalid mint close authority"
const int mplTokenMetadataErrorInvalidMintCloseAuthority = 0xc3; // 195

/// InvalidMetadataPointer: Invalid metadata pointer
/// Message: "Invalid metadata pointer"
const int mplTokenMetadataErrorInvalidMetadataPointer = 0xc4; // 196

/// InvalidTokenExtensionType: Invalid token extension type
/// Message: "Invalid token extension type"
const int mplTokenMetadataErrorInvalidTokenExtensionType = 0xc5; // 197

/// MissingImmutableOwnerExtension: Missing immutable owner extension
/// Message: "Missing immutable owner extension"
const int mplTokenMetadataErrorMissingImmutableOwnerExtension = 0xc6; // 198

/// ExpectedUninitializedAccount: Expected account to be uninitialized
/// Message: "Expected account to be uninitialized"
const int mplTokenMetadataErrorExpectedUninitializedAccount = 0xc7; // 199

/// InvalidEditionAccountLength: Edition account has an invalid length
/// Message: "Edition account has an invalid length"
const int mplTokenMetadataErrorInvalidEditionAccountLength = 0xc8; // 200

/// AccountAlreadyResized: Account has already been resized
/// Message: "Account has already been resized"
const int mplTokenMetadataErrorAccountAlreadyResized = 0xc9; // 201

/// ConditionsForClosingNotMet: Conditions for closing not met
/// Message: "Conditions for closing not met"
const int mplTokenMetadataErrorConditionsForClosingNotMet = 0xca; // 202

/// Map of error codes to human-readable messages.
const Map<int, String> _mplTokenMetadataErrorMessages = {
  mplTokenMetadataErrorInstructionUnpackError: '',
  mplTokenMetadataErrorInstructionPackError: '',
  mplTokenMetadataErrorNotRentExempt:
      'Lamport balance below rent-exempt threshold',
  mplTokenMetadataErrorAlreadyInitialized: 'Already initialized',
  mplTokenMetadataErrorUninitialized: 'Uninitialized',
  mplTokenMetadataErrorInvalidMetadataKey:
      ' Metadata\'s key must match seed of [\'metadata\', program id, mint] provided',
  mplTokenMetadataErrorInvalidEditionKey:
      'Edition\'s key must match seed of [\'metadata\', program id, name, \'edition\'] provided',
  mplTokenMetadataErrorUpdateAuthorityIncorrect:
      'Update Authority given does not match',
  mplTokenMetadataErrorUpdateAuthorityIsNotSigner:
      'Update Authority needs to be signer to update metadata',
  mplTokenMetadataErrorNotMintAuthority:
      'You must be the mint authority and signer on this transaction',
  mplTokenMetadataErrorInvalidMintAuthority:
      'Mint authority provided does not match the authority on the mint',
  mplTokenMetadataErrorNameTooLong: 'Name too long',
  mplTokenMetadataErrorSymbolTooLong: 'Symbol too long',
  mplTokenMetadataErrorUriTooLong: 'URI too long',
  mplTokenMetadataErrorUpdateAuthorityMustBeEqualToMetadataAuthorityAndSigner:
      '',
  mplTokenMetadataErrorMintMismatch:
      'Mint given does not match mint on Metadata',
  mplTokenMetadataErrorEditionsMustHaveExactlyOneToken:
      'Editions must have exactly one token',
  mplTokenMetadataErrorMaxEditionsMintedAlready: '',
  mplTokenMetadataErrorTokenMintToFailed: '',
  mplTokenMetadataErrorMasterRecordMismatch: '',
  mplTokenMetadataErrorDestinationMintMismatch: '',
  mplTokenMetadataErrorEditionAlreadyMinted: '',
  mplTokenMetadataErrorPrintingMintDecimalsShouldBeZero: '',
  mplTokenMetadataErrorOneTimePrintingAuthorizationMintDecimalsShouldBeZero: '',
  mplTokenMetadataErrorEditionMintDecimalsShouldBeZero:
      'EditionMintDecimalsShouldBeZero',
  mplTokenMetadataErrorTokenBurnFailed: '',
  mplTokenMetadataErrorTokenAccountOneTimeAuthMintMismatch: '',
  mplTokenMetadataErrorDerivedKeyInvalid: 'Derived key invalid',
  mplTokenMetadataErrorPrintingMintMismatch:
      'The Printing mint does not match that on the master edition!',
  mplTokenMetadataErrorOneTimePrintingAuthMintMismatch:
      'The One Time Printing Auth mint does not match that on the master edition!',
  mplTokenMetadataErrorTokenAccountMintMismatch:
      'The mint of the token account does not match the Printing mint!',
  mplTokenMetadataErrorTokenAccountMintMismatchV2:
      'The mint of the token account does not match the master metadata mint!',
  mplTokenMetadataErrorNotEnoughTokens:
      'Not enough tokens to mint a limited edition',
  mplTokenMetadataErrorPrintingMintAuthorizationAccountMismatch: '',
  mplTokenMetadataErrorAuthorizationTokenAccountOwnerMismatch: '',
  mplTokenMetadataErrorDisabled: '',
  mplTokenMetadataErrorCreatorsTooLong: 'Creators list too long',
  mplTokenMetadataErrorCreatorsMustBeAtleastOne:
      'Creators must be at least one if set',
  mplTokenMetadataErrorMustBeOneOfCreators: '',
  mplTokenMetadataErrorNoCreatorsPresentOnMetadata:
      'This metadata does not have creators',
  mplTokenMetadataErrorCreatorNotFound: 'This creator address was not found',
  mplTokenMetadataErrorInvalidBasisPoints:
      'Basis points cannot be more than 10000',
  mplTokenMetadataErrorPrimarySaleCanOnlyBeFlippedToTrue:
      'Primary sale can only be flipped to true and is immutable',
  mplTokenMetadataErrorOwnerMismatch:
      'Owner does not match that on the account given',
  mplTokenMetadataErrorNoBalanceInAccountForAuthorization:
      'This account has no tokens to be used for authorization',
  mplTokenMetadataErrorShareTotalMustBe100:
      'Share total must equal 100 for creator array',
  mplTokenMetadataErrorReservationExists: '',
  mplTokenMetadataErrorReservationDoesNotExist: '',
  mplTokenMetadataErrorReservationNotSet: '',
  mplTokenMetadataErrorReservationAlreadyMade: '',
  mplTokenMetadataErrorBeyondMaxAddressSize: '',
  mplTokenMetadataErrorNumericalOverflowError: 'NumericalOverflowError',
  mplTokenMetadataErrorReservationBreachesMaximumSupply: '',
  mplTokenMetadataErrorAddressNotInReservation: '',
  mplTokenMetadataErrorCannotVerifyAnotherCreator:
      'You cannot unilaterally verify another creator, they must sign',
  mplTokenMetadataErrorCannotUnverifyAnotherCreator:
      'You cannot unilaterally unverify another creator',
  mplTokenMetadataErrorSpotMismatch: '',
  mplTokenMetadataErrorIncorrectOwner: 'Incorrect account owner',
  mplTokenMetadataErrorPrintingWouldBreachMaximumSupply: '',
  mplTokenMetadataErrorDataIsImmutable: 'Data is immutable',
  mplTokenMetadataErrorDuplicateCreatorAddress:
      'No duplicate creator addresses',
  mplTokenMetadataErrorReservationSpotsRemainingShouldMatchTotalSpotsAtStart:
      '',
  mplTokenMetadataErrorInvalidTokenProgram: 'Invalid token program',
  mplTokenMetadataErrorDataTypeMismatch: 'Data type mismatch',
  mplTokenMetadataErrorBeyondAlottedAddressSize: '',
  mplTokenMetadataErrorReservationNotComplete: '',
  mplTokenMetadataErrorTriedToReplaceAnExistingReservation: '',
  mplTokenMetadataErrorInvalidOperation: 'Invalid operation',
  mplTokenMetadataErrorInvalidOwner: 'Invalid Owner',
  mplTokenMetadataErrorPrintingMintSupplyMustBeZeroForConversion:
      'Printing mint supply must be zero for conversion',
  mplTokenMetadataErrorOneTimeAuthMintSupplyMustBeZeroForConversion:
      'One Time Auth mint supply must be zero for conversion',
  mplTokenMetadataErrorInvalidEditionIndex:
      'You tried to insert one edition too many into an edition mark pda',
  mplTokenMetadataErrorReservationArrayShouldBeSizeOne: '',
  mplTokenMetadataErrorIsMutableCanOnlyBeFlippedToFalse:
      'Is Mutable can only be flipped to false',
  mplTokenMetadataErrorCollectionCannotBeVerifiedInThisInstruction:
      'Collection cannot be verified in this instruction',
  mplTokenMetadataErrorRemoved:
      'This instruction was deprecated in a previous release and is now removed',
  mplTokenMetadataErrorMustBeBurned: '',
  mplTokenMetadataErrorInvalidUseMethod: 'This use method is invalid',
  mplTokenMetadataErrorCannotChangeUseMethodAfterFirstUse:
      'Cannot Change Use Method after the first use',
  mplTokenMetadataErrorCannotChangeUsesAfterFirstUse:
      'Cannot Change Remaining or Available uses after the first use',
  mplTokenMetadataErrorCollectionNotFound: 'Collection Not Found on Metadata',
  mplTokenMetadataErrorInvalidCollectionUpdateAuthority:
      'Collection Update Authority is invalid',
  mplTokenMetadataErrorCollectionMustBeAUniqueMasterEdition:
      'Collection Must Be a Unique Master Edition v2',
  mplTokenMetadataErrorUseAuthorityRecordAlreadyExists:
      'The Use Authority Record Already Exists, to modify it Revoke, then Approve',
  mplTokenMetadataErrorUseAuthorityRecordAlreadyRevoked:
      'The Use Authority Record is empty or already revoked',
  mplTokenMetadataErrorUnusable: 'This token has no uses',
  mplTokenMetadataErrorNotEnoughUses:
      'There are not enough Uses left on this token.',
  mplTokenMetadataErrorCollectionAuthorityRecordAlreadyExists:
      'This Collection Authority Record Already Exists.',
  mplTokenMetadataErrorCollectionAuthorityDoesNotExist:
      'This Collection Authority Record Does Not Exist.',
  mplTokenMetadataErrorInvalidUseAuthorityRecord:
      'This Use Authority Record is invalid.',
  mplTokenMetadataErrorInvalidCollectionAuthorityRecord: '',
  mplTokenMetadataErrorInvalidFreezeAuthority:
      'Metadata does not match the freeze authority on the mint',
  mplTokenMetadataErrorInvalidDelegate:
      'All tokens in this account have not been delegated to this user.',
  mplTokenMetadataErrorCannotAdjustVerifiedCreator: '',
  mplTokenMetadataErrorCannotRemoveVerifiedCreator:
      'Verified creators cannot be removed.',
  mplTokenMetadataErrorCannotWipeVerifiedCreators: '',
  mplTokenMetadataErrorNotAllowedToChangeSellerFeeBasisPoints: '',
  mplTokenMetadataErrorEditionOverrideCannotBeZero:
      'Edition override cannot be zero',
  mplTokenMetadataErrorInvalidUser: 'Invalid User',
  mplTokenMetadataErrorRevokeCollectionAuthoritySignerIncorrect:
      'Revoke Collection Authority signer is incorrect',
  mplTokenMetadataErrorTokenCloseFailed: '',
  mplTokenMetadataErrorUnsizedCollection:
      'Can\'t use this function on unsized collection',
  mplTokenMetadataErrorSizedCollection:
      'Can\'t use this function on a sized collection',
  mplTokenMetadataErrorMissingCollectionMetadata:
      'Missing collection metadata account',
  mplTokenMetadataErrorNotAMemberOfCollection:
      'This NFT is not a member of the specified collection.',
  mplTokenMetadataErrorNotVerifiedMemberOfCollection:
      'This NFT is not a verified member of the specified collection.',
  mplTokenMetadataErrorNotACollectionParent:
      'This NFT is not a collection parent NFT.',
  mplTokenMetadataErrorCouldNotDetermineTokenStandard:
      'Could not determine a TokenStandard type.',
  mplTokenMetadataErrorMissingEditionAccount:
      'This mint account has an edition but none was provided.',
  mplTokenMetadataErrorNotAMasterEdition:
      'This edition is not a Master Edition',
  mplTokenMetadataErrorMasterEditionHasPrints:
      'This Master Edition has existing prints',
  mplTokenMetadataErrorBorshDeserializationError: '',
  mplTokenMetadataErrorCannotUpdateVerifiedCollection:
      'Cannot update a verified collection in this command',
  mplTokenMetadataErrorCollectionMasterEditionAccountInvalid:
      'Edition account doesnt match collection ',
  mplTokenMetadataErrorAlreadyVerified: 'Item is already verified.',
  mplTokenMetadataErrorAlreadyUnverified: '',
  mplTokenMetadataErrorNotAPrintEdition: 'This edition is not a Print Edition',
  mplTokenMetadataErrorInvalidMasterEdition: 'Invalid Master Edition',
  mplTokenMetadataErrorInvalidPrintEdition: 'Invalid Print Edition',
  mplTokenMetadataErrorInvalidEditionMarker: 'Invalid Edition Marker',
  mplTokenMetadataErrorReservationListDeprecated:
      'Reservation List is Deprecated',
  mplTokenMetadataErrorPrintEditionDoesNotMatchMasterEdition:
      'Print Edition does not match Master Edition',
  mplTokenMetadataErrorEditionNumberGreaterThanMaxSupply:
      'Edition Number greater than max supply',
  mplTokenMetadataErrorMustUnverify:
      'Must unverify before migrating collections.',
  mplTokenMetadataErrorInvalidEscrowBumpSeed:
      'Invalid Escrow Account Bump Seed',
  mplTokenMetadataErrorMustBeEscrowAuthority: 'Must Escrow Authority',
  mplTokenMetadataErrorInvalidSystemProgram: 'Invalid System Program',
  mplTokenMetadataErrorMustBeNonFungible: 'Must be a Non Fungible Token',
  mplTokenMetadataErrorInsufficientTokens: 'Insufficient tokens for transfer',
  mplTokenMetadataErrorBorshSerializationError: 'Borsh Serialization Error',
  mplTokenMetadataErrorNoFreezeAuthoritySet:
      'Cannot create NFT with no Freeze Authority.',
  mplTokenMetadataErrorInvalidCollectionSizeChange:
      'Invalid collection size change',
  mplTokenMetadataErrorInvalidBubblegumSigner: 'Invalid bubblegum signer',
  mplTokenMetadataErrorEscrowParentHasDelegate:
      'Escrow parent cannot have a delegate',
  mplTokenMetadataErrorMintIsNotSigner:
      'Mint needs to be signer to initialize the account',
  mplTokenMetadataErrorInvalidTokenStandard: 'Invalid token standard',
  mplTokenMetadataErrorInvalidMintForTokenStandard:
      'Invalid mint account for specified token standard',
  mplTokenMetadataErrorInvalidAuthorizationRules:
      'Invalid authorization rules account',
  mplTokenMetadataErrorMissingAuthorizationRules:
      'Missing authorization rules account',
  mplTokenMetadataErrorMissingProgrammableConfig:
      'Missing programmable configuration',
  mplTokenMetadataErrorInvalidProgrammableConfig:
      'Invalid programmable configuration',
  mplTokenMetadataErrorDelegateAlreadyExists: 'Delegate already exists',
  mplTokenMetadataErrorDelegateNotFound: 'Delegate not found',
  mplTokenMetadataErrorMissingAccountInBuilder:
      'Required account not set in instruction builder',
  mplTokenMetadataErrorMissingArgumentInBuilder:
      'Required argument not set in instruction builder',
  mplTokenMetadataErrorFeatureNotSupported: 'Feature not supported currently',
  mplTokenMetadataErrorInvalidSystemWallet: 'Invalid system wallet',
  mplTokenMetadataErrorOnlySaleDelegateCanTransfer:
      'Only the sale delegate can transfer while its set',
  mplTokenMetadataErrorMissingTokenAccount: 'Missing token account',
  mplTokenMetadataErrorMissingSplTokenProgram: 'Missing SPL token program',
  mplTokenMetadataErrorMissingAuthorizationRulesProgram:
      'Missing authorization rules program',
  mplTokenMetadataErrorInvalidDelegateRoleForTransfer:
      'Invalid delegate role for transfer',
  mplTokenMetadataErrorInvalidTransferAuthority: 'Invalid transfer authority',
  mplTokenMetadataErrorInstructionNotSupported:
      'Instruction not supported for ProgrammableNonFungible assets',
  mplTokenMetadataErrorKeyMismatch: 'Public key does not match expected value',
  mplTokenMetadataErrorLockedToken: 'Token is locked',
  mplTokenMetadataErrorUnlockedToken: 'Token is unlocked',
  mplTokenMetadataErrorMissingDelegateRole: 'Missing delegate role',
  mplTokenMetadataErrorInvalidAuthorityType: 'Invalid authority type',
  mplTokenMetadataErrorMissingTokenRecord: 'Missing token record account',
  mplTokenMetadataErrorMintSupplyMustBeZero:
      'Mint supply must be zero for programmable assets',
  mplTokenMetadataErrorDataIsEmptyOrZeroed: 'Data is empty or zeroed',
  mplTokenMetadataErrorMissingTokenOwnerAccount: 'Missing token owner',
  mplTokenMetadataErrorInvalidMasterEditionAccountLength:
      'Master edition account has an invalid length',
  mplTokenMetadataErrorIncorrectTokenState: 'Incorrect token state',
  mplTokenMetadataErrorInvalidDelegateRole: 'Invalid delegate role',
  mplTokenMetadataErrorMissingPrintSupply:
      'Print supply is required for non-fungibles',
  mplTokenMetadataErrorMissingMasterEditionAccount:
      'Missing master edition account',
  mplTokenMetadataErrorAmountMustBeGreaterThanZero:
      'Amount must be greater than zero',
  mplTokenMetadataErrorInvalidDelegateArgs: 'Invalid delegate args',
  mplTokenMetadataErrorMissingLockedTransferAddress:
      'Missing address for locked transfer',
  mplTokenMetadataErrorInvalidLockedTransferAddress:
      'Invalid destination address for locked transfer',
  mplTokenMetadataErrorDataIncrementLimitExceeded:
      'Exceeded account realloc increase limit',
  mplTokenMetadataErrorCannotUpdateAssetWithDelegate:
      'Cannot update the rule set of a programmable asset that has a delegate',
  mplTokenMetadataErrorInvalidAmount:
      'Invalid token amount for this operation or token standard',
  mplTokenMetadataErrorMissingMasterEditionMintAccount:
      'Missing master edition mint account',
  mplTokenMetadataErrorMissingMasterEditionTokenAccount:
      'Missing master edition token account',
  mplTokenMetadataErrorMissingEditionMarkerAccount:
      'Missing edition marker account',
  mplTokenMetadataErrorCannotBurnWithDelegate:
      'Cannot burn while persistent delegate is set',
  mplTokenMetadataErrorMissingEdition: 'Missing edition account',
  mplTokenMetadataErrorInvalidAssociatedTokenAccountProgram:
      'Invalid Associated Token Account Program',
  mplTokenMetadataErrorInvalidInstructionsSysvar: 'Invalid InstructionsSysvar',
  mplTokenMetadataErrorInvalidParentAccounts:
      'Invalid or Unneeded parent accounts',
  mplTokenMetadataErrorInvalidUpdateArgs:
      'Authority cannot apply all update args',
  mplTokenMetadataErrorInsufficientTokenBalance:
      'Token account does not have enough tokens',
  mplTokenMetadataErrorMissingCollectionMint: 'Missing collection account',
  mplTokenMetadataErrorMissingCollectionMasterEdition:
      'Missing collection master edition account',
  mplTokenMetadataErrorInvalidTokenRecord: 'Invalid token record account',
  mplTokenMetadataErrorInvalidCloseAuthority:
      'The close authority needs to be revoked by the Utility Delegate',
  mplTokenMetadataErrorInvalidInstruction: 'Invalid or removed instruction',
  mplTokenMetadataErrorMissingDelegateRecord: 'Missing delegate record',
  mplTokenMetadataErrorInvalidFeeAccount: '',
  mplTokenMetadataErrorInvalidMetadataFlags: '',
  mplTokenMetadataErrorCannotChangeUpdateAuthorityWithDelegate:
      'Cannot change the update authority with a delegate',
  mplTokenMetadataErrorInvalidMintExtensionType: 'Invalid mint extension type',
  mplTokenMetadataErrorInvalidMintCloseAuthority:
      'Invalid mint close authority',
  mplTokenMetadataErrorInvalidMetadataPointer: 'Invalid metadata pointer',
  mplTokenMetadataErrorInvalidTokenExtensionType:
      'Invalid token extension type',
  mplTokenMetadataErrorMissingImmutableOwnerExtension:
      'Missing immutable owner extension',
  mplTokenMetadataErrorExpectedUninitializedAccount:
      'Expected account to be uninitialized',
  mplTokenMetadataErrorInvalidEditionAccountLength:
      'Edition account has an invalid length',
  mplTokenMetadataErrorAccountAlreadyResized:
      'Account has already been resized',
  mplTokenMetadataErrorConditionsForClosingNotMet:
      'Conditions for closing not met',
};

/// Get the error message for a MplTokenMetadata program error code.
String? getMplTokenMetadataErrorMessage(int code) {
  return _mplTokenMetadataErrorMessages[code];
}

/// Check if an error code belongs to the MplTokenMetadata program.
bool isMplTokenMetadataError(int code) {
  return _mplTokenMetadataErrorMessages.containsKey(code);
}
