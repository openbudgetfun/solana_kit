/// All Solana error code constants ported from the TypeScript `@solana/errors`
/// package.
///
/// Each constant corresponds to a unique error condition in the Solana web3
/// stack. The numeric values are kept in sync with the upstream TypeScript
/// source so that error codes are interoperable across implementations.
abstract final class SolanaErrorCode {
  // ---------------------------------------------------------------------------
  // General (1 - 10)
  // ---------------------------------------------------------------------------

  static const int blockHeightExceeded = 1;
  static const int invalidNonce = 2;
  static const int nonceAccountNotFound = 3;
  static const int blockhashStringLengthOutOfRange = 4;
  static const int invalidBlockhashByteLength = 5;
  static const int lamportsOutOfRange = 6;
  static const int malformedBigintString = 7;
  static const int malformedNumberString = 8;
  static const int timestampOutOfRange = 9;
  static const int malformedJsonRpcError = 10;

  // ---------------------------------------------------------------------------
  // JSON-RPC (-32768 to -32000)
  // ---------------------------------------------------------------------------

  static const int jsonRpcParseError = -32700;
  static const int jsonRpcInternalError = -32603;
  static const int jsonRpcInvalidParams = -32602;
  static const int jsonRpcMethodNotFound = -32601;
  static const int jsonRpcInvalidRequest = -32600;
  static const int jsonRpcServerErrorLongTermStorageUnreachable = -32019;
  static const int jsonRpcServerErrorSlotNotEpochBoundary = -32018;
  static const int jsonRpcServerErrorEpochRewardsPeriodActive = -32017;
  static const int jsonRpcServerErrorMinContextSlotNotReached = -32016;
  static const int jsonRpcServerErrorUnsupportedTransactionVersion = -32015;
  static const int jsonRpcServerErrorBlockStatusNotAvailableYet = -32014;
  static const int jsonRpcServerErrorTransactionSignatureLenMismatch = -32013;
  static const int jsonRpcScanError = -32012;
  static const int jsonRpcServerErrorTransactionHistoryNotAvailable = -32011;
  static const int jsonRpcServerErrorKeyExcludedFromSecondaryIndex = -32010;
  static const int jsonRpcServerErrorLongTermStorageSlotSkipped = -32009;
  static const int jsonRpcServerErrorNoSnapshot = -32008;
  static const int jsonRpcServerErrorSlotSkipped = -32007;
  static const int jsonRpcServerErrorTransactionPrecompileVerificationFailure =
      -32006;
  static const int jsonRpcServerErrorNodeUnhealthy = -32005;
  static const int jsonRpcServerErrorBlockNotAvailable = -32004;
  static const int jsonRpcServerErrorTransactionSignatureVerificationFailure =
      -32003;
  static const int jsonRpcServerErrorSendTransactionPreflightFailure = -32002;
  static const int jsonRpcServerErrorBlockCleanedUp = -32001;

  // ---------------------------------------------------------------------------
  // Addresses (2800000 - 2800999)
  // ---------------------------------------------------------------------------

  static const int addressesInvalidByteLength = 2800000;
  static const int addressesStringLengthOutOfRange = 2800001;
  static const int addressesInvalidBase58EncodedAddress = 2800002;
  static const int addressesInvalidEd25519PublicKey = 2800003;
  static const int addressesMalformedPda = 2800004;
  static const int addressesPdaBumpSeedOutOfRange = 2800005;
  static const int addressesMaxNumberOfPdaSeedsExceeded = 2800006;
  static const int addressesMaxPdaSeedLengthExceeded = 2800007;
  static const int addressesInvalidSeedsPointOnCurve = 2800008;
  static const int addressesFailedToFindViablePdaBumpSeed = 2800009;
  static const int addressesPdaEndsWithPdaMarker = 2800010;
  static const int addressesInvalidOffCurveAddress = 2800011;

  // ---------------------------------------------------------------------------
  // Accounts (3230000 - 3230999)
  // ---------------------------------------------------------------------------

  static const int accountsAccountNotFound = 3230000;
  static const int accountsOneOrMoreAccountsNotFound = 32300001;
  static const int accountsFailedToDecodeAccount = 3230002;
  static const int accountsExpectedDecodedAccount = 3230003;
  static const int accountsExpectedAllAccountsToBeDecoded = 3230004;

  // ---------------------------------------------------------------------------
  // Subtle Crypto (3610000 - 3610999)
  // ---------------------------------------------------------------------------

  static const int subtleCryptoDisallowedInInsecureContext = 3610000;
  static const int subtleCryptoDigestUnimplemented = 3610001;
  static const int subtleCryptoEd25519AlgorithmUnimplemented = 3610002;
  static const int subtleCryptoExportFunctionUnimplemented = 3610003;
  static const int subtleCryptoGenerateFunctionUnimplemented = 3610004;
  static const int subtleCryptoSignFunctionUnimplemented = 3610005;
  static const int subtleCryptoVerifyFunctionUnimplemented = 3610006;
  static const int subtleCryptoCannotExportNonExtractableKey = 3610007;

  // ---------------------------------------------------------------------------
  // Crypto (3611000 - 3611050)
  // ---------------------------------------------------------------------------

  static const int cryptoRandomValuesFunctionUnimplemented = 3611000;

  // ---------------------------------------------------------------------------
  // Keys (3704000 - 3704999)
  // ---------------------------------------------------------------------------

  static const int keysInvalidKeyPairByteLength = 3704000;
  static const int keysInvalidPrivateKeyByteLength = 3704001;
  static const int keysInvalidSignatureByteLength = 3704002;
  static const int keysSignatureStringLengthOutOfRange = 3704003;
  static const int keysPublicKeyMustMatchPrivateKey = 3704004;

  // ---------------------------------------------------------------------------
  // Instruction (4128000 - 4128999)
  // ---------------------------------------------------------------------------

  static const int instructionExpectedToHaveAccounts = 4128000;
  static const int instructionExpectedToHaveData = 4128001;
  static const int instructionProgramIdMismatch = 4128002;

  // ---------------------------------------------------------------------------
  // Instruction Errors (4615000 - 4615999)
  // ---------------------------------------------------------------------------

  static const int instructionErrorUnknown = 4615000;
  static const int instructionErrorGenericError = 4615001;
  static const int instructionErrorInvalidArgument = 4615002;
  static const int instructionErrorInvalidInstructionData = 4615003;
  static const int instructionErrorInvalidAccountData = 4615004;
  static const int instructionErrorAccountDataTooSmall = 4615005;
  static const int instructionErrorInsufficientFunds = 4615006;
  static const int instructionErrorIncorrectProgramId = 4615007;
  static const int instructionErrorMissingRequiredSignature = 4615008;
  static const int instructionErrorAccountAlreadyInitialized = 4615009;
  static const int instructionErrorUninitializedAccount = 4615010;
  static const int instructionErrorUnbalancedInstruction = 4615011;
  static const int instructionErrorModifiedProgramId = 4615012;
  static const int instructionErrorExternalAccountLamportSpend = 4615013;
  static const int instructionErrorExternalAccountDataModified = 4615014;
  static const int instructionErrorReadonlyLamportChange = 4615015;
  static const int instructionErrorReadonlyDataModified = 4615016;
  static const int instructionErrorDuplicateAccountIndex = 4615017;
  static const int instructionErrorExecutableModified = 4615018;
  static const int instructionErrorRentEpochModified = 4615019;
  static const int instructionErrorNotEnoughAccountKeys = 4615020;
  static const int instructionErrorAccountDataSizeChanged = 4615021;
  static const int instructionErrorAccountNotExecutable = 4615022;
  static const int instructionErrorAccountBorrowFailed = 4615023;
  static const int instructionErrorAccountBorrowOutstanding = 4615024;
  static const int instructionErrorDuplicateAccountOutOfSync = 4615025;
  static const int instructionErrorCustom = 4615026;
  static const int instructionErrorInvalidError = 4615027;
  static const int instructionErrorExecutableDataModified = 4615028;
  static const int instructionErrorExecutableLamportChange = 4615029;
  static const int instructionErrorExecutableAccountNotRentExempt = 4615030;
  static const int instructionErrorUnsupportedProgramId = 4615031;
  static const int instructionErrorCallDepth = 4615032;
  static const int instructionErrorMissingAccount = 4615033;
  static const int instructionErrorReentrancyNotAllowed = 4615034;
  static const int instructionErrorMaxSeedLengthExceeded = 4615035;
  static const int instructionErrorInvalidSeeds = 4615036;
  static const int instructionErrorInvalidRealloc = 4615037;
  static const int instructionErrorComputationalBudgetExceeded = 4615038;
  static const int instructionErrorPrivilegeEscalation = 4615039;
  static const int instructionErrorProgramEnvironmentSetupFailure = 4615040;
  static const int instructionErrorProgramFailedToComplete = 4615041;
  static const int instructionErrorProgramFailedToCompile = 4615042;
  static const int instructionErrorImmutable = 4615043;
  static const int instructionErrorIncorrectAuthority = 4615044;
  static const int instructionErrorBorshIoError = 4615045;
  static const int instructionErrorAccountNotRentExempt = 4615046;
  static const int instructionErrorInvalidAccountOwner = 4615047;
  static const int instructionErrorArithmeticOverflow = 4615048;
  static const int instructionErrorUnsupportedSysvar = 4615049;
  static const int instructionErrorIllegalOwner = 4615050;
  static const int instructionErrorMaxAccountsDataAllocationsExceeded = 4615051;
  static const int instructionErrorMaxAccountsExceeded = 4615052;
  static const int instructionErrorMaxInstructionTraceLengthExceeded = 4615053;
  static const int instructionErrorBuiltinProgramsMustConsumeComputeUnits =
      4615054;

  // ---------------------------------------------------------------------------
  // Signer (5508000 - 5508999)
  // ---------------------------------------------------------------------------

  static const int signerAddressCannotHaveMultipleSigners = 5508000;
  static const int signerExpectedKeyPairSigner = 5508001;
  static const int signerExpectedMessageSigner = 5508002;
  static const int signerExpectedMessageModifyingSigner = 5508003;
  static const int signerExpectedMessagePartialSigner = 5508004;
  static const int signerExpectedTransactionSigner = 5508005;
  static const int signerExpectedTransactionModifyingSigner = 5508006;
  static const int signerExpectedTransactionPartialSigner = 5508007;
  static const int signerExpectedTransactionSendingSigner = 5508008;
  static const int signerTransactionCannotHaveMultipleSendingSigners = 5508009;
  static const int signerTransactionSendingSignerMissing = 5508010;
  static const int signerWalletMultisignUnimplemented = 5508011;

  // ---------------------------------------------------------------------------
  // Offchain Message (5607000 - 5607999)
  // ---------------------------------------------------------------------------

  static const int offchainMessageMaximumLengthExceeded = 5607000;
  static const int offchainMessageRestrictedAsciiBodyCharacterOutOfRange =
      5607001;
  static const int offchainMessageApplicationDomainStringLengthOutOfRange =
      5607002;
  static const int offchainMessageInvalidApplicationDomainByteLength = 5607003;
  static const int offchainMessageNumSignaturesMismatch = 5607004;
  static const int offchainMessageNumRequiredSignersCannotBeZero = 5607005;
  static const int offchainMessageVersionNumberNotSupported = 5607006;
  static const int offchainMessageMessageFormatMismatch = 5607007;
  static const int offchainMessageMessageLengthMismatch = 5607008;
  static const int offchainMessageMessageMustBeNonEmpty = 5607009;
  static const int offchainMessageNumEnvelopeSignaturesCannotBeZero = 5607010;
  static const int offchainMessageSignaturesMissing = 5607011;
  static const int offchainMessageEnvelopeSignersMismatch = 5607012;
  static const int offchainMessageAddressesCannotSignOffchainMessage = 5607013;
  static const int offchainMessageUnexpectedVersion = 5607014;
  static const int offchainMessageSignatoriesMustBeSorted = 5607015;
  static const int offchainMessageSignatoriesMustBeUnique = 5607016;
  static const int offchainMessageSignatureVerificationFailure = 5607017;

  // ---------------------------------------------------------------------------
  // Transaction (5663000 - 5663999)
  // ---------------------------------------------------------------------------

  static const int transactionInvokedProgramsCannotPayFees = 5663000;
  static const int transactionInvokedProgramsMustNotBeWritable = 5663001;
  static const int transactionExpectedBlockhashLifetime = 5663002;
  static const int transactionExpectedNonceLifetime = 5663003;
  static const int transactionVersionNumberOutOfRange = 5663004;
  static const int
  transactionFailedToDecompileAddressLookupTableContentsMissing = 5663005;
  static const int
  transactionFailedToDecompileAddressLookupTableIndexOutOfRange = 5663006;
  static const int
  transactionFailedToDecompileInstructionProgramAddressNotFound = 5663007;
  static const int transactionFailedToDecompileFeePayerMissing = 5663008;
  static const int transactionSignaturesMissing = 5663009;
  static const int transactionAddressMissing = 5663010;
  static const int transactionFeePayerMissing = 5663011;
  static const int transactionFeePayerSignatureMissing = 5663012;
  static const int transactionInvalidNonceTransactionInstructionsMissing =
      5663013;
  static const int
  transactionInvalidNonceTransactionFirstInstructionMustBeAdvanceNonce =
      5663014;
  static const int transactionAddressesCannotSignTransaction = 5663015;
  static const int transactionCannotEncodeWithEmptySignatures = 5663016;
  static const int transactionMessageSignaturesMismatch = 5663017;
  static const int transactionFailedToEstimateComputeLimit = 5663018;
  static const int transactionFailedWhenSimulatingToEstimateComputeLimit =
      5663019;
  static const int transactionExceedsSizeLimit = 5663020;
  static const int transactionVersionNumberNotSupported = 5663021;
  static const int transactionNonceAccountCannotBeInLookupTable = 5663022;

  // ---------------------------------------------------------------------------
  // Transaction Errors (7050000 - 7050999)
  // ---------------------------------------------------------------------------

  static const int transactionErrorUnknown = 7050000;
  static const int transactionErrorAccountInUse = 7050001;
  static const int transactionErrorAccountLoadedTwice = 7050002;
  static const int transactionErrorAccountNotFound = 7050003;
  static const int transactionErrorProgramAccountNotFound = 7050004;
  static const int transactionErrorInsufficientFundsForFee = 7050005;
  static const int transactionErrorInvalidAccountForFee = 7050006;
  static const int transactionErrorAlreadyProcessed = 7050007;
  static const int transactionErrorBlockhashNotFound = 7050008;
  static const int transactionErrorCallChainTooDeep = 7050009;
  static const int transactionErrorMissingSignatureForFee = 7050010;
  static const int transactionErrorInvalidAccountIndex = 7050011;
  static const int transactionErrorSignatureFailure = 7050012;
  static const int transactionErrorInvalidProgramForExecution = 7050013;
  static const int transactionErrorSanitizeFailure = 7050014;
  static const int transactionErrorClusterMaintenance = 7050015;
  static const int transactionErrorAccountBorrowOutstanding = 7050016;
  static const int transactionErrorWouldExceedMaxBlockCostLimit = 7050017;
  static const int transactionErrorUnsupportedVersion = 7050018;
  static const int transactionErrorInvalidWritableAccount = 7050019;
  static const int transactionErrorWouldExceedMaxAccountCostLimit = 7050020;
  static const int transactionErrorWouldExceedAccountDataBlockLimit = 7050021;
  static const int transactionErrorTooManyAccountLocks = 7050022;
  static const int transactionErrorAddressLookupTableNotFound = 7050023;
  static const int transactionErrorInvalidAddressLookupTableOwner = 7050024;
  static const int transactionErrorInvalidAddressLookupTableData = 7050025;
  static const int transactionErrorInvalidAddressLookupTableIndex = 7050026;
  static const int transactionErrorInvalidRentPayingAccount = 7050027;
  static const int transactionErrorWouldExceedMaxVoteCostLimit = 7050028;
  static const int transactionErrorWouldExceedAccountDataTotalLimit = 7050029;
  static const int transactionErrorDuplicateInstruction = 7050030;
  static const int transactionErrorInsufficientFundsForRent = 7050031;
  static const int transactionErrorMaxLoadedAccountsDataSizeExceeded = 7050032;
  static const int transactionErrorInvalidLoadedAccountsDataSizeLimit = 7050033;
  static const int transactionErrorResanitizationNeeded = 7050034;
  static const int transactionErrorProgramExecutionTemporarilyRestricted =
      7050035;
  static const int transactionErrorUnbalancedTransaction = 7050036;

  // ---------------------------------------------------------------------------
  // Instruction Plans (7618000 - 7618999)
  // ---------------------------------------------------------------------------

  static const int instructionPlansMessageCannotAccommodatePlan = 7618000;
  static const int instructionPlansMessagePackerAlreadyComplete = 7618001;
  static const int instructionPlansEmptyInstructionPlan = 7618002;
  static const int instructionPlansFailedToExecuteTransactionPlan = 7618003;
  static const int instructionPlansNonDivisibleTransactionPlansNotSupported =
      7618004;
  static const int instructionPlansFailedSingleTransactionPlanResultNotFound =
      7618005;
  static const int instructionPlansUnexpectedInstructionPlan = 7618006;
  static const int instructionPlansUnexpectedTransactionPlan = 7618007;
  static const int instructionPlansUnexpectedTransactionPlanResult = 7618008;
  static const int instructionPlansExpectedSuccessfulTransactionPlanResult =
      7618009;

  // ---------------------------------------------------------------------------
  // Codecs (8078000 - 8078999)
  // ---------------------------------------------------------------------------

  static const int codecsCannotDecodeEmptyByteArray = 8078000;
  static const int codecsInvalidByteLength = 8078001;
  static const int codecsExpectedFixedLength = 8078002;
  static const int codecsExpectedVariableLength = 8078003;
  static const int codecsEncoderDecoderSizeCompatibilityMismatch = 8078004;
  static const int codecsEncoderDecoderFixedSizeMismatch = 8078005;
  static const int codecsEncoderDecoderMaxSizeMismatch = 8078006;
  static const int codecsInvalidNumberOfItems = 8078007;
  static const int codecsEnumDiscriminatorOutOfRange = 8078008;
  static const int codecsInvalidDiscriminatedUnionVariant = 8078009;
  static const int codecsInvalidEnumVariant = 8078010;
  static const int codecsNumberOutOfRange = 8078011;
  static const int codecsInvalidStringForBase = 8078012;
  static const int codecsExpectedPositiveByteLength = 8078013;
  static const int codecsOffsetOutOfRange = 8078014;
  static const int codecsInvalidLiteralUnionVariant = 8078015;
  static const int codecsLiteralUnionDiscriminatorOutOfRange = 8078016;
  static const int codecsUnionVariantOutOfRange = 8078017;
  static const int codecsInvalidConstant = 8078018;
  static const int codecsExpectedZeroValueToMatchItemFixedSize = 8078019;
  static const int codecsEncodedBytesMustNotIncludeSentinel = 8078020;
  static const int codecsSentinelMissingInDecodedBytes = 8078021;
  static const int codecsCannotUseLexicalValuesAsEnumDiscriminators = 8078022;
  static const int codecsExpectedDecoderToConsumeEntireByteArray = 8078023;

  // ---------------------------------------------------------------------------
  // RPC (8100000 - 8100999)
  // ---------------------------------------------------------------------------

  static const int rpcIntegerOverflow = 8100000;
  static const int rpcTransportHttpHeaderForbidden = 8100001;
  static const int rpcTransportHttpError = 8100002;
  static const int rpcApiPlanMissingForRpcMethod = 8100003;

  // ---------------------------------------------------------------------------
  // RPC Subscriptions (8190000 - 8190999)
  // ---------------------------------------------------------------------------

  static const int rpcSubscriptionsCannotCreateSubscriptionPlan = 8190000;
  static const int rpcSubscriptionsExpectedServerSubscriptionId = 8190001;
  static const int rpcSubscriptionsChannelClosedBeforeMessageBuffered = 8190002;
  static const int rpcSubscriptionsChannelConnectionClosed = 8190003;
  static const int rpcSubscriptionsChannelFailedToConnect = 8190004;

  // ---------------------------------------------------------------------------
  // Program Clients (8500000 - 8500999)
  // ---------------------------------------------------------------------------

  static const int programClientsInsufficientAccountMetas = 8500000;
  static const int programClientsUnrecognizedInstructionType = 8500001;
  static const int programClientsFailedToIdentifyInstruction = 8500002;
  static const int programClientsUnexpectedResolvedInstructionInputType =
      8500003;
  static const int programClientsResolvedInstructionInputMustBeNonNull =
      8500004;
  static const int programClientsUnrecognizedAccountType = 8500005;
  static const int programClientsFailedToIdentifyAccount = 8500006;

  // ---------------------------------------------------------------------------
  // Helius (8600000 - 8600099)
  // ---------------------------------------------------------------------------

  static const int heliusRpcError = 8600000;
  static const int heliusRestError = 8600001;
  static const int heliusApiKeyRequired = 8600002;
  static const int heliusWebSocketError = 8600003;
  static const int heliusTransactionConfirmationTimeout = 8600004;
  static const int heliusTransactionSimulationFailed = 8600005;

  // ---------------------------------------------------------------------------
  // Invariant Violations (9900000 - 9900999)
  // ---------------------------------------------------------------------------

  static const int invariantViolationSubscriptionIteratorStateMissing = 9900000;
  static const int
  invariantViolationSubscriptionIteratorMustNotPollBeforeResolvingExistingMessagePromise =
      9900001;
  static const int invariantViolationCachedAbortableIterableCacheEntryMissing =
      9900002;
  static const int invariantViolationSwitchMustBeExhaustive = 9900003;
  static const int invariantViolationDataPublisherChannelUnimplemented =
      9900004;
  static const int invariantViolationInvalidInstructionPlanKind = 9900005;
  static const int invariantViolationInvalidTransactionPlanKind = 9900006;
}
