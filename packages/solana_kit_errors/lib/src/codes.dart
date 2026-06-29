/// All Solana error code constants ported from the TypeScript `@solana/errors`
/// package.
///
/// Each constant corresponds to a unique error condition in the Solana web3
/// stack. The numeric values are kept in sync with the upstream TypeScript
/// source so that error codes are interoperable across implementations.
enum SolanaErrorCode {
  // ---------------------------------------------------------------------------
  // General (1 - 10)
  // ---------------------------------------------------------------------------

  /// The current block height has been exceeded.
  blockHeightExceeded(1),

  /// The provided nonce is invalid.
  invalidNonce(2),

  /// The nonce account could not be found.
  nonceAccountNotFound(3),

  /// The blockhash string length is outside the allowed range.
  blockhashStringLengthOutOfRange(4),

  /// The blockhash has an invalid byte length.
  invalidBlockhashByteLength(5),

  /// The lamports value is outside the allowed range.
  lamportsOutOfRange(6),

  /// The bigint string is malformed and cannot be parsed.
  malformedBigintString(7),

  /// The number string is malformed and cannot be parsed.
  malformedNumberString(8),

  /// The timestamp value is outside the allowed range.
  timestampOutOfRange(9),

  /// The JSON-RPC error payload is malformed.
  malformedJsonRpcError(10),

  /// Failed to send the transaction.
  failedToSendTransaction(11),

  /// Failed to send the batch of transactions.
  failedToSendTransactions(12),

  // ---------------------------------------------------------------------------
  // JSON-RPC (-32768 to -32000)
  // ---------------------------------------------------------------------------

  /// JSON-RPC parse error: invalid JSON was received.
  jsonRpcParseError(-32700),

  /// JSON-RPC internal error.
  jsonRpcInternalError(-32603),

  /// JSON-RPC invalid method parameters.
  jsonRpcInvalidParams(-32602),

  /// JSON-RPC method not found.
  jsonRpcMethodNotFound(-32601),

  /// JSON-RPC invalid request.
  jsonRpcInvalidRequest(-32600),

  /// Server error: no slot history available.
  jsonRpcServerErrorNoSlotHistory(-32021),

  /// Server error: transaction not found in scan filter.
  jsonRpcServerErrorFilterTransactionNotFound(-32020),

  /// Server error: long-term storage is unreachable.
  jsonRpcServerErrorLongTermStorageUnreachable(-32019),

  /// Server error: slot is not an epoch boundary.
  jsonRpcServerErrorSlotNotEpochBoundary(-32018),

  /// Server error: epoch rewards period is still active.
  jsonRpcServerErrorEpochRewardsPeriodActive(-32017),

  /// Server error: minimum context slot was not reached.
  jsonRpcServerErrorMinContextSlotNotReached(-32016),

  /// Server error: unsupported transaction version.
  jsonRpcServerErrorUnsupportedTransactionVersion(-32015),

  /// Server error: block status not available yet.
  jsonRpcServerErrorBlockStatusNotAvailableYet(-32014),

  /// Server error: transaction signature length mismatch.
  jsonRpcServerErrorTransactionSignatureLenMismatch(-32013),

  /// JSON-RPC scan error.
  jsonRpcScanError(-32012),

  /// Server error: transaction history is not available.
  jsonRpcServerErrorTransactionHistoryNotAvailable(-32011),

  /// Server error: key excluded from secondary index.
  jsonRpcServerErrorKeyExcludedFromSecondaryIndex(-32010),

  /// Server error: long-term storage slot was skipped.
  jsonRpcServerErrorLongTermStorageSlotSkipped(-32009),

  /// Server error: no snapshot available.
  jsonRpcServerErrorNoSnapshot(-32008),

  /// Server error: slot was skipped.
  jsonRpcServerErrorSlotSkipped(-32007),

  /// Server error: transaction precompile verification failure.
  jsonRpcServerErrorTransactionPrecompileVerificationFailure(-32006),

  /// Server error: node is unhealthy.
  jsonRpcServerErrorNodeUnhealthy(-32005),

  /// Server error: block is not available.
  jsonRpcServerErrorBlockNotAvailable(-32004),

  /// Server error: transaction signature verification failure.
  jsonRpcServerErrorTransactionSignatureVerificationFailure(-32003),

  /// Server error: sendTransaction preflight failure.
  jsonRpcServerErrorSendTransactionPreflightFailure(-32002),

  /// Server error: block was cleaned up.
  jsonRpcServerErrorBlockCleanedUp(-32001),

  // ---------------------------------------------------------------------------
  // Addresses (2800000 - 2800999)
  // ---------------------------------------------------------------------------

  /// An address has an invalid byte length.
  addressesInvalidByteLength(2800000),

  /// The address string length is outside the allowed range.
  addressesStringLengthOutOfRange(2800001),

  /// The address is not a valid base58-encoded address.
  addressesInvalidBase58EncodedAddress(2800002),

  /// The value is not a valid Ed25519 public key.
  addressesInvalidEd25519PublicKey(2800003),

  /// The PDA (program derived address) is malformed.
  addressesMalformedPda(2800004),

  /// The PDA bump seed is outside the allowed range.
  addressesPdaBumpSeedOutOfRange(2800005),

  /// The maximum number of PDA seeds was exceeded.
  addressesMaxNumberOfPdaSeedsExceeded(2800006),

  /// The maximum PDA seed length was exceeded.
  addressesMaxPdaSeedLengthExceeded(2800007),

  /// The PDA seeds resolve to a point on the curve.
  addressesInvalidSeedsPointOnCurve(2800008),

  /// Failed to find a viable PDA bump seed.
  addressesFailedToFindViablePdaBumpSeed(2800009),

  /// The PDA ends with the PDA marker.
  addressesPdaEndsWithPdaMarker(2800010),

  /// The address is not a valid off-curve address.
  addressesInvalidOffCurveAddress(2800011),

  // ---------------------------------------------------------------------------
  // Accounts (3230000 - 3230999)
  // ---------------------------------------------------------------------------

  /// The account could not be found.
  accountsAccountNotFound(3230000),

  /// Note: upstream typo — value is 8 digits (32300001) vs 7 for siblings.
  accountsOneOrMoreAccountsNotFound(32300001),

  /// Failed to decode the account data.
  accountsFailedToDecodeAccount(3230002),

  /// Expected a decoded account but received something else.
  accountsExpectedDecodedAccount(3230003),

  /// Expected all accounts to be decoded.
  accountsExpectedAllAccountsToBeDecoded(3230004),

  // ---------------------------------------------------------------------------
  // Subtle Crypto (3610000 - 3610999)
  // ---------------------------------------------------------------------------

  /// SubtleCrypto is disallowed in an insecure context.
  subtleCryptoDisallowedInInsecureContext(3610000),

  /// The requested SubtleCrypto digest is unimplemented.
  subtleCryptoDigestUnimplemented(3610001),

  /// The Ed25519 algorithm is unimplemented in SubtleCrypto.
  subtleCryptoEd25519AlgorithmUnimplemented(3610002),

  /// The SubtleCrypto key export function is unimplemented.
  subtleCryptoExportFunctionUnimplemented(3610003),

  /// The SubtleCrypto key generation function is unimplemented.
  subtleCryptoGenerateFunctionUnimplemented(3610004),

  /// The SubtleCrypto signing function is unimplemented.
  subtleCryptoSignFunctionUnimplemented(3610005),

  /// The SubtleCrypto verify function is unimplemented.
  subtleCryptoVerifyFunctionUnimplemented(3610006),

  /// Cannot export a non-extractable key.
  subtleCryptoCannotExportNonExtractableKey(3610007),

  // ---------------------------------------------------------------------------
  // Crypto (3611000 - 3611050)
  // ---------------------------------------------------------------------------

  /// The `randomValues` function is unimplemented in this environment.
  cryptoRandomValuesFunctionUnimplemented(3611000),

  // ---------------------------------------------------------------------------
  // Keys (3704000 - 3704999)
  // ---------------------------------------------------------------------------

  /// The key pair has an invalid byte length.
  keysInvalidKeyPairByteLength(3704000),

  /// The private key has an invalid byte length.
  keysInvalidPrivateKeyByteLength(3704001),

  /// The signature has an invalid byte length.
  keysInvalidSignatureByteLength(3704002),

  /// The signature string length is outside the allowed range.
  keysSignatureStringLengthOutOfRange(3704003),

  /// The public key must match the private key.
  keysPublicKeyMustMatchPrivateKey(3704004),

  /// The base58 grind regex is invalid.
  keysInvalidBase58InGrindRegex(3704005),

  /// Writing a key pair is unsupported in this environment.
  keysWriteKeyPairUnsupportedEnvironment(3704006),

  // ---------------------------------------------------------------------------
  // Filesystem (3712000 - 3712999)
  // ---------------------------------------------------------------------------

  /// Filesystem access is unsupported in this environment.
  fsUnsupportedEnvironment(3712000),

  // ---------------------------------------------------------------------------
  // Instruction (4128000 - 4128999)
  // ---------------------------------------------------------------------------

  /// The instruction was expected to have accounts.
  instructionExpectedToHaveAccounts(4128000),

  /// The instruction was expected to have data.
  instructionExpectedToHaveData(4128001),

  /// The instruction program id does not match the expected one.
  instructionProgramIdMismatch(4128002),

  // ---------------------------------------------------------------------------
  // Instruction Errors (4615000 - 4615999)
  // ---------------------------------------------------------------------------

  /// An unknown instruction error occurred.
  instructionErrorUnknown(4615000),

  /// A generic instruction error occurred.
  instructionErrorGenericError(4615001),

  /// An invalid argument was passed to the instruction.
  instructionErrorInvalidArgument(4615002),

  /// The instruction data is invalid.
  instructionErrorInvalidInstructionData(4615003),

  /// The account data is invalid.
  instructionErrorInvalidAccountData(4615004),

  /// The account data is too small.
  instructionErrorAccountDataTooSmall(4615005),

  /// There are insufficient funds for the instruction.
  instructionErrorInsufficientFunds(4615006),

  /// The program id is incorrect.
  instructionErrorIncorrectProgramId(4615007),

  /// A required signature is missing.
  instructionErrorMissingRequiredSignature(4615008),

  /// The account is already initialized.
  instructionErrorAccountAlreadyInitialized(4615009),

  /// The account has not been initialized.
  instructionErrorUninitializedAccount(4615010),

  /// The instruction is unbalanced.
  instructionErrorUnbalancedInstruction(4615011),

  /// The program id was modified.
  instructionErrorModifiedProgramId(4615012),

  /// An external account's lamports were spent.
  instructionErrorExternalAccountLamportSpend(4615013),

  /// An external account's data was modified.
  instructionErrorExternalAccountDataModified(4615014),

  /// A read-only account's lamports were changed.
  instructionErrorReadonlyLamportChange(4615015),

  /// A read-only account's data was modified.
  instructionErrorReadonlyDataModified(4615016),

  /// A duplicate account index was encountered.
  instructionErrorDuplicateAccountIndex(4615017),

  /// An executable account was modified.
  instructionErrorExecutableModified(4615018),

  /// The rent epoch was modified.
  instructionErrorRentEpochModified(4615019),

  /// There are not enough account keys.
  instructionErrorNotEnoughAccountKeys(4615020),

  /// The account data size changed.
  instructionErrorAccountDataSizeChanged(4615021),

  /// The account is not executable.
  instructionErrorAccountNotExecutable(4615022),

  /// Borrowing the account failed.
  instructionErrorAccountBorrowFailed(4615023),

  /// There is outstanding account borrow.
  instructionErrorAccountBorrowOutstanding(4615024),

  /// A duplicate account is out of sync.
  instructionErrorDuplicateAccountOutOfSync(4615025),

  /// A custom instruction error occurred.
  instructionErrorCustom(4615026),

  /// The instruction error is invalid.
  instructionErrorInvalidError(4615027),

  /// An executable account's data was modified.
  instructionErrorExecutableDataModified(4615028),

  /// An executable account's lamports changed.
  instructionErrorExecutableLamportChange(4615029),

  /// An executable account is not rent exempt.
  instructionErrorExecutableAccountNotRentExempt(4615030),

  /// The program id is unsupported.
  instructionErrorUnsupportedProgramId(4615031),

  /// The call depth was exceeded.
  instructionErrorCallDepth(4615032),

  /// A required account is missing.
  instructionErrorMissingAccount(4615033),

  /// Reentrancy is not allowed.
  instructionErrorReentrancyNotAllowed(4615034),

  /// The maximum seed length was exceeded.
  instructionErrorMaxSeedLengthExceeded(4615035),

  /// The provided seeds are invalid.
  instructionErrorInvalidSeeds(4615036),

  /// The realloc is invalid.
  instructionErrorInvalidRealloc(4615037),

  /// The computational budget was exceeded.
  instructionErrorComputationalBudgetExceeded(4615038),

  /// An unauthorized privilege escalation was attempted.
  instructionErrorPrivilegeEscalation(4615039),

  /// Setting up the program environment failed.
  instructionErrorProgramEnvironmentSetupFailure(4615040),

  /// The program failed to complete execution.
  instructionErrorProgramFailedToComplete(4615041),

  /// The program failed to compile.
  instructionErrorProgramFailedToCompile(4615042),

  /// The account is immutable.
  instructionErrorImmutable(4615043),

  /// The authority is incorrect.
  instructionErrorIncorrectAuthority(4615044),

  /// A Borsh serialization/deserialization IO error occurred.
  instructionErrorBorshIoError(4615045),

  /// The account is not rent exempt.
  instructionErrorAccountNotRentExempt(4615046),

  /// The account owner is invalid.
  instructionErrorInvalidAccountOwner(4615047),

  /// An arithmetic overflow occurred.
  instructionErrorArithmeticOverflow(4615048),

  /// The sysvar is unsupported.
  instructionErrorUnsupportedSysvar(4615049),

  /// The owner is illegal.
  instructionErrorIllegalOwner(4615050),

  /// The maximum accounts data allocations was exceeded.
  instructionErrorMaxAccountsDataAllocationsExceeded(4615051),

  /// The maximum number of accounts was exceeded.
  instructionErrorMaxAccountsExceeded(4615052),

  /// The maximum instruction trace length was exceeded.
  instructionErrorMaxInstructionTraceLengthExceeded(4615053),

  /// Builtin programs must consume compute units.
  instructionErrorBuiltinProgramsMustConsumeComputeUnits(4615054),

  // ---------------------------------------------------------------------------
  // Signer (5508000 - 5508999)
  // ---------------------------------------------------------------------------

  /// An address cannot have multiple signers.
  signerAddressCannotHaveMultipleSigners(5508000),

  /// Expected a key pair signer.
  signerExpectedKeyPairSigner(5508001),

  /// Expected a message signer.
  signerExpectedMessageSigner(5508002),

  /// Expected a message-modifying signer.
  signerExpectedMessageModifyingSigner(5508003),

  /// Expected a message partial signer.
  signerExpectedMessagePartialSigner(5508004),

  /// Expected a transaction signer.
  signerExpectedTransactionSigner(5508005),

  /// Expected a transaction-modifying signer.
  signerExpectedTransactionModifyingSigner(5508006),

  /// Expected a transaction partial signer.
  signerExpectedTransactionPartialSigner(5508007),

  /// Expected a transaction-sending signer.
  signerExpectedTransactionSendingSigner(5508008),

  /// A transaction cannot have multiple sending signers.
  signerTransactionCannotHaveMultipleSendingSigners(5508009),

  /// The transaction sending signer is missing.
  signerTransactionSendingSignerMissing(5508010),

  /// Wallet multisign is unimplemented.
  signerWalletMultisignUnimplemented(5508011),

  /// The wallet account cannot sign the transaction.
  signerWalletAccountCannotSignTransaction(5508012),

  // ---------------------------------------------------------------------------
  // Offchain Message (5607000 - 5607999)
  // ---------------------------------------------------------------------------

  /// The offchain message exceeds the maximum length.
  offchainMessageMaximumLengthExceeded(5607000),

  /// The offchain message body contains a restricted ASCII character out of range.
  offchainMessageRestrictedAsciiBodyCharacterOutOfRange(5607001),

  /// The application domain string length is outside the allowed range.
  offchainMessageApplicationDomainStringLengthOutOfRange(5607002),

  /// The application domain has an invalid byte length.
  offchainMessageInvalidApplicationDomainByteLength(5607003),

  /// The number of signatures does not match the expected count.
  offchainMessageNumSignaturesMismatch(5607004),

  /// The number of required signers cannot be zero.
  offchainMessageNumRequiredSignersCannotBeZero(5607005),

  /// The offchain message version number is not supported.
  offchainMessageVersionNumberNotSupported(5607006),

  /// The offchain message format does not match the expected one.
  offchainMessageMessageFormatMismatch(5607007),

  /// The offchain message length does not match the expected length.
  offchainMessageMessageLengthMismatch(5607008),

  /// The offchain message must be non-empty.
  offchainMessageMessageMustBeNonEmpty(5607009),

  /// The number of envelope signatures cannot be zero.
  offchainMessageNumEnvelopeSignaturesCannotBeZero(5607010),

  /// Signatures are missing from the offchain message.
  offchainMessageSignaturesMissing(5607011),

  /// The envelope signers do not match the expected signers.
  offchainMessageEnvelopeSignersMismatch(5607012),

  /// The addresses cannot sign the offchain message.
  offchainMessageAddressesCannotSignOffchainMessage(5607013),

  /// An unexpected offchain message version was encountered.
  offchainMessageUnexpectedVersion(5607014),

  /// The signatories must be sorted.
  offchainMessageSignatoriesMustBeSorted(5607015),

  /// The signatories must be unique.
  offchainMessageSignatoriesMustBeUnique(5607016),

  /// Verification of an offchain message signature failed.
  offchainMessageSignatureVerificationFailure(5607017),

  // ---------------------------------------------------------------------------
  // Transaction (5663000 - 5663999)
  // ---------------------------------------------------------------------------

  /// Invoked programs cannot pay fees.
  transactionInvokedProgramsCannotPayFees(5663000),

  /// Invoked programs must not be writable.
  transactionInvokedProgramsMustNotBeWritable(5663001),

  /// Expected a blockhash transaction lifetime.
  transactionExpectedBlockhashLifetime(5663002),

  /// Expected a nonce transaction lifetime.
  transactionExpectedNonceLifetime(5663003),

  /// The transaction version number is out of range.
  transactionVersionNumberOutOfRange(5663004),

  /// Failed to decompile: address lookup table contents are missing.
  transactionFailedToDecompileAddressLookupTableContentsMissing(5663005),

  /// Failed to decompile: an address lookup table index is out of range.
  transactionFailedToDecompileAddressLookupTableIndexOutOfRange(5663006),

  /// Failed to decompile: the instruction program address was not found.
  transactionFailedToDecompileInstructionProgramAddressNotFound(5663007),

  /// Failed to decompile: the fee payer is missing.
  transactionFailedToDecompileFeePayerMissing(5663008),

  /// Transaction signatures are missing.
  transactionSignaturesMissing(5663009),

  /// A transaction address is missing.
  transactionAddressMissing(5663010),

  /// The transaction fee payer is missing.
  transactionFeePayerMissing(5663011),

  /// The fee payer signature is missing.
  transactionFeePayerSignatureMissing(5663012),

  /// The nonce transaction is missing instructions.
  transactionInvalidNonceTransactionInstructionsMissing(5663013),

  /// The first nonce transaction instruction must advance the nonce.
  transactionInvalidNonceTransactionFirstInstructionMustBeAdvanceNonce(5663014),

  /// The addresses cannot sign the transaction.
  transactionAddressesCannotSignTransaction(5663015),

  /// Cannot encode a transaction with empty signatures.
  transactionCannotEncodeWithEmptySignatures(5663016),

  /// The transaction message signatures do not match.
  transactionMessageSignaturesMismatch(5663017),

  /// Failed to estimate the compute limit.
  transactionFailedToEstimateComputeLimit(5663018),

  /// Simulation failed while estimating the compute limit.
  transactionFailedWhenSimulatingToEstimateComputeLimit(5663019),

  /// The transaction exceeds the size limit.
  transactionExceedsSizeLimit(5663020),

  /// The transaction version number is not supported.
  transactionVersionNumberNotSupported(5663021),

  /// The nonce account cannot be in an address lookup table.
  transactionNonceAccountCannotBeInLookupTable(5663022),

  /// The transaction message bytes are malformed.
  transactionMalformedMessageBytes(5663023),

  /// Cannot encode a transaction with empty message bytes.
  transactionCannotEncodeWithEmptyMessageBytes(5663024),

  /// Cannot decode empty transaction bytes.
  transactionCannotDecodeEmptyTransactionBytes(5663025),

  /// Version zero transactions must be encoded with signatures first.
  transactionVersionZeroMustBeEncodedWithSignaturesFirst(5663026),

  /// The signature count is too high for the transaction bytes.
  transactionSignatureCountTooHighForTransactionBytes(5663027),

  /// The config mask has invalid priority fee bits.
  transactionInvalidConfigMaskPriorityFeeBits(5663028),

  /// The nonce account index is invalid.
  transactionInvalidNonceAccountIndex(5663029),

  /// The config value kind is invalid.
  transactionInvalidConfigValueKind(5663030),

  /// The instruction headers and payloads do not match.
  transactionInstructionHeadersPayloadsMismatch(5663031),

  /// There are too many signer addresses.
  transactionTooManySignerAddresses(5663032),

  /// There are too many account addresses.
  transactionTooManyAccountAddresses(5663033),

  /// There are too many instructions.
  transactionTooManyInstructions(5663034),

  /// There are too many accounts in the instruction.
  transactionTooManyAccountsInInstruction(5663035),

  /// Failed to estimate the loaded accounts data size limit.
  transactionFailedToEstimateLoadedAccountsDataSizeLimit(5663036),

  /// Simulation failed while estimating the resource limits.
  transactionFailedWhenSimulatingToEstimateResourceLimits(5663037),

  // ---------------------------------------------------------------------------
  // Transaction Errors (7050000 - 7050999)
  // ---------------------------------------------------------------------------

  /// An unknown transaction error occurred.
  transactionErrorUnknown(7050000),

  /// The account is already in use.
  transactionErrorAccountInUse(7050001),

  /// The account was loaded twice.
  transactionErrorAccountLoadedTwice(7050002),

  /// The account was not found.
  transactionErrorAccountNotFound(7050003),

  /// The program account was not found.
  transactionErrorProgramAccountNotFound(7050004),

  /// There are insufficient funds for the fee.
  transactionErrorInsufficientFundsForFee(7050005),

  /// The account is invalid for paying the fee.
  transactionErrorInvalidAccountForFee(7050006),

  /// The transaction was already processed.
  transactionErrorAlreadyProcessed(7050007),

  /// The blockhash was not found.
  transactionErrorBlockhashNotFound(7050008),

  /// The call chain is too deep.
  transactionErrorCallChainTooDeep(7050009),

  /// The signature for the fee is missing.
  transactionErrorMissingSignatureForFee(7050010),

  /// The account index is invalid.
  transactionErrorInvalidAccountIndex(7050011),

  /// The transaction signature failed verification.
  transactionErrorSignatureFailure(7050012),

  /// The program is invalid for execution.
  transactionErrorInvalidProgramForExecution(7050013),

  /// The transaction failed to sanitize.
  transactionErrorSanitizeFailure(7050014),

  /// The cluster is under maintenance.
  transactionErrorClusterMaintenance(7050015),

  /// There is outstanding account borrow.
  transactionErrorAccountBorrowOutstanding(7050016),

  /// The transaction would exceed the max block cost limit.
  transactionErrorWouldExceedMaxBlockCostLimit(7050017),

  /// The transaction version is unsupported.
  transactionErrorUnsupportedVersion(7050018),

  /// The writable account is invalid.
  transactionErrorInvalidWritableAccount(7050019),

  /// The transaction would exceed the max account cost limit.
  transactionErrorWouldExceedMaxAccountCostLimit(7050020),

  /// The transaction would exceed the account data block limit.
  transactionErrorWouldExceedAccountDataBlockLimit(7050021),

  /// There are too many account locks.
  transactionErrorTooManyAccountLocks(7050022),

  /// The address lookup table was not found.
  transactionErrorAddressLookupTableNotFound(7050023),

  /// The address lookup table owner is invalid.
  transactionErrorInvalidAddressLookupTableOwner(7050024),

  /// The address lookup table data is invalid.
  transactionErrorInvalidAddressLookupTableData(7050025),

  /// The address lookup table index is invalid.
  transactionErrorInvalidAddressLookupTableIndex(7050026),

  /// The rent-paying account is invalid.
  transactionErrorInvalidRentPayingAccount(7050027),

  /// The transaction would exceed the max vote cost limit.
  transactionErrorWouldExceedMaxVoteCostLimit(7050028),

  /// The transaction would exceed the account data total limit.
  transactionErrorWouldExceedAccountDataTotalLimit(7050029),

  /// A duplicate instruction was encountered.
  transactionErrorDuplicateInstruction(7050030),

  /// There are insufficient funds for rent.
  transactionErrorInsufficientFundsForRent(7050031),

  /// The max loaded accounts data size was exceeded.
  transactionErrorMaxLoadedAccountsDataSizeExceeded(7050032),

  /// The loaded accounts data size limit is invalid.
  transactionErrorInvalidLoadedAccountsDataSizeLimit(7050033),

  /// Resanitization is needed.
  transactionErrorResanitizationNeeded(7050034),

  /// Program execution is temporarily restricted.
  transactionErrorProgramExecutionTemporarilyRestricted(7050035),

  /// The transaction is unbalanced.
  transactionErrorUnbalancedTransaction(7050036),

  // ---------------------------------------------------------------------------
  // Instruction Plans (7618000 - 7618999)
  // ---------------------------------------------------------------------------

  /// The message cannot accommodate the instruction plan.
  instructionPlansMessageCannotAccommodatePlan(7618000),

  /// The message packer is already complete.
  instructionPlansMessagePackerAlreadyComplete(7618001),

  /// The instruction plan is empty.
  instructionPlansEmptyInstructionPlan(7618002),

  /// Failed to execute the transaction plan.
  instructionPlansFailedToExecuteTransactionPlan(7618003),

  /// Non-divisible transaction plans are not supported.
  instructionPlansNonDivisibleTransactionPlansNotSupported(7618004),

  /// The single transaction plan result was not found.
  instructionPlansFailedSingleTransactionPlanResultNotFound(7618005),

  /// An unexpected instruction plan was encountered.
  instructionPlansUnexpectedInstructionPlan(7618006),

  /// An unexpected transaction plan was encountered.
  instructionPlansUnexpectedTransactionPlan(7618007),

  /// An unexpected transaction plan result was encountered.
  instructionPlansUnexpectedTransactionPlanResult(7618008),

  /// A successful transaction plan result was expected.
  instructionPlansExpectedSuccessfulTransactionPlanResult(7618009),

  // ---------------------------------------------------------------------------
  // Codecs (8078000 - 8078999)
  // ---------------------------------------------------------------------------

  /// Cannot decode an empty byte array.
  codecsCannotDecodeEmptyByteArray(8078000),

  /// The byte length is invalid.
  codecsInvalidByteLength(8078001),

  /// A fixed-length codec was expected.
  codecsExpectedFixedLength(8078002),

  /// A variable-length codec was expected.
  codecsExpectedVariableLength(8078003),

  /// The encoder and decoder sizes are not compatible.
  codecsEncoderDecoderSizeCompatibilityMismatch(8078004),

  /// The encoder and decoder fixed sizes do not match.
  codecsEncoderDecoderFixedSizeMismatch(8078005),

  /// The encoder and decoder max sizes do not match.
  codecsEncoderDecoderMaxSizeMismatch(8078006),

  /// The number of items is invalid.
  codecsInvalidNumberOfItems(8078007),

  /// The enum discriminator is out of range.
  codecsEnumDiscriminatorOutOfRange(8078008),

  /// The discriminated union variant is invalid.
  codecsInvalidDiscriminatedUnionVariant(8078009),

  /// The enum variant is invalid.
  codecsInvalidEnumVariant(8078010),

  /// The number is out of range.
  codecsNumberOutOfRange(8078011),

  /// The string is invalid for the given base.
  codecsInvalidStringForBase(8078012),

  /// A positive byte length was expected.
  codecsExpectedPositiveByteLength(8078013),

  /// The offset is out of range.
  codecsOffsetOutOfRange(8078014),

  /// The literal union variant is invalid.
  codecsInvalidLiteralUnionVariant(8078015),

  /// The literal union discriminator is out of range.
  codecsLiteralUnionDiscriminatorOutOfRange(8078016),

  /// The union variant is out of range.
  codecsUnionVariantOutOfRange(8078017),

  /// The constant is invalid.
  codecsInvalidConstant(8078018),

  /// A zero value was expected to match the item's fixed size.
  codecsExpectedZeroValueToMatchItemFixedSize(8078019),

  /// The encoded bytes must not include a sentinel.
  codecsEncodedBytesMustNotIncludeSentinel(8078020),

  /// A sentinel is missing in the decoded bytes.
  codecsSentinelMissingInDecodedBytes(8078021),

  /// Lexical values cannot be used as enum discriminators.
  codecsCannotUseLexicalValuesAsEnumDiscriminators(8078022),

  /// The decoder was expected to consume the entire byte array.
  codecsExpectedDecoderToConsumeEntireByteArray(8078023),

  /// The pattern match value is invalid.
  codecsInvalidPatternMatchValue(8078024),

  /// The pattern match bytes are invalid.
  codecsInvalidPatternMatchBytes(8078025),

  /// The string contains null characters.
  codecsStringContainsNullCharacters(8078026),

  // ---------------------------------------------------------------------------
  // Fixed Points (8090000 - 8090999)
  // ---------------------------------------------------------------------------

  /// The total number of bits is invalid.
  fixedPointsInvalidTotalBits(8090000),

  /// The number of fractional bits is invalid.
  fixedPointsInvalidFractionalBits(8090001),

  /// The number of decimals is invalid.
  fixedPointsInvalidDecimals(8090002),

  /// The fractional bits exceed the total bits.
  fixedPointsFractionalBitsExceedTotalBits(8090003),

  /// The fixed-point value is out of range.
  fixedPointsValueOutOfRange(8090004),

  /// The fixed-point string is invalid.
  fixedPointsInvalidString(8090005),

  /// The denominator ratio is a zero value.
  fixedPointsInvalidZeroDenominatorRatio(8090006),

  /// An arithmetic overflow occurred in the fixed-point computation.
  fixedPointsArithmeticOverflow(8090007),

  /// The fixed-point shapes do not match.
  fixedPointsShapeMismatch(8090008),

  /// A division by zero occurred in the fixed-point computation.
  fixedPointsDivisionByZero(8090009),

  /// Precision was lost in strict mode.
  fixedPointsStrictModePrecisionLoss(8090010),

  /// The raw fixed-point value is malformed.
  fixedPointsMalformedRawValue(8090011),

  /// The total bits are not byte-aligned.
  fixedPointsTotalBitsNotByteAligned(8090012),

  // ---------------------------------------------------------------------------
  // RPC (8100000 - 8100999)
  // ---------------------------------------------------------------------------

  /// An integer overflow occurred in an RPC response.
  rpcIntegerOverflow(8100000),

  /// An HTTP header is forbidden for the RPC transport.
  rpcTransportHttpHeaderForbidden(8100001),

  /// An HTTP error occurred in the RPC transport.
  rpcTransportHttpError(8100002),

  /// The API plan is missing for the RPC method.
  rpcApiPlanMissingForRpcMethod(8100003),

  // ---------------------------------------------------------------------------
  // RPC Subscriptions (8190000 - 8190999)
  // ---------------------------------------------------------------------------

  /// Cannot create a subscription plan for the RPC subscription.
  rpcSubscriptionsCannotCreateSubscriptionPlan(8190000),

  /// A server subscription id was expected.
  rpcSubscriptionsExpectedServerSubscriptionId(8190001),

  /// The subscription channel was closed before the message was buffered.
  rpcSubscriptionsChannelClosedBeforeMessageBuffered(8190002),

  /// The subscription channel connection was closed.
  rpcSubscriptionsChannelConnectionClosed(8190003),

  /// The subscription channel failed to connect.
  rpcSubscriptionsChannelFailedToConnect(8190004),

  // ---------------------------------------------------------------------------
  // Subscribable (8195000 - 8195999)
  // ---------------------------------------------------------------------------

  /// Retry is not supported by this subscribable.
  subscribableRetryNotSupported(8195000),

  // ---------------------------------------------------------------------------
  // Program Clients (8500000 - 8500999)
  // ---------------------------------------------------------------------------

  /// There are insufficient account metas for the program client.
  programClientsInsufficientAccountMetas(8500000),

  /// The instruction type is not recognized by the program client.
  programClientsUnrecognizedInstructionType(8500001),

  /// Failed to identify the instruction.
  programClientsFailedToIdentifyInstruction(8500002),

  /// An unexpected resolved instruction input type was encountered.
  programClientsUnexpectedResolvedInstructionInputType(8500003),

  /// A resolved instruction input must be non-null.
  programClientsResolvedInstructionInputMustBeNonNull(8500004),

  /// The account type is not recognized by the program client.
  programClientsUnrecognizedAccountType(8500005),

  /// Failed to identify the account.
  programClientsFailedToIdentifyAccount(8500006),

  // ---------------------------------------------------------------------------
  // Mobile Wallet Adapter - Session (8400000 - 8400049)
  // ---------------------------------------------------------------------------

  /// The MWA association port is out of range.
  mwaAssociationPortOutOfRange(8400000),

  /// The MWA reflector id is out of range.
  mwaReflectorIdOutOfRange(8400001),

  /// The wallet base URL is forbidden.
  mwaForbiddenWalletBaseUrl(8400002),

  /// The MWA session was closed.
  mwaSessionClosed(8400003),

  /// The MWA session timed out.
  mwaSessionTimeout(8400004),

  /// The wallet was not found.
  mwaWalletNotFound(8400005),

  /// The MWA protocol version is invalid.
  mwaInvalidProtocolVersion(8400006),

  /// The platform is not supported.
  mwaPlatformNotSupported(8400007),

  /// The sequence number overflowed.
  mwaSequenceNumberOverflow(8400008),

  /// The sequence number is invalid.
  mwaInvalidSequenceNumber(8400009),

  /// Decryption failed.
  mwaDecryptionFailed(8400010),

  /// Encryption failed.
  mwaEncryptionFailed(8400011),

  /// The MWA handshake failed.
  mwaHandshakeFailed(8400012),

  /// The hello response is invalid.
  mwaInvalidHelloResponse(8400013),

  // ---------------------------------------------------------------------------
  // Mobile Wallet Adapter - Protocol JSON-RPC (8400100 - 8400199)
  // ---------------------------------------------------------------------------

  /// The MWA protocol authorization failed.
  mwaProtocolAuthorizationFailed(8400100),

  /// The MWA protocol payloads are invalid.
  mwaProtocolInvalidPayloads(8400101),

  /// The MWA protocol request was not signed.
  mwaProtocolNotSigned(8400102),

  /// The MWA protocol request was not submitted.
  mwaProtocolNotSubmitted(8400103),

  /// There are too many payloads in the MWA protocol request.
  mwaProtocolTooManyPayloads(8400104),

  /// The attest origin is for Android.
  mwaProtocolAttestOriginAndroid(8400105),

  // ---------------------------------------------------------------------------
  // Helius (8600000 - 8600099)
  // ---------------------------------------------------------------------------

  /// A Helius RPC error occurred.
  heliusRpcError(8600000),

  /// A Helius REST error occurred.
  heliusRestError(8600001),

  /// A Helius API key is required.
  heliusApiKeyRequired(8600002),

  /// A Helius WebSocket error occurred.
  heliusWebSocketError(8600003),

  /// The Helius transaction confirmation timed out.
  heliusTransactionConfirmationTimeout(8600004),

  /// The Helius transaction simulation failed.
  heliusTransactionSimulationFailed(8600005),

  // ---------------------------------------------------------------------------
  // Wallet (8900000 - 8900999)
  // ---------------------------------------------------------------------------

  /// The wallet is not connected.
  walletNotConnected(8900000),

  /// No signer is connected to the wallet.
  walletNoSignerConnected(8900001),

  /// The wallet signer is not available.
  walletSignerNotAvailable(8900002),

  /// The wallet account is not available.
  walletAccountNotAvailable(8900003),

  // ---------------------------------------------------------------------------
  // Invariant Violations (9900000 - 9900999)
  // ---------------------------------------------------------------------------

  /// The subscription iterator state is missing.
  invariantViolationSubscriptionIteratorStateMissing(9900000),

  /// The subscription iterator must not poll before resolving the existing
  /// message promise.
  invariantViolationSubscriptionIteratorMustNotPollBeforeResolvingExistingMessagePromise(
    9900001,
  ),

  /// The cached abortable iterable cache entry is missing.
  invariantViolationCachedAbortableIterableCacheEntryMissing(9900002),

  /// A switch statement must be exhaustive.
  invariantViolationSwitchMustBeExhaustive(9900003),

  /// The data publisher channel is unimplemented.
  invariantViolationDataPublisherChannelUnimplemented(9900004),

  /// The instruction plan kind is invalid.
  invariantViolationInvalidInstructionPlanKind(9900005),

  /// The transaction plan kind is invalid.
  invariantViolationInvalidTransactionPlanKind(9900006);

  /// Creates a [SolanaErrorCode] with the given numeric [value].
  const SolanaErrorCode(this.value);

  /// The numeric error code value, kept in sync with the upstream TypeScript
  /// `@solana/errors` package.
  final int value;

  /// Returns the [SolanaErrorCode] whose [value] equals [value], or `null`
  /// if no matching entry exists.
  static SolanaErrorCode? fromValue(int value) {
    for (final code in SolanaErrorCode.values) {
      if (code.value == value) return code;
    }
    return null;
  }
}
