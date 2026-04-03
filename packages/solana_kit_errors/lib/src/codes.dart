// ignore_for_file: public_member_api_docs
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

  blockHeightExceeded(1),
  invalidNonce(2),
  nonceAccountNotFound(3),
  blockhashStringLengthOutOfRange(4),
  invalidBlockhashByteLength(5),
  lamportsOutOfRange(6),
  malformedBigintString(7),
  malformedNumberString(8),
  timestampOutOfRange(9),
  malformedJsonRpcError(10),
  failedToSendTransaction(11),
  failedToSendTransactions(12),

  // ---------------------------------------------------------------------------
  // JSON-RPC (-32768 to -32000)
  // ---------------------------------------------------------------------------

  jsonRpcParseError(-32700),
  jsonRpcInternalError(-32603),
  jsonRpcInvalidParams(-32602),
  jsonRpcMethodNotFound(-32601),
  jsonRpcInvalidRequest(-32600),
  jsonRpcServerErrorLongTermStorageUnreachable(-32019),
  jsonRpcServerErrorSlotNotEpochBoundary(-32018),
  jsonRpcServerErrorEpochRewardsPeriodActive(-32017),
  jsonRpcServerErrorMinContextSlotNotReached(-32016),
  jsonRpcServerErrorUnsupportedTransactionVersion(-32015),
  jsonRpcServerErrorBlockStatusNotAvailableYet(-32014),
  jsonRpcServerErrorTransactionSignatureLenMismatch(-32013),
  jsonRpcScanError(-32012),
  jsonRpcServerErrorTransactionHistoryNotAvailable(-32011),
  jsonRpcServerErrorKeyExcludedFromSecondaryIndex(-32010),
  jsonRpcServerErrorLongTermStorageSlotSkipped(-32009),
  jsonRpcServerErrorNoSnapshot(-32008),
  jsonRpcServerErrorSlotSkipped(-32007),
  jsonRpcServerErrorTransactionPrecompileVerificationFailure(-32006),
  jsonRpcServerErrorNodeUnhealthy(-32005),
  jsonRpcServerErrorBlockNotAvailable(-32004),
  jsonRpcServerErrorTransactionSignatureVerificationFailure(-32003),
  jsonRpcServerErrorSendTransactionPreflightFailure(-32002),
  jsonRpcServerErrorBlockCleanedUp(-32001),

  // ---------------------------------------------------------------------------
  // Addresses (2800000 - 2800999)
  // ---------------------------------------------------------------------------

  addressesInvalidByteLength(2800000),
  addressesStringLengthOutOfRange(2800001),
  addressesInvalidBase58EncodedAddress(2800002),
  addressesInvalidEd25519PublicKey(2800003),
  addressesMalformedPda(2800004),
  addressesPdaBumpSeedOutOfRange(2800005),
  addressesMaxNumberOfPdaSeedsExceeded(2800006),
  addressesMaxPdaSeedLengthExceeded(2800007),
  addressesInvalidSeedsPointOnCurve(2800008),
  addressesFailedToFindViablePdaBumpSeed(2800009),
  addressesPdaEndsWithPdaMarker(2800010),
  addressesInvalidOffCurveAddress(2800011),

  // ---------------------------------------------------------------------------
  // Accounts (3230000 - 3230999)
  // ---------------------------------------------------------------------------

  accountsAccountNotFound(3230000),

  /// Note: upstream typo — value is 8 digits (32300001) vs 7 for siblings.
  accountsOneOrMoreAccountsNotFound(32300001),
  accountsFailedToDecodeAccount(3230002),
  accountsExpectedDecodedAccount(3230003),
  accountsExpectedAllAccountsToBeDecoded(3230004),

  // ---------------------------------------------------------------------------
  // Subtle Crypto (3610000 - 3610999)
  // ---------------------------------------------------------------------------

  subtleCryptoDisallowedInInsecureContext(3610000),
  subtleCryptoDigestUnimplemented(3610001),
  subtleCryptoEd25519AlgorithmUnimplemented(3610002),
  subtleCryptoExportFunctionUnimplemented(3610003),
  subtleCryptoGenerateFunctionUnimplemented(3610004),
  subtleCryptoSignFunctionUnimplemented(3610005),
  subtleCryptoVerifyFunctionUnimplemented(3610006),
  subtleCryptoCannotExportNonExtractableKey(3610007),

  // ---------------------------------------------------------------------------
  // Crypto (3611000 - 3611050)
  // ---------------------------------------------------------------------------

  cryptoRandomValuesFunctionUnimplemented(3611000),

  // ---------------------------------------------------------------------------
  // Keys (3704000 - 3704999)
  // ---------------------------------------------------------------------------

  keysInvalidKeyPairByteLength(3704000),
  keysInvalidPrivateKeyByteLength(3704001),
  keysInvalidSignatureByteLength(3704002),
  keysSignatureStringLengthOutOfRange(3704003),
  keysPublicKeyMustMatchPrivateKey(3704004),

  // ---------------------------------------------------------------------------
  // Instruction (4128000 - 4128999)
  // ---------------------------------------------------------------------------

  instructionExpectedToHaveAccounts(4128000),
  instructionExpectedToHaveData(4128001),
  instructionProgramIdMismatch(4128002),

  // ---------------------------------------------------------------------------
  // Instruction Errors (4615000 - 4615999)
  // ---------------------------------------------------------------------------

  instructionErrorUnknown(4615000),
  instructionErrorGenericError(4615001),
  instructionErrorInvalidArgument(4615002),
  instructionErrorInvalidInstructionData(4615003),
  instructionErrorInvalidAccountData(4615004),
  instructionErrorAccountDataTooSmall(4615005),
  instructionErrorInsufficientFunds(4615006),
  instructionErrorIncorrectProgramId(4615007),
  instructionErrorMissingRequiredSignature(4615008),
  instructionErrorAccountAlreadyInitialized(4615009),
  instructionErrorUninitializedAccount(4615010),
  instructionErrorUnbalancedInstruction(4615011),
  instructionErrorModifiedProgramId(4615012),
  instructionErrorExternalAccountLamportSpend(4615013),
  instructionErrorExternalAccountDataModified(4615014),
  instructionErrorReadonlyLamportChange(4615015),
  instructionErrorReadonlyDataModified(4615016),
  instructionErrorDuplicateAccountIndex(4615017),
  instructionErrorExecutableModified(4615018),
  instructionErrorRentEpochModified(4615019),
  instructionErrorNotEnoughAccountKeys(4615020),
  instructionErrorAccountDataSizeChanged(4615021),
  instructionErrorAccountNotExecutable(4615022),
  instructionErrorAccountBorrowFailed(4615023),
  instructionErrorAccountBorrowOutstanding(4615024),
  instructionErrorDuplicateAccountOutOfSync(4615025),
  instructionErrorCustom(4615026),
  instructionErrorInvalidError(4615027),
  instructionErrorExecutableDataModified(4615028),
  instructionErrorExecutableLamportChange(4615029),
  instructionErrorExecutableAccountNotRentExempt(4615030),
  instructionErrorUnsupportedProgramId(4615031),
  instructionErrorCallDepth(4615032),
  instructionErrorMissingAccount(4615033),
  instructionErrorReentrancyNotAllowed(4615034),
  instructionErrorMaxSeedLengthExceeded(4615035),
  instructionErrorInvalidSeeds(4615036),
  instructionErrorInvalidRealloc(4615037),
  instructionErrorComputationalBudgetExceeded(4615038),
  instructionErrorPrivilegeEscalation(4615039),
  instructionErrorProgramEnvironmentSetupFailure(4615040),
  instructionErrorProgramFailedToComplete(4615041),
  instructionErrorProgramFailedToCompile(4615042),
  instructionErrorImmutable(4615043),
  instructionErrorIncorrectAuthority(4615044),
  instructionErrorBorshIoError(4615045),
  instructionErrorAccountNotRentExempt(4615046),
  instructionErrorInvalidAccountOwner(4615047),
  instructionErrorArithmeticOverflow(4615048),
  instructionErrorUnsupportedSysvar(4615049),
  instructionErrorIllegalOwner(4615050),
  instructionErrorMaxAccountsDataAllocationsExceeded(4615051),
  instructionErrorMaxAccountsExceeded(4615052),
  instructionErrorMaxInstructionTraceLengthExceeded(4615053),
  instructionErrorBuiltinProgramsMustConsumeComputeUnits(4615054),

  // ---------------------------------------------------------------------------
  // Signer (5508000 - 5508999)
  // ---------------------------------------------------------------------------

  signerAddressCannotHaveMultipleSigners(5508000),
  signerExpectedKeyPairSigner(5508001),
  signerExpectedMessageSigner(5508002),
  signerExpectedMessageModifyingSigner(5508003),
  signerExpectedMessagePartialSigner(5508004),
  signerExpectedTransactionSigner(5508005),
  signerExpectedTransactionModifyingSigner(5508006),
  signerExpectedTransactionPartialSigner(5508007),
  signerExpectedTransactionSendingSigner(5508008),
  signerTransactionCannotHaveMultipleSendingSigners(5508009),
  signerTransactionSendingSignerMissing(5508010),
  signerWalletMultisignUnimplemented(5508011),
  signerWalletAccountCannotSignTransaction(5508012),

  // ---------------------------------------------------------------------------
  // Offchain Message (5607000 - 5607999)
  // ---------------------------------------------------------------------------

  offchainMessageMaximumLengthExceeded(5607000),
  offchainMessageRestrictedAsciiBodyCharacterOutOfRange(5607001),
  offchainMessageApplicationDomainStringLengthOutOfRange(5607002),
  offchainMessageInvalidApplicationDomainByteLength(5607003),
  offchainMessageNumSignaturesMismatch(5607004),
  offchainMessageNumRequiredSignersCannotBeZero(5607005),
  offchainMessageVersionNumberNotSupported(5607006),
  offchainMessageMessageFormatMismatch(5607007),
  offchainMessageMessageLengthMismatch(5607008),
  offchainMessageMessageMustBeNonEmpty(5607009),
  offchainMessageNumEnvelopeSignaturesCannotBeZero(5607010),
  offchainMessageSignaturesMissing(5607011),
  offchainMessageEnvelopeSignersMismatch(5607012),
  offchainMessageAddressesCannotSignOffchainMessage(5607013),
  offchainMessageUnexpectedVersion(5607014),
  offchainMessageSignatoriesMustBeSorted(5607015),
  offchainMessageSignatoriesMustBeUnique(5607016),
  offchainMessageSignatureVerificationFailure(5607017),

  // ---------------------------------------------------------------------------
  // Transaction (5663000 - 5663999)
  // ---------------------------------------------------------------------------

  transactionInvokedProgramsCannotPayFees(5663000),
  transactionInvokedProgramsMustNotBeWritable(5663001),
  transactionExpectedBlockhashLifetime(5663002),
  transactionExpectedNonceLifetime(5663003),
  transactionVersionNumberOutOfRange(5663004),
  transactionFailedToDecompileAddressLookupTableContentsMissing(5663005),
  transactionFailedToDecompileAddressLookupTableIndexOutOfRange(5663006),
  transactionFailedToDecompileInstructionProgramAddressNotFound(5663007),
  transactionFailedToDecompileFeePayerMissing(5663008),
  transactionSignaturesMissing(5663009),
  transactionAddressMissing(5663010),
  transactionFeePayerMissing(5663011),
  transactionFeePayerSignatureMissing(5663012),
  transactionInvalidNonceTransactionInstructionsMissing(5663013),
  transactionInvalidNonceTransactionFirstInstructionMustBeAdvanceNonce(
    5663014,
  ),
  transactionAddressesCannotSignTransaction(5663015),
  transactionCannotEncodeWithEmptySignatures(5663016),
  transactionMessageSignaturesMismatch(5663017),
  transactionFailedToEstimateComputeLimit(5663018),
  transactionFailedWhenSimulatingToEstimateComputeLimit(5663019),
  transactionExceedsSizeLimit(5663020),
  transactionVersionNumberNotSupported(5663021),
  transactionNonceAccountCannotBeInLookupTable(5663022),
  transactionMalformedMessageBytes(5663023),
  transactionCannotEncodeWithEmptyMessageBytes(5663024),
  transactionCannotDecodeEmptyTransactionBytes(5663025),
  transactionVersionZeroMustBeEncodedWithSignaturesFirst(5663026),
  transactionSignatureCountTooHighForTransactionBytes(5663027),
  transactionInvalidConfigMaskPriorityFeeBits(5663028),
  transactionInvalidNonceAccountIndex(5663029),
  transactionInvalidConfigValueKind(5663030),
  transactionInstructionHeadersPayloadsMismatch(5663031),

  // ---------------------------------------------------------------------------
  // Transaction Errors (7050000 - 7050999)
  // ---------------------------------------------------------------------------

  transactionErrorUnknown(7050000),
  transactionErrorAccountInUse(7050001),
  transactionErrorAccountLoadedTwice(7050002),
  transactionErrorAccountNotFound(7050003),
  transactionErrorProgramAccountNotFound(7050004),
  transactionErrorInsufficientFundsForFee(7050005),
  transactionErrorInvalidAccountForFee(7050006),
  transactionErrorAlreadyProcessed(7050007),
  transactionErrorBlockhashNotFound(7050008),
  transactionErrorCallChainTooDeep(7050009),
  transactionErrorMissingSignatureForFee(7050010),
  transactionErrorInvalidAccountIndex(7050011),
  transactionErrorSignatureFailure(7050012),
  transactionErrorInvalidProgramForExecution(7050013),
  transactionErrorSanitizeFailure(7050014),
  transactionErrorClusterMaintenance(7050015),
  transactionErrorAccountBorrowOutstanding(7050016),
  transactionErrorWouldExceedMaxBlockCostLimit(7050017),
  transactionErrorUnsupportedVersion(7050018),
  transactionErrorInvalidWritableAccount(7050019),
  transactionErrorWouldExceedMaxAccountCostLimit(7050020),
  transactionErrorWouldExceedAccountDataBlockLimit(7050021),
  transactionErrorTooManyAccountLocks(7050022),
  transactionErrorAddressLookupTableNotFound(7050023),
  transactionErrorInvalidAddressLookupTableOwner(7050024),
  transactionErrorInvalidAddressLookupTableData(7050025),
  transactionErrorInvalidAddressLookupTableIndex(7050026),
  transactionErrorInvalidRentPayingAccount(7050027),
  transactionErrorWouldExceedMaxVoteCostLimit(7050028),
  transactionErrorWouldExceedAccountDataTotalLimit(7050029),
  transactionErrorDuplicateInstruction(7050030),
  transactionErrorInsufficientFundsForRent(7050031),
  transactionErrorMaxLoadedAccountsDataSizeExceeded(7050032),
  transactionErrorInvalidLoadedAccountsDataSizeLimit(7050033),
  transactionErrorResanitizationNeeded(7050034),
  transactionErrorProgramExecutionTemporarilyRestricted(7050035),
  transactionErrorUnbalancedTransaction(7050036),

  // ---------------------------------------------------------------------------
  // Instruction Plans (7618000 - 7618999)
  // ---------------------------------------------------------------------------

  instructionPlansMessageCannotAccommodatePlan(7618000),
  instructionPlansMessagePackerAlreadyComplete(7618001),
  instructionPlansEmptyInstructionPlan(7618002),
  instructionPlansFailedToExecuteTransactionPlan(7618003),
  instructionPlansNonDivisibleTransactionPlansNotSupported(7618004),
  instructionPlansFailedSingleTransactionPlanResultNotFound(7618005),
  instructionPlansUnexpectedInstructionPlan(7618006),
  instructionPlansUnexpectedTransactionPlan(7618007),
  instructionPlansUnexpectedTransactionPlanResult(7618008),
  instructionPlansExpectedSuccessfulTransactionPlanResult(7618009),

  // ---------------------------------------------------------------------------
  // Codecs (8078000 - 8078999)
  // ---------------------------------------------------------------------------

  codecsCannotDecodeEmptyByteArray(8078000),
  codecsInvalidByteLength(8078001),
  codecsExpectedFixedLength(8078002),
  codecsExpectedVariableLength(8078003),
  codecsEncoderDecoderSizeCompatibilityMismatch(8078004),
  codecsEncoderDecoderFixedSizeMismatch(8078005),
  codecsEncoderDecoderMaxSizeMismatch(8078006),
  codecsInvalidNumberOfItems(8078007),
  codecsEnumDiscriminatorOutOfRange(8078008),
  codecsInvalidDiscriminatedUnionVariant(8078009),
  codecsInvalidEnumVariant(8078010),
  codecsNumberOutOfRange(8078011),
  codecsInvalidStringForBase(8078012),
  codecsExpectedPositiveByteLength(8078013),
  codecsOffsetOutOfRange(8078014),
  codecsInvalidLiteralUnionVariant(8078015),
  codecsLiteralUnionDiscriminatorOutOfRange(8078016),
  codecsUnionVariantOutOfRange(8078017),
  codecsInvalidConstant(8078018),
  codecsExpectedZeroValueToMatchItemFixedSize(8078019),
  codecsEncodedBytesMustNotIncludeSentinel(8078020),
  codecsSentinelMissingInDecodedBytes(8078021),
  codecsCannotUseLexicalValuesAsEnumDiscriminators(8078022),
  codecsExpectedDecoderToConsumeEntireByteArray(8078023),
  codecsInvalidPatternMatchValue(8078024),
  codecsInvalidPatternMatchBytes(8078025),
  codecsStringContainsNullCharacters(8078026),

  // ---------------------------------------------------------------------------
  // RPC (8100000 - 8100999)
  // ---------------------------------------------------------------------------

  rpcIntegerOverflow(8100000),
  rpcTransportHttpHeaderForbidden(8100001),
  rpcTransportHttpError(8100002),
  rpcApiPlanMissingForRpcMethod(8100003),

  // ---------------------------------------------------------------------------
  // RPC Subscriptions (8190000 - 8190999)
  // ---------------------------------------------------------------------------

  rpcSubscriptionsCannotCreateSubscriptionPlan(8190000),
  rpcSubscriptionsExpectedServerSubscriptionId(8190001),
  rpcSubscriptionsChannelClosedBeforeMessageBuffered(8190002),
  rpcSubscriptionsChannelConnectionClosed(8190003),
  rpcSubscriptionsChannelFailedToConnect(8190004),

  // ---------------------------------------------------------------------------
  // Program Clients (8500000 - 8500999)
  // ---------------------------------------------------------------------------

  programClientsInsufficientAccountMetas(8500000),
  programClientsUnrecognizedInstructionType(8500001),
  programClientsFailedToIdentifyInstruction(8500002),
  programClientsUnexpectedResolvedInstructionInputType(8500003),
  programClientsResolvedInstructionInputMustBeNonNull(8500004),
  programClientsUnrecognizedAccountType(8500005),
  programClientsFailedToIdentifyAccount(8500006),

  // ---------------------------------------------------------------------------
  // Mobile Wallet Adapter - Session (8400000 - 8400049)
  // ---------------------------------------------------------------------------

  mwaAssociationPortOutOfRange(8400000),
  mwaReflectorIdOutOfRange(8400001),
  mwaForbiddenWalletBaseUrl(8400002),
  mwaSessionClosed(8400003),
  mwaSessionTimeout(8400004),
  mwaWalletNotFound(8400005),
  mwaInvalidProtocolVersion(8400006),
  mwaPlatformNotSupported(8400007),
  mwaSequenceNumberOverflow(8400008),
  mwaInvalidSequenceNumber(8400009),
  mwaDecryptionFailed(8400010),
  mwaEncryptionFailed(8400011),
  mwaHandshakeFailed(8400012),
  mwaInvalidHelloResponse(8400013),

  // ---------------------------------------------------------------------------
  // Mobile Wallet Adapter - Protocol JSON-RPC (8400100 - 8400199)
  // ---------------------------------------------------------------------------

  mwaProtocolAuthorizationFailed(8400100),
  mwaProtocolInvalidPayloads(8400101),
  mwaProtocolNotSigned(8400102),
  mwaProtocolNotSubmitted(8400103),
  mwaProtocolTooManyPayloads(8400104),
  mwaProtocolAttestOriginAndroid(8400105),

  // ---------------------------------------------------------------------------
  // Helius (8600000 - 8600099)
  // ---------------------------------------------------------------------------

  heliusRpcError(8600000),
  heliusRestError(8600001),
  heliusApiKeyRequired(8600002),
  heliusWebSocketError(8600003),
  heliusTransactionConfirmationTimeout(8600004),
  heliusTransactionSimulationFailed(8600005),

  // ---------------------------------------------------------------------------
  // Invariant Violations (9900000 - 9900999)
  // ---------------------------------------------------------------------------

  invariantViolationSubscriptionIteratorStateMissing(9900000),
  invariantViolationSubscriptionIteratorMustNotPollBeforeResolvingExistingMessagePromise(
    9900001,
  ),
  invariantViolationCachedAbortableIterableCacheEntryMissing(9900002),
  invariantViolationSwitchMustBeExhaustive(9900003),
  invariantViolationDataPublisherChannelUnimplemented(9900004),
  invariantViolationInvalidInstructionPlanKind(9900005),
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
