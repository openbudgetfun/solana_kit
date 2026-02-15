/// Represents an instruction-level error returned by the Solana runtime.
///
/// This is a sealed class hierarchy where most variants are simple string
/// labels, while [InstructionErrorCustom] carries a custom program error
/// code.
sealed class InstructionError {
  const InstructionError();

  /// The string label for this instruction error (e.g. 'GenericError').
  String get label;
}

/// A custom program error with a numeric code.
class InstructionErrorCustom extends InstructionError {
  const InstructionErrorCustom(this.code);

  /// The custom error code from the program.
  final int code;

  @override
  String get label => 'Custom';
}

/// A simple instruction error identified by its string label.
class InstructionErrorSimple extends InstructionError {
  const InstructionErrorSimple(this.label);

  @override
  final String label;
}

/// All known simple instruction error labels as constants.
abstract final class InstructionErrorLabel {
  static const String accountAlreadyInitialized = 'AccountAlreadyInitialized';
  static const String accountBorrowFailed = 'AccountBorrowFailed';
  static const String accountBorrowOutstanding = 'AccountBorrowOutstanding';
  static const String accountDataSizeChanged = 'AccountDataSizeChanged';
  static const String accountDataTooSmall = 'AccountDataTooSmall';
  static const String accountNotExecutable = 'AccountNotExecutable';
  static const String accountNotRentExempt = 'AccountNotRentExempt';
  static const String arithmeticOverflow = 'ArithmeticOverflow';
  static const String borshIoError = 'BorshIoError';
  static const String builtinProgramsMustConsumeComputeUnits =
      'BuiltinProgramsMustConsumeComputeUnits';
  static const String callDepth = 'CallDepth';
  static const String computationalBudgetExceeded =
      'ComputationalBudgetExceeded';
  static const String duplicateAccountIndex = 'DuplicateAccountIndex';
  static const String duplicateAccountOutOfSync = 'DuplicateAccountOutOfSync';
  static const String executableAccountNotRentExempt =
      'ExecutableAccountNotRentExempt';
  static const String executableDataModified = 'ExecutableDataModified';
  static const String executableLamportChange = 'ExecutableLamportChange';
  static const String executableModified = 'ExecutableModified';
  static const String externalAccountDataModified =
      'ExternalAccountDataModified';
  static const String externalAccountLamportSpend =
      'ExternalAccountLamportSpend';
  static const String genericError = 'GenericError';
  static const String illegalOwner = 'IllegalOwner';
  static const String immutable = 'Immutable';
  static const String incorrectAuthority = 'IncorrectAuthority';
  static const String incorrectProgramId = 'IncorrectProgramId';
  static const String insufficientFunds = 'InsufficientFunds';
  static const String invalidAccountData = 'InvalidAccountData';
  static const String invalidAccountOwner = 'InvalidAccountOwner';
  static const String invalidArgument = 'InvalidArgument';
  static const String invalidError = 'InvalidError';
  static const String invalidInstructionData = 'InvalidInstructionData';
  static const String invalidRealloc = 'InvalidRealloc';
  static const String invalidSeeds = 'InvalidSeeds';
  static const String maxAccountsDataAllocationsExceeded =
      'MaxAccountsDataAllocationsExceeded';
  static const String maxAccountsExceeded = 'MaxAccountsExceeded';
  static const String maxInstructionTraceLengthExceeded =
      'MaxInstructionTraceLengthExceeded';
  static const String maxSeedLengthExceeded = 'MaxSeedLengthExceeded';
  static const String missingAccount = 'MissingAccount';
  static const String missingRequiredSignature = 'MissingRequiredSignature';
  static const String modifiedProgramId = 'ModifiedProgramId';
  static const String notEnoughAccountKeys = 'NotEnoughAccountKeys';
  static const String privilegeEscalation = 'PrivilegeEscalation';
  static const String programEnvironmentSetupFailure =
      'ProgramEnvironmentSetupFailure';
  static const String programFailedToCompile = 'ProgramFailedToCompile';
  static const String programFailedToComplete = 'ProgramFailedToComplete';
  static const String readonlyDataModified = 'ReadonlyDataModified';
  static const String readonlyLamportChange = 'ReadonlyLamportChange';
  static const String reentrancyNotAllowed = 'ReentrancyNotAllowed';
  static const String rentEpochModified = 'RentEpochModified';
  static const String unbalancedInstruction = 'UnbalancedInstruction';
  static const String uninitializedAccount = 'UninitializedAccount';
  static const String unsupportedProgramId = 'UnsupportedProgramId';
  static const String unsupportedSysvar = 'UnsupportedSysvar';
}

/// Represents a transaction-level error returned by the Solana runtime.
///
/// This is a sealed class hierarchy where most variants are simple string
/// labels, while some carry additional structured data.
sealed class TransactionError {
  const TransactionError();

  /// The string label for this transaction error.
  String get label;
}

/// A simple transaction error identified by its string label.
class TransactionErrorSimple extends TransactionError {
  const TransactionErrorSimple(this.label);

  @override
  final String label;
}

/// A transaction error indicating a duplicate instruction at the given index.
class TransactionErrorDuplicateInstruction extends TransactionError {
  const TransactionErrorDuplicateInstruction(this.instructionIndex);

  /// The index of the duplicate instruction.
  final int instructionIndex;

  @override
  String get label => 'DuplicateInstruction';
}

/// A transaction error wrapping an instruction-level error.
class TransactionErrorInstructionError extends TransactionError {
  const TransactionErrorInstructionError(
    this.instructionIndex,
    this.instructionError,
  );

  /// The index of the instruction that caused the error.
  final int instructionIndex;

  /// The instruction-level error.
  final InstructionError instructionError;

  @override
  String get label => 'InstructionError';
}

/// A transaction error indicating insufficient funds for rent at the given
/// account index.
class TransactionErrorInsufficientFundsForRent extends TransactionError {
  const TransactionErrorInsufficientFundsForRent(this.accountIndex);

  /// The index of the account with insufficient funds for rent.
  final int accountIndex;

  @override
  String get label => 'InsufficientFundsForRent';
}

/// A transaction error indicating that program execution is temporarily
/// restricted for the given account index.
class TransactionErrorProgramExecutionTemporarilyRestricted
    extends TransactionError {
  const TransactionErrorProgramExecutionTemporarilyRestricted(
    this.accountIndex,
  );

  /// The index of the restricted account.
  final int accountIndex;

  @override
  String get label => 'ProgramExecutionTemporarilyRestricted';
}

/// All known simple transaction error labels as constants.
abstract final class TransactionErrorLabel {
  static const String accountBorrowOutstanding = 'AccountBorrowOutstanding';
  static const String accountInUse = 'AccountInUse';
  static const String accountLoadedTwice = 'AccountLoadedTwice';
  static const String accountNotFound = 'AccountNotFound';
  static const String addressLookupTableNotFound = 'AddressLookupTableNotFound';
  static const String alreadyProcessed = 'AlreadyProcessed';
  static const String blockhashNotFound = 'BlockhashNotFound';
  static const String callChainTooDeep = 'CallChainTooDeep';
  static const String clusterMaintenance = 'ClusterMaintenance';
  static const String insufficientFundsForFee = 'InsufficientFundsForFee';
  static const String invalidAccountForFee = 'InvalidAccountForFee';
  static const String invalidAccountIndex = 'InvalidAccountIndex';
  static const String invalidAddressLookupTableData =
      'InvalidAddressLookupTableData';
  static const String invalidAddressLookupTableIndex =
      'InvalidAddressLookupTableIndex';
  static const String invalidAddressLookupTableOwner =
      'InvalidAddressLookupTableOwner';
  static const String invalidLoadedAccountsDataSizeLimit =
      'InvalidLoadedAccountsDataSizeLimit';
  static const String invalidProgramForExecution = 'InvalidProgramForExecution';
  static const String invalidRentPayingAccount = 'InvalidRentPayingAccount';
  static const String invalidWritableAccount = 'InvalidWritableAccount';
  static const String maxLoadedAccountsDataSizeExceeded =
      'MaxLoadedAccountsDataSizeExceeded';
  static const String missingSignatureForFee = 'MissingSignatureForFee';
  static const String programAccountNotFound = 'ProgramAccountNotFound';
  static const String resanitizationNeeded = 'ResanitizationNeeded';
  static const String sanitizeFailure = 'SanitizeFailure';
  static const String signatureFailure = 'SignatureFailure';
  static const String tooManyAccountLocks = 'TooManyAccountLocks';
  static const String unbalancedTransaction = 'UnbalancedTransaction';
  static const String unsupportedVersion = 'UnsupportedVersion';
  static const String wouldExceedAccountDataBlockLimit =
      'WouldExceedAccountDataBlockLimit';
  static const String wouldExceedAccountDataTotalLimit =
      'WouldExceedAccountDataTotalLimit';
  static const String wouldExceedMaxAccountCostLimit =
      'WouldExceedMaxAccountCostLimit';
  static const String wouldExceedMaxBlockCostLimit =
      'WouldExceedMaxBlockCostLimit';
  static const String wouldExceedMaxVoteCostLimit =
      'WouldExceedMaxVoteCostLimit';
}
