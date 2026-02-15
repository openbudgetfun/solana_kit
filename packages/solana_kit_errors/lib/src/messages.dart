import 'package:solana_kit_errors/src/codes.dart';

/// Maps every [SolanaErrorCode] to its human-readable message template string.
///
/// Template strings may contain `$`-prefixed placeholders (e.g. `$address`,
/// `$actualLength`) that should be interpolated with context-specific values
/// when constructing the final error message.
const Map<int, String> solanaErrorMessages = {
  SolanaErrorCode.accountsAccountNotFound:
      r'Account not found at address: $address',
  SolanaErrorCode.accountsExpectedAllAccountsToBeDecoded:
      r'Not all accounts were decoded. Encoded accounts found at addresses: $addresses.',
  SolanaErrorCode.accountsExpectedDecodedAccount:
      r'Expected decoded account at address: $address',
  SolanaErrorCode.accountsFailedToDecodeAccount:
      r'Failed to decode account data at address: $address',
  SolanaErrorCode.accountsOneOrMoreAccountsNotFound:
      r'Accounts not found at addresses: $addresses',
  SolanaErrorCode.addressesFailedToFindViablePdaBumpSeed:
      'Unable to find a viable program address bump seed.',
  SolanaErrorCode.addressesInvalidBase58EncodedAddress:
      r'$putativeAddress is not a base58-encoded address.',
  SolanaErrorCode.addressesInvalidByteLength:
      r'Expected base58 encoded address to decode to a byte array of length 32. Actual length: $actualLength.',
  SolanaErrorCode.addressesInvalidEd25519PublicKey:
      'The CryptoKey must be an Ed25519 public key.',
  SolanaErrorCode.addressesInvalidOffCurveAddress:
      r'$putativeOffCurveAddress is not a base58-encoded off-curve address.',
  SolanaErrorCode.addressesInvalidSeedsPointOnCurve:
      'Invalid seeds; point must fall off the Ed25519 curve.',
  SolanaErrorCode.addressesMalformedPda:
      'Expected given program derived address to have the following format: [Address, ProgramDerivedAddressBump].',
  SolanaErrorCode.addressesMaxNumberOfPdaSeedsExceeded:
      r'A maximum of $maxSeeds seeds, including the bump seed, may be supplied when creating an address. Received: $actual.',
  SolanaErrorCode.addressesMaxPdaSeedLengthExceeded:
      r'The seed at index $index with length $actual exceeds the maximum length of $maxSeedLength bytes.',
  SolanaErrorCode.addressesPdaBumpSeedOutOfRange:
      r'Expected program derived address bump to be in the range [0, 255], got: $bump.',
  SolanaErrorCode.addressesPdaEndsWithPdaMarker:
      'Program address cannot end with PDA marker.',
  SolanaErrorCode.addressesStringLengthOutOfRange:
      r'Expected base58-encoded address string of length in the range [32, 44]. Actual length: $actualLength.',
  SolanaErrorCode.blockhashStringLengthOutOfRange:
      r'Expected base58-encoded blockhash string of length in the range [32, 44]. Actual length: $actualLength.',
  SolanaErrorCode.blockHeightExceeded:
      'The network has progressed past the last block for which this transaction could have been committed.',
  SolanaErrorCode.codecsCannotDecodeEmptyByteArray:
      r'Codec [$codecDescription] cannot decode empty byte arrays.',
  SolanaErrorCode.codecsCannotUseLexicalValuesAsEnumDiscriminators:
      r'Enum codec cannot use lexical values [$stringValues] as discriminators. Either remove all lexical values or set useValuesAsDiscriminators to false.',
  SolanaErrorCode.codecsEncodedBytesMustNotIncludeSentinel:
      r'Sentinel [$hexSentinel] must not be present in encoded bytes [$hexEncodedBytes].',
  SolanaErrorCode.codecsEncoderDecoderFixedSizeMismatch:
      r'Encoder and decoder must have the same fixed size, got [$encoderFixedSize] and [$decoderFixedSize].',
  SolanaErrorCode.codecsEncoderDecoderMaxSizeMismatch:
      r'Encoder and decoder must have the same max size, got [$encoderMaxSize] and [$decoderMaxSize].',
  SolanaErrorCode.codecsEncoderDecoderSizeCompatibilityMismatch:
      'Encoder and decoder must either both be fixed-size or variable-size.',
  SolanaErrorCode.codecsEnumDiscriminatorOutOfRange:
      r'Enum discriminator out of range. Expected a number in [$formattedValidDiscriminators], got $discriminator.',
  SolanaErrorCode.codecsExpectedDecoderToConsumeEntireByteArray:
      r'This decoder expected a byte array of exactly $expectedLength bytes, but $numExcessBytes unexpected excess bytes remained after decoding. Are you sure that you have chosen the correct decoder for this data?',
  SolanaErrorCode.codecsExpectedFixedLength:
      'Expected a fixed-size codec, got a variable-size one.',
  SolanaErrorCode.codecsExpectedPositiveByteLength:
      r'Codec [$codecDescription] expected a positive byte length, got $bytesLength.',
  SolanaErrorCode.codecsExpectedVariableLength:
      'Expected a variable-size codec, got a fixed-size one.',
  SolanaErrorCode.codecsExpectedZeroValueToMatchItemFixedSize:
      r'Codec [$codecDescription] expected zero-value [$hexZeroValue] to have the same size as the provided fixed-size item [$expectedSize bytes].',
  SolanaErrorCode.codecsInvalidByteLength:
      r'Codec [$codecDescription] expected $expected bytes, got $bytesLength.',
  SolanaErrorCode.codecsInvalidConstant:
      r'Expected byte array constant [$hexConstant] to be present in data [$hexData] at offset [$offset].',
  SolanaErrorCode.codecsInvalidDiscriminatedUnionVariant:
      r'Invalid discriminated union variant. Expected one of [$variants], got $value.',
  SolanaErrorCode.codecsInvalidEnumVariant:
      r'Invalid enum variant. Expected one of [$stringValues] or a number in [$formattedNumericalValues], got $variant.',
  SolanaErrorCode.codecsInvalidLiteralUnionVariant:
      r'Invalid literal union variant. Expected one of [$variants], got $value.',
  SolanaErrorCode.codecsInvalidNumberOfItems:
      r'Expected [$codecDescription] to have $expected items, got $actual.',
  SolanaErrorCode.codecsInvalidStringForBase:
      r'Invalid value $value for base $base with alphabet $alphabet.',
  SolanaErrorCode.codecsLiteralUnionDiscriminatorOutOfRange:
      r'Literal union discriminator out of range. Expected a number between $minRange and $maxRange, got $discriminator.',
  SolanaErrorCode.codecsNumberOutOfRange:
      r'Codec [$codecDescription] expected number to be in the range [$min, $max], got $value.',
  SolanaErrorCode.codecsOffsetOutOfRange:
      r'Codec [$codecDescription] expected offset to be in the range [0, $bytesLength], got $offset.',
  SolanaErrorCode.codecsSentinelMissingInDecodedBytes:
      r'Expected sentinel [$hexSentinel] to be present in decoded bytes [$hexDecodedBytes].',
  SolanaErrorCode.codecsUnionVariantOutOfRange:
      r'Union variant out of range. Expected an index between $minRange and $maxRange, got $variant.',
  SolanaErrorCode.cryptoRandomValuesFunctionUnimplemented:
      'No random values implementation could be found.',
  SolanaErrorCode.instructionErrorAccountAlreadyInitialized:
      'instruction requires an uninitialized account',
  SolanaErrorCode.instructionErrorAccountBorrowFailed:
      'instruction tries to borrow reference for an account which is already borrowed',
  SolanaErrorCode.instructionErrorAccountBorrowOutstanding:
      'instruction left account with an outstanding borrowed reference',
  SolanaErrorCode.instructionErrorAccountDataSizeChanged:
      "program other than the account's owner changed the size of the account data",
  SolanaErrorCode.instructionErrorAccountDataTooSmall:
      'account data too small for instruction',
  SolanaErrorCode.instructionErrorAccountNotExecutable:
      'instruction expected an executable account',
  SolanaErrorCode.instructionErrorAccountNotRentExempt:
      'An account does not have enough lamports to be rent-exempt',
  SolanaErrorCode.instructionErrorArithmeticOverflow:
      'Program arithmetic overflowed',
  SolanaErrorCode.instructionErrorBorshIoError:
      r'Failed to serialize or deserialize account data: $encodedData',
  SolanaErrorCode.instructionErrorBuiltinProgramsMustConsumeComputeUnits:
      'Builtin programs must consume compute units',
  SolanaErrorCode.instructionErrorCallDepth:
      'Cross-program invocation call depth too deep',
  SolanaErrorCode.instructionErrorComputationalBudgetExceeded:
      'Computational budget exceeded',
  SolanaErrorCode.instructionErrorCustom: r'custom program error: #$code',
  SolanaErrorCode.instructionErrorDuplicateAccountIndex:
      'instruction contains duplicate accounts',
  SolanaErrorCode.instructionErrorDuplicateAccountOutOfSync:
      'instruction modifications of multiply-passed account differ',
  SolanaErrorCode.instructionErrorExecutableAccountNotRentExempt:
      'executable accounts must be rent exempt',
  SolanaErrorCode.instructionErrorExecutableDataModified:
      'instruction changed executable accounts data',
  SolanaErrorCode.instructionErrorExecutableLamportChange:
      'instruction changed the balance of an executable account',
  SolanaErrorCode.instructionErrorExecutableModified:
      'instruction changed executable bit of an account',
  SolanaErrorCode.instructionErrorExternalAccountDataModified:
      'instruction modified data of an account it does not own',
  SolanaErrorCode.instructionErrorExternalAccountLamportSpend:
      'instruction spent from the balance of an account it does not own',
  SolanaErrorCode.instructionErrorGenericError: 'generic instruction error',
  SolanaErrorCode.instructionErrorIllegalOwner: 'Provided owner is not allowed',
  SolanaErrorCode.instructionErrorImmutable: 'Account is immutable',
  SolanaErrorCode.instructionErrorIncorrectAuthority:
      'Incorrect authority provided',
  SolanaErrorCode.instructionErrorIncorrectProgramId:
      'incorrect program id for instruction',
  SolanaErrorCode.instructionErrorInsufficientFunds:
      'insufficient funds for instruction',
  SolanaErrorCode.instructionErrorInvalidAccountData:
      'invalid account data for instruction',
  SolanaErrorCode.instructionErrorInvalidAccountOwner: 'Invalid account owner',
  SolanaErrorCode.instructionErrorInvalidArgument: 'invalid program argument',
  SolanaErrorCode.instructionErrorInvalidError:
      'program returned invalid error code',
  SolanaErrorCode.instructionErrorInvalidInstructionData:
      'invalid instruction data',
  SolanaErrorCode.instructionErrorInvalidRealloc:
      'Failed to reallocate account data',
  SolanaErrorCode.instructionErrorInvalidSeeds:
      'Provided seeds do not result in a valid address',
  SolanaErrorCode.instructionErrorMaxAccountsDataAllocationsExceeded:
      'Accounts data allocations exceeded the maximum allowed per transaction',
  SolanaErrorCode.instructionErrorMaxAccountsExceeded: 'Max accounts exceeded',
  SolanaErrorCode.instructionErrorMaxInstructionTraceLengthExceeded:
      'Max instruction trace length exceeded',
  SolanaErrorCode.instructionErrorMaxSeedLengthExceeded:
      'Length of the seed is too long for address generation',
  SolanaErrorCode.instructionErrorMissingAccount:
      'An account required by the instruction is missing',
  SolanaErrorCode.instructionErrorMissingRequiredSignature:
      'missing required signature for instruction',
  SolanaErrorCode.instructionErrorModifiedProgramId:
      'instruction illegally modified the program id of an account',
  SolanaErrorCode.instructionErrorNotEnoughAccountKeys:
      'insufficient account keys for instruction',
  SolanaErrorCode.instructionErrorPrivilegeEscalation:
      'Cross-program invocation with unauthorized signer or writable account',
  SolanaErrorCode.instructionErrorProgramEnvironmentSetupFailure:
      'Failed to create program execution environment',
  SolanaErrorCode.instructionErrorProgramFailedToCompile:
      'Program failed to compile',
  SolanaErrorCode.instructionErrorProgramFailedToComplete:
      'Program failed to complete',
  SolanaErrorCode.instructionErrorReadonlyDataModified:
      'instruction modified data of a read-only account',
  SolanaErrorCode.instructionErrorReadonlyLamportChange:
      'instruction changed the balance of a read-only account',
  SolanaErrorCode.instructionErrorReentrancyNotAllowed:
      'Cross-program invocation reentrancy not allowed for this instruction',
  SolanaErrorCode.instructionErrorRentEpochModified:
      'instruction modified rent epoch of an account',
  SolanaErrorCode.instructionErrorUnbalancedInstruction:
      'sum of account balances before and after instruction do not match',
  SolanaErrorCode.instructionErrorUninitializedAccount:
      'instruction requires an initialized account',
  SolanaErrorCode.instructionErrorUnknown: '',
  SolanaErrorCode.instructionErrorUnsupportedProgramId:
      'Unsupported program id',
  SolanaErrorCode.instructionErrorUnsupportedSysvar: 'Unsupported sysvar',
  SolanaErrorCode.instructionExpectedToHaveAccounts:
      'The instruction does not have any accounts.',
  SolanaErrorCode.instructionExpectedToHaveData:
      'The instruction does not have any data.',
  SolanaErrorCode.instructionProgramIdMismatch:
      r'Expected instruction to have program address $expectedProgramAddress, got $actualProgramAddress.',
  SolanaErrorCode.instructionPlansEmptyInstructionPlan:
      'The provided instruction plan is empty.',
  SolanaErrorCode.instructionPlansExpectedSuccessfulTransactionPlanResult:
      'Expected a successful transaction plan result. I.e. there is at least one failed or cancelled transaction in the plan.',
  SolanaErrorCode.instructionPlansFailedSingleTransactionPlanResultNotFound:
      'No failed transaction plan result was found in the provided transaction plan result.',
  SolanaErrorCode.instructionPlansFailedToExecuteTransactionPlan:
      'The provided transaction plan failed to execute. See the transactionPlanResult attribute for more details.',
  SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan:
      r'The provided message has insufficient capacity to accommodate the next instruction(s) in this plan. Expected at least $numBytesRequired free byte(s), got $numFreeBytes byte(s).',
  SolanaErrorCode.instructionPlansMessagePackerAlreadyComplete:
      'No more instructions to pack; the message packer has completed the instruction plan.',
  SolanaErrorCode.instructionPlansNonDivisibleTransactionPlansNotSupported:
      'This transaction plan executor does not support non-divisible sequential plans.',
  SolanaErrorCode.instructionPlansUnexpectedInstructionPlan:
      r'Unexpected instruction plan. Expected $expectedKind plan, got $actualKind plan.',
  SolanaErrorCode.instructionPlansUnexpectedTransactionPlan:
      r'Unexpected transaction plan. Expected $expectedKind plan, got $actualKind plan.',
  SolanaErrorCode.instructionPlansUnexpectedTransactionPlanResult:
      r'Unexpected transaction plan result. Expected $expectedKind plan, got $actualKind plan.',
  SolanaErrorCode.invalidBlockhashByteLength:
      r'Expected base58 encoded blockhash to decode to a byte array of length 32. Actual length: $actualLength.',
  SolanaErrorCode.invalidNonce:
      r'The nonce $expectedNonceValue is no longer valid. It has advanced to $actualNonceValue',
  SolanaErrorCode.invariantViolationCachedAbortableIterableCacheEntryMissing:
      r'Invariant violation: Found no abortable iterable cache entry for key $cacheKey. Please file an issue at https://sola.na/web3invariant',
  SolanaErrorCode.invariantViolationDataPublisherChannelUnimplemented:
      r'Invariant violation: This data publisher does not publish to the channel named $channelName. Supported channels include $supportedChannelNames.',
  SolanaErrorCode.invariantViolationInvalidInstructionPlanKind:
      r'Invalid instruction plan kind: $kind.',
  SolanaErrorCode.invariantViolationInvalidTransactionPlanKind:
      r'Invalid transaction plan kind: $kind.',
  SolanaErrorCode
          .invariantViolationSubscriptionIteratorMustNotPollBeforeResolvingExistingMessagePromise:
      'Invariant violation: WebSocket message iterator state is corrupt; iterated without first resolving existing message promise. Please file an issue at https://sola.na/web3invariant',
  SolanaErrorCode.invariantViolationSubscriptionIteratorStateMissing:
      'Invariant violation: WebSocket message iterator is missing state storage. Please file an issue at https://sola.na/web3invariant',
  SolanaErrorCode.invariantViolationSwitchMustBeExhaustive:
      r'Invariant violation: Switch statement non-exhaustive. Received unexpected value $unexpectedValue. Please file an issue at https://sola.na/web3invariant',
  SolanaErrorCode.jsonRpcInternalError:
      r'JSON-RPC error: Internal JSON-RPC error ($__serverMessage)',
  SolanaErrorCode.jsonRpcInvalidParams:
      r'JSON-RPC error: Invalid method parameter(s) ($__serverMessage)',
  SolanaErrorCode.jsonRpcInvalidRequest:
      r'JSON-RPC error: The JSON sent is not a valid Request object ($__serverMessage)',
  SolanaErrorCode.jsonRpcMethodNotFound:
      r'JSON-RPC error: The method does not exist / is not available ($__serverMessage)',
  SolanaErrorCode.jsonRpcParseError:
      r'JSON-RPC error: An error occurred on the server while parsing the JSON text ($__serverMessage)',
  SolanaErrorCode.jsonRpcScanError: r'$__serverMessage',
  SolanaErrorCode.jsonRpcServerErrorBlockCleanedUp: r'$__serverMessage',
  SolanaErrorCode.jsonRpcServerErrorBlockNotAvailable: r'$__serverMessage',
  SolanaErrorCode.jsonRpcServerErrorBlockStatusNotAvailableYet:
      r'$__serverMessage',
  SolanaErrorCode.jsonRpcServerErrorEpochRewardsPeriodActive:
      r'Epoch rewards period still active at slot $slot',
  SolanaErrorCode.jsonRpcServerErrorKeyExcludedFromSecondaryIndex:
      r'$__serverMessage',
  SolanaErrorCode.jsonRpcServerErrorLongTermStorageSlotSkipped:
      r'$__serverMessage',
  SolanaErrorCode.jsonRpcServerErrorLongTermStorageUnreachable:
      'Failed to query long-term storage; please try again',
  SolanaErrorCode.jsonRpcServerErrorMinContextSlotNotReached:
      'Minimum context slot has not been reached',
  SolanaErrorCode.jsonRpcServerErrorNodeUnhealthy:
      r'Node is unhealthy; behind by $numSlotsBehind slots',
  SolanaErrorCode.jsonRpcServerErrorNoSnapshot: 'No snapshot',
  SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure:
      'Transaction simulation failed',
  SolanaErrorCode.jsonRpcServerErrorSlotNotEpochBoundary:
      r'Rewards cannot be found because slot $slot is not the epoch boundary.',
  SolanaErrorCode.jsonRpcServerErrorSlotSkipped: r'$__serverMessage',
  SolanaErrorCode.jsonRpcServerErrorTransactionHistoryNotAvailable:
      'Transaction history is not available from this node',
  SolanaErrorCode.jsonRpcServerErrorTransactionPrecompileVerificationFailure:
      r'$__serverMessage',
  SolanaErrorCode.jsonRpcServerErrorTransactionSignatureLenMismatch:
      'Transaction signature length mismatch',
  SolanaErrorCode.jsonRpcServerErrorTransactionSignatureVerificationFailure:
      'Transaction signature verification failure',
  SolanaErrorCode.jsonRpcServerErrorUnsupportedTransactionVersion:
      r'$__serverMessage',
  SolanaErrorCode.keysInvalidKeyPairByteLength:
      r'Key pair bytes must be of length 64, got $byteLength.',
  SolanaErrorCode.keysInvalidPrivateKeyByteLength:
      r'Expected private key bytes with length 32. Actual length: $actualLength.',
  SolanaErrorCode.keysInvalidSignatureByteLength:
      r'Expected base58-encoded signature to decode to a byte array of length 64. Actual length: $actualLength.',
  SolanaErrorCode.keysPublicKeyMustMatchPrivateKey:
      'The provided private key does not match the provided public key.',
  SolanaErrorCode.keysSignatureStringLengthOutOfRange:
      r'Expected base58-encoded signature string of length in the range [64, 88]. Actual length: $actualLength.',
  SolanaErrorCode.lamportsOutOfRange:
      'Lamports value must be in the range [0, 2e64-1]',
  SolanaErrorCode.malformedBigintString: r'$value cannot be parsed as a BigInt',
  SolanaErrorCode.malformedJsonRpcError: r'$message',
  SolanaErrorCode.malformedNumberString: r'$value cannot be parsed as a Number',
  SolanaErrorCode.nonceAccountNotFound:
      r'No nonce account could be found at address $nonceAccountAddress',
  SolanaErrorCode.offchainMessageAddressesCannotSignOffchainMessage:
      'Attempted to sign an offchain message with an address that is not a signer for it',
  SolanaErrorCode.offchainMessageApplicationDomainStringLengthOutOfRange:
      r'Expected base58-encoded application domain string of length in the range [32, 44]. Actual length: $actualLength.',
  SolanaErrorCode.offchainMessageEnvelopeSignersMismatch:
      'The signer addresses in this offchain message envelope do not match the list of required signers in the message preamble.',
  SolanaErrorCode.offchainMessageInvalidApplicationDomainByteLength:
      r'Expected base58 encoded application domain to decode to a byte array of length 32. Actual length: $actualLength.',
  SolanaErrorCode.offchainMessageMaximumLengthExceeded:
      r'The message body provided has a byte-length of $actualBytes. The maximum allowable byte-length is $maxBytes',
  SolanaErrorCode.offchainMessageMessageFormatMismatch:
      r'Expected message format $expectedMessageFormat, got $actualMessageFormat',
  SolanaErrorCode.offchainMessageMessageLengthMismatch:
      r'The message length specified in the message preamble is $specifiedLength bytes. The actual length of the message is $actualLength bytes.',
  SolanaErrorCode.offchainMessageMessageMustBeNonEmpty:
      'Offchain message content must be non-empty',
  SolanaErrorCode.offchainMessageNumEnvelopeSignaturesCannotBeZero:
      'Offchain message envelope must reserve space for at least one signature',
  SolanaErrorCode.offchainMessageNumRequiredSignersCannotBeZero:
      'Offchain message must specify the address of at least one required signer',
  SolanaErrorCode.offchainMessageNumSignaturesMismatch:
      r'The offchain message preamble specifies $numRequiredSignatures required signature(s), got $signaturesLength.',
  SolanaErrorCode.offchainMessageRestrictedAsciiBodyCharacterOutOfRange:
      'The message body provided contains characters whose codes fall outside the allowed range.',
  SolanaErrorCode.offchainMessageSignatoriesMustBeSorted:
      'The signatories of this offchain message must be listed in lexicographical order',
  SolanaErrorCode.offchainMessageSignatoriesMustBeUnique:
      'An address must be listed no more than once among the signatories of an offchain message',
  SolanaErrorCode.offchainMessageSignatureVerificationFailure:
      'Offchain message signature verification failed.',
  SolanaErrorCode.offchainMessageSignaturesMissing:
      r'Offchain message is missing signatures for addresses: $addresses.',
  SolanaErrorCode.offchainMessageUnexpectedVersion:
      r'Expected offchain message version $expectedVersion. Got $actualVersion.',
  SolanaErrorCode.offchainMessageVersionNumberNotSupported:
      r'This version of Kit does not support decoding offchain messages with version $unsupportedVersion.',
  SolanaErrorCode.programClientsFailedToIdentifyAccount:
      r'The provided account could not be identified as an account from the $programName program.',
  SolanaErrorCode.programClientsFailedToIdentifyInstruction:
      r'The provided instruction could not be identified as an instruction from the $programName program.',
  SolanaErrorCode.programClientsInsufficientAccountMetas:
      r'The provided instruction is missing some accounts. Expected at least $expectedAccountMetas account(s), got $actualAccountMetas.',
  SolanaErrorCode.programClientsResolvedInstructionInputMustBeNonNull:
      r"Expected resolved instruction input '$inputName' to be non-null.",
  SolanaErrorCode.programClientsUnexpectedResolvedInstructionInputType:
      r"Expected resolved instruction input '$inputName' to be of type $expectedType.",
  SolanaErrorCode.programClientsUnrecognizedAccountType:
      r"Unrecognized account type '$accountType' for the $programName program.",
  SolanaErrorCode.programClientsUnrecognizedInstructionType:
      r"Unrecognized instruction type '$instructionType' for the $programName program.",
  SolanaErrorCode.rpcApiPlanMissingForRpcMethod:
      r'Could not find an API plan for RPC method: $method',
  SolanaErrorCode.rpcIntegerOverflow:
      r'The $argumentLabel argument to the $methodName RPC method was $value. This number is unsafe because it exceeds the maximum safe integer.',
  SolanaErrorCode.rpcSubscriptionsCannotCreateSubscriptionPlan:
      r"The notification name must end in 'Notifications' and the API must supply a subscription plan creator function for the notification '$notificationName'.",
  SolanaErrorCode.rpcSubscriptionsChannelClosedBeforeMessageBuffered:
      'WebSocket was closed before payload could be added to the send buffer',
  SolanaErrorCode.rpcSubscriptionsChannelConnectionClosed:
      'WebSocket connection closed',
  SolanaErrorCode.rpcSubscriptionsChannelFailedToConnect:
      'WebSocket failed to connect',
  SolanaErrorCode.rpcSubscriptionsExpectedServerSubscriptionId:
      'Failed to obtain a subscription id from the server',
  SolanaErrorCode.rpcTransportHttpError: r'HTTP error ($statusCode): $message',
  SolanaErrorCode.rpcTransportHttpHeaderForbidden:
      r'HTTP header(s) forbidden: $headers.',
  SolanaErrorCode.signerAddressCannotHaveMultipleSigners:
      r'Multiple distinct signers were identified for address $address. Please ensure that you are using the same signer instance for each address.',
  SolanaErrorCode.signerExpectedKeyPairSigner:
      'The provided value does not implement the KeyPairSigner interface',
  SolanaErrorCode.signerExpectedMessageModifyingSigner:
      'The provided value does not implement the MessageModifyingSigner interface',
  SolanaErrorCode.signerExpectedMessagePartialSigner:
      'The provided value does not implement the MessagePartialSigner interface',
  SolanaErrorCode.signerExpectedMessageSigner:
      'The provided value does not implement any of the MessageSigner interfaces',
  SolanaErrorCode.signerExpectedTransactionModifyingSigner:
      'The provided value does not implement the TransactionModifyingSigner interface',
  SolanaErrorCode.signerExpectedTransactionPartialSigner:
      'The provided value does not implement the TransactionPartialSigner interface',
  SolanaErrorCode.signerExpectedTransactionSendingSigner:
      'The provided value does not implement the TransactionSendingSigner interface',
  SolanaErrorCode.signerExpectedTransactionSigner:
      'The provided value does not implement any of the TransactionSigner interfaces',
  SolanaErrorCode.signerTransactionCannotHaveMultipleSendingSigners:
      'More than one TransactionSendingSigner was identified.',
  SolanaErrorCode.signerTransactionSendingSignerMissing:
      'No TransactionSendingSigner was identified.',
  SolanaErrorCode.signerWalletMultisignUnimplemented:
      'Wallet account signers do not support signing multiple messages/transactions in a single operation',
  SolanaErrorCode.subtleCryptoCannotExportNonExtractableKey:
      'Cannot export a non-extractable key.',
  SolanaErrorCode.subtleCryptoDigestUnimplemented:
      'No digest implementation could be found.',
  SolanaErrorCode.subtleCryptoDisallowedInInsecureContext:
      'Cryptographic operations are only allowed in secure contexts.',
  SolanaErrorCode.subtleCryptoEd25519AlgorithmUnimplemented:
      'This runtime does not support the generation of Ed25519 key pairs.',
  SolanaErrorCode.subtleCryptoExportFunctionUnimplemented:
      'No signature verification implementation could be found.',
  SolanaErrorCode.subtleCryptoGenerateFunctionUnimplemented:
      'No key generation implementation could be found.',
  SolanaErrorCode.subtleCryptoSignFunctionUnimplemented:
      'No signing implementation could be found.',
  SolanaErrorCode.subtleCryptoVerifyFunctionUnimplemented:
      'No key export implementation could be found.',
  SolanaErrorCode.timestampOutOfRange:
      r'Timestamp value must be in the range [-(2^63), (2^63) - 1]. $value given',
  SolanaErrorCode.transactionAddressesCannotSignTransaction:
      'Attempted to sign a transaction with an address that is not a signer for it',
  SolanaErrorCode.transactionAddressMissing:
      r'Transaction is missing an address at index: $index.',
  SolanaErrorCode.transactionCannotEncodeWithEmptySignatures:
      'Transaction has no expected signers therefore it cannot be encoded',
  SolanaErrorCode.transactionErrorAccountBorrowOutstanding:
      'Transaction processing left an account with an outstanding borrowed reference',
  SolanaErrorCode.transactionErrorAccountInUse: 'Account in use',
  SolanaErrorCode.transactionErrorAccountLoadedTwice: 'Account loaded twice',
  SolanaErrorCode.transactionErrorAccountNotFound:
      'Attempt to debit an account but found no record of a prior credit.',
  SolanaErrorCode.transactionErrorAddressLookupTableNotFound:
      "Transaction loads an address table account that doesn't exist",
  SolanaErrorCode.transactionErrorAlreadyProcessed:
      'This transaction has already been processed',
  SolanaErrorCode.transactionErrorBlockhashNotFound: 'Blockhash not found',
  SolanaErrorCode.transactionErrorCallChainTooDeep:
      'Loader call chain is too deep',
  SolanaErrorCode.transactionErrorClusterMaintenance:
      'Transactions are currently disabled due to cluster maintenance',
  SolanaErrorCode.transactionErrorDuplicateInstruction:
      r'Transaction contains a duplicate instruction ($index) that is not allowed',
  SolanaErrorCode.transactionErrorInsufficientFundsForFee:
      'Insufficient funds for fee',
  SolanaErrorCode.transactionErrorInsufficientFundsForRent:
      r'Transaction results in an account ($accountIndex) with insufficient funds for rent',
  SolanaErrorCode.transactionErrorInvalidAccountForFee:
      'This account may not be used to pay transaction fees',
  SolanaErrorCode.transactionErrorInvalidAccountIndex:
      'Transaction contains an invalid account reference',
  SolanaErrorCode.transactionErrorInvalidAddressLookupTableData:
      'Transaction loads an address table account with invalid data',
  SolanaErrorCode.transactionErrorInvalidAddressLookupTableIndex:
      'Transaction address table lookup uses an invalid index',
  SolanaErrorCode.transactionErrorInvalidAddressLookupTableOwner:
      'Transaction loads an address table account with an invalid owner',
  SolanaErrorCode.transactionErrorInvalidLoadedAccountsDataSizeLimit:
      'LoadedAccountsDataSizeLimit set for transaction must be greater than 0.',
  SolanaErrorCode.transactionErrorInvalidProgramForExecution:
      'This program may not be used for executing instructions',
  SolanaErrorCode.transactionErrorInvalidRentPayingAccount:
      'Transaction leaves an account with a lower balance than rent-exempt minimum',
  SolanaErrorCode.transactionErrorInvalidWritableAccount:
      'Transaction loads a writable account that cannot be written',
  SolanaErrorCode.transactionErrorMaxLoadedAccountsDataSizeExceeded:
      'Transaction exceeded max loaded accounts data size cap',
  SolanaErrorCode.transactionErrorMissingSignatureForFee:
      'Transaction requires a fee but has no signature present',
  SolanaErrorCode.transactionErrorProgramAccountNotFound:
      'Attempt to load a program that does not exist',
  SolanaErrorCode.transactionErrorProgramExecutionTemporarilyRestricted:
      r'Execution of the program referenced by account at index $accountIndex is temporarily restricted.',
  SolanaErrorCode.transactionErrorResanitizationNeeded: 'ResanitizationNeeded',
  SolanaErrorCode.transactionErrorSanitizeFailure:
      'Transaction failed to sanitize accounts offsets correctly',
  SolanaErrorCode.transactionErrorSignatureFailure:
      'Transaction did not pass signature verification',
  SolanaErrorCode.transactionErrorTooManyAccountLocks:
      'Transaction locked too many accounts',
  SolanaErrorCode.transactionErrorUnbalancedTransaction:
      'Sum of account balances before and after transaction do not match',
  SolanaErrorCode.transactionErrorUnknown:
      r'The transaction failed with the error $errorName',
  SolanaErrorCode.transactionErrorUnsupportedVersion:
      'Transaction version is unsupported',
  SolanaErrorCode.transactionErrorWouldExceedAccountDataBlockLimit:
      'Transaction would exceed account data limit within the block',
  SolanaErrorCode.transactionErrorWouldExceedAccountDataTotalLimit:
      'Transaction would exceed total account data limit',
  SolanaErrorCode.transactionErrorWouldExceedMaxAccountCostLimit:
      'Transaction would exceed max account limit within the block',
  SolanaErrorCode.transactionErrorWouldExceedMaxBlockCostLimit:
      'Transaction would exceed max Block Cost Limit',
  SolanaErrorCode.transactionErrorWouldExceedMaxVoteCostLimit:
      'Transaction would exceed max Vote Cost Limit',
  SolanaErrorCode.transactionExceedsSizeLimit:
      r'Transaction size $transactionSize exceeds limit of $transactionSizeLimit bytes',
  SolanaErrorCode.transactionExpectedBlockhashLifetime:
      'Transaction does not have a blockhash lifetime',
  SolanaErrorCode.transactionExpectedNonceLifetime:
      'Transaction is not a durable nonce transaction',
  SolanaErrorCode.transactionFailedToDecompileAddressLookupTableContentsMissing:
      r'Contents of these address lookup tables unknown: $lookupTableAddresses',
  SolanaErrorCode.transactionFailedToDecompileAddressLookupTableIndexOutOfRange:
      r'Lookup of address at index $highestRequestedIndex failed for lookup table $lookupTableAddress. Highest known index is $highestKnownIndex.',
  SolanaErrorCode.transactionFailedToDecompileFeePayerMissing:
      'No fee payer set in CompiledTransaction',
  SolanaErrorCode.transactionFailedToDecompileInstructionProgramAddressNotFound:
      r'Could not find program address at index $index',
  SolanaErrorCode.transactionFailedToEstimateComputeLimit:
      'Failed to estimate the compute unit consumption for this transaction message.',
  SolanaErrorCode.transactionFailedWhenSimulatingToEstimateComputeLimit:
      'Transaction failed when it was simulated in order to estimate the compute unit consumption.',
  SolanaErrorCode.transactionFeePayerMissing:
      'Transaction is missing a fee payer.',
  SolanaErrorCode.transactionFeePayerSignatureMissing:
      "Could not determine this transaction's signature. Make sure that the transaction has been signed by its fee payer.",
  SolanaErrorCode
          .transactionInvalidNonceTransactionFirstInstructionMustBeAdvanceNonce:
      'Transaction first instruction is not advance nonce account instruction.',
  SolanaErrorCode.transactionInvalidNonceTransactionInstructionsMissing:
      'Transaction with no instructions cannot be durable nonce transaction.',
  SolanaErrorCode.transactionInvokedProgramsCannotPayFees:
      r'This transaction includes an address ($programAddress) which is both invoked and set as the fee payer. Program addresses may not pay fees',
  SolanaErrorCode.transactionInvokedProgramsMustNotBeWritable:
      r'This transaction includes an address ($programAddress) which is both invoked and marked writable. Program addresses may not be writable',
  SolanaErrorCode.transactionMessageSignaturesMismatch:
      r'The transaction message expected the transaction to have $numRequiredSignatures signatures, got $signaturesLength.',
  SolanaErrorCode.transactionNonceAccountCannotBeInLookupTable:
      'The transaction has a durable nonce lifetime, but the nonce account address is in a lookup table.',
  SolanaErrorCode.transactionSignaturesMissing:
      r'Transaction is missing signatures for addresses: $addresses.',
  SolanaErrorCode.transactionVersionNumberNotSupported:
      r'This version of Kit does not support decoding transactions with version $unsupportedVersion.',
  SolanaErrorCode.transactionVersionNumberOutOfRange:
      r'Transaction version must be in the range [0, 127]. $actualVersion given',
};
