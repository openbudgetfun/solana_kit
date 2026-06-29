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
  /// Creates a custom instruction error carrying the supplied program [code].
  const InstructionErrorCustom(this.code);

  /// The custom error code from the program.
  final int code;

  @override
  String get label => 'Custom';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstructionErrorCustom &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => Object.hash(runtimeType, code);

  @override
  String toString() => 'InstructionErrorCustom(code: $code)';
}

/// A simple instruction error identified by its string label.
class InstructionErrorSimple extends InstructionError {
  /// Creates a simple instruction error for the supplied [label].
  const InstructionErrorSimple(this.label);

  @override
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstructionErrorSimple &&
          runtimeType == other.runtimeType &&
          label == other.label;

  @override
  int get hashCode => Object.hash(runtimeType, label);

  @override
  String toString() => 'InstructionErrorSimple(label: $label)';
}

/// All known simple instruction error labels as constants.
abstract final class InstructionErrorLabel {
  /// The account was already initialized when the instruction required it not
  /// to be.
  static const String accountAlreadyInitialized = 'AccountAlreadyInitialized';

  /// An attempt to borrow an account for writing failed.
  static const String accountBorrowFailed = 'AccountBorrowFailed';

  /// An account still has outstanding borrows when it should not.
  static const String accountBorrowOutstanding = 'AccountBorrowOutstanding';

  /// The account data size was changed in a way that is not allowed.
  static const String accountDataSizeChanged = 'AccountDataSizeChanged';

  /// The account data is too small for the requested operation.
  static const String accountDataTooSmall = 'AccountDataTooSmall';

  /// The account is not executable but an executable account was required.
  static const String accountNotExecutable = 'AccountNotExecutable';

  /// The account is not rent-exempt but rent exemption was required.
  static const String accountNotRentExempt = 'AccountNotRentExempt';

  /// An arithmetic overflow occurred while executing the instruction.
  static const String arithmeticOverflow = 'ArithmeticOverflow';

  /// A Borsh serialization or deserialization error occurred.
  static const String borshIoError = 'BorshIoError';

  /// A built-in program did not consume any compute units.
  static const String builtinProgramsMustConsumeComputeUnits =
      'BuiltinProgramsMustConsumeComputeUnits';

  /// The maximum call depth was exceeded while executing the program.
  static const String callDepth = 'CallDepth';

  /// The computational budget for the instruction was exceeded.
  static const String computationalBudgetExceeded =
      'ComputationalBudgetExceeded';

  /// The same account was referenced more than once at different indices.
  static const String duplicateAccountIndex = 'DuplicateAccountIndex';

  /// Duplicate accounts have inconsistent states across references.
  static const String duplicateAccountOutOfSync = 'DuplicateAccountOutOfSync';

  /// An executable account is not rent-exempt.
  static const String executableAccountNotRentExempt =
      'ExecutableAccountNotRentExempt';

  /// The executable bit on an account was modified.
  static const String executableDataModified = 'ExecutableDataModified';

  /// Lamports on an executable account were changed.
  static const String executableLamportChange = 'ExecutableLamportChange';

  /// The executable flag on an account was modified.
  static const String executableModified = 'ExecutableModified';

  /// Account data owned by another program was modified.
  static const String externalAccountDataModified =
      'ExternalAccountDataModified';

  /// Lamports on an account owned by another program were spent.
  static const String externalAccountLamportSpend =
      'ExternalAccountLamportSpend';

  /// A generic error occurred while executing the instruction.
  static const String genericError = 'GenericError';

  /// The account owner is not the program that was expected.
  static const String illegalOwner = 'IllegalOwner';

  /// The account is immutable and cannot be modified.
  static const String immutable = 'Immutable';

  /// The instruction's authority did not match the expected one.
  static const String incorrectAuthority = 'IncorrectAuthority';

  /// The program id supplied does not match the expected program.
  static const String incorrectProgramId = 'IncorrectProgramId';

  /// There are insufficient funds to complete the instruction.
  static const String insufficientFunds = 'InsufficientFunds';

  /// The account data is invalid.
  static const String invalidAccountData = 'InvalidAccountData';

  /// The account owner is invalid for the requested operation.
  static const String invalidAccountOwner = 'InvalidAccountOwner';

  /// An argument supplied to the instruction is invalid.
  static const String invalidArgument = 'InvalidArgument';

  /// The program returned an invalid error code.
  static const String invalidError = 'InvalidError';

  /// The instruction data is invalid.
  static const String invalidInstructionData = 'InvalidInstructionData';

  /// An invalid realloc was requested for the account.
  static const String invalidRealloc = 'InvalidRealloc';

  /// The seeds supplied to derive a program address are invalid.
  static const String invalidSeeds = 'InvalidSeeds';

  /// The maximum number of account data allocations was exceeded.
  static const String maxAccountsDataAllocationsExceeded =
      'MaxAccountsDataAllocationsExceeded';

  /// The maximum number of accounts in a transaction was exceeded.
  static const String maxAccountsExceeded = 'MaxAccountsExceeded';

  /// The maximum instruction trace length was exceeded.
  static const String maxInstructionTraceLengthExceeded =
      'MaxInstructionTraceLengthExceeded';

  /// The maximum seed length was exceeded while deriving an address.
  static const String maxSeedLengthExceeded = 'MaxSeedLengthExceeded';

  /// A required account was missing from the instruction.
  static const String missingAccount = 'MissingAccount';

  /// A required signature was missing for an account.
  static const String missingRequiredSignature = 'MissingRequiredSignature';

  /// The program id of an account was modified.
  static const String modifiedProgramId = 'ModifiedProgramId';

  /// There were not enough account keys supplied to the instruction.
  static const String notEnoughAccountKeys = 'NotEnoughAccountKeys';

  /// An instruction attempted a privileged operation without authorization.
  static const String privilegeEscalation = 'PrivilegeEscalation';

  /// The program environment could not be set up for execution.
  static const String programEnvironmentSetupFailure =
      'ProgramEnvironmentSetupFailure';

  /// The program failed to compile.
  static const String programFailedToCompile = 'ProgramFailedToCompile';

  /// The program failed to complete execution.
  static const String programFailedToComplete = 'ProgramFailedToComplete';

  /// Data on a read-only account was modified.
  static const String readonlyDataModified = 'ReadonlyDataModified';

  /// Lamports on a read-only account were modified.
  static const String readonlyLamportChange = 'ReadonlyLamportChange';

  /// Reentrancy is not allowed for the invoked program.
  static const String reentrancyNotAllowed = 'ReentrancyNotAllowed';

  /// The rent epoch of an account was modified.
  static const String rentEpochModified = 'RentEpochModified';

  /// The instruction's account credits and debits do not balance.
  static const String unbalancedInstruction = 'UnbalancedInstruction';

  /// The account has not been initialized.
  static const String uninitializedAccount = 'UninitializedAccount';

  /// The program id is not supported.
  static const String unsupportedProgramId = 'UnsupportedProgramId';

  /// The sysvar account is not supported.
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
  /// Creates a simple transaction error for the supplied [label].
  const TransactionErrorSimple(this.label);

  @override
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionErrorSimple &&
          runtimeType == other.runtimeType &&
          label == other.label;

  @override
  int get hashCode => Object.hash(runtimeType, label);

  @override
  String toString() => 'TransactionErrorSimple(label: $label)';
}

/// A transaction error indicating a duplicate instruction at the given index.
class TransactionErrorDuplicateInstruction extends TransactionError {
  /// Creates a duplicate-instruction error for the supplied [instructionIndex].
  const TransactionErrorDuplicateInstruction(this.instructionIndex);

  /// The index of the duplicate instruction.
  final int instructionIndex;

  @override
  String get label => 'DuplicateInstruction';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionErrorDuplicateInstruction &&
          runtimeType == other.runtimeType &&
          instructionIndex == other.instructionIndex;

  @override
  int get hashCode => Object.hash(runtimeType, instructionIndex);

  @override
  String toString() =>
      'TransactionErrorDuplicateInstruction(instructionIndex: $instructionIndex)';
}

/// A transaction error wrapping an instruction-level error.
class TransactionErrorInstructionError extends TransactionError {
  /// Creates a transaction error wrapping the [instructionError] that
  /// occurred at [instructionIndex].
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionErrorInstructionError &&
          runtimeType == other.runtimeType &&
          instructionIndex == other.instructionIndex &&
          instructionError == other.instructionError;

  @override
  int get hashCode =>
      Object.hash(runtimeType, instructionIndex, instructionError);

  @override
  String toString() =>
      'TransactionErrorInstructionError(instructionIndex: $instructionIndex, '
      'instructionError: $instructionError)';
}

/// A transaction error indicating insufficient funds for rent at the given
/// account index.
class TransactionErrorInsufficientFundsForRent extends TransactionError {
  /// Creates an insufficient-funds-for-rent error for the supplied
  /// [accountIndex].
  const TransactionErrorInsufficientFundsForRent(this.accountIndex);

  /// The index of the account with insufficient funds for rent.
  final int accountIndex;

  @override
  String get label => 'InsufficientFundsForRent';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionErrorInsufficientFundsForRent &&
          runtimeType == other.runtimeType &&
          accountIndex == other.accountIndex;

  @override
  int get hashCode => Object.hash(runtimeType, accountIndex);

  @override
  String toString() =>
      'TransactionErrorInsufficientFundsForRent(accountIndex: $accountIndex)';
}

/// A transaction error indicating that program execution is temporarily
/// restricted for the given account index.
class TransactionErrorProgramExecutionTemporarilyRestricted
    extends TransactionError {
  /// Creates a program-execution-temporarily-restricted error for the supplied
  /// [accountIndex].
  const TransactionErrorProgramExecutionTemporarilyRestricted(
    this.accountIndex,
  );

  /// The index of the restricted account.
  final int accountIndex;

  @override
  String get label => 'ProgramExecutionTemporarilyRestricted';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionErrorProgramExecutionTemporarilyRestricted &&
          runtimeType == other.runtimeType &&
          accountIndex == other.accountIndex;

  @override
  int get hashCode => Object.hash(runtimeType, accountIndex);

  @override
  String toString() =>
      'TransactionErrorProgramExecutionTemporarilyRestricted('
      'accountIndex: $accountIndex)';
}

/// All known simple transaction error labels as constants.
abstract final class TransactionErrorLabel {
  /// An account in the transaction has an outstanding borrow.
  static const String accountBorrowOutstanding = 'AccountBorrowOutstanding';

  /// An account in the transaction is already in use.
  static const String accountInUse = 'AccountInUse';

  /// An account was loaded more than once in the transaction.
  static const String accountLoadedTwice = 'AccountLoadedTwice';

  /// A referenced account could not be found.
  static const String accountNotFound = 'AccountNotFound';

  /// The referenced address lookup table could not be found.
  static const String addressLookupTableNotFound = 'AddressLookupTableNotFound';

  /// The transaction has already been processed.
  static const String alreadyProcessed = 'AlreadyProcessed';

  /// The transaction's blockhash is no longer valid.
  static const String blockhashNotFound = 'BlockhashNotFound';

  /// The call chain is too deep.
  static const String callChainTooDeep = 'CallChainTooDeep';

  /// The cluster is in maintenance mode.
  static const String clusterMaintenance = 'ClusterMaintenance';

  /// There are insufficient funds to pay the transaction fee.
  static const String insufficientFundsForFee = 'InsufficientFundsForFee';

  /// The account designated to pay the fee is invalid.
  static const String invalidAccountForFee = 'InvalidAccountForFee';

  /// An account index in the transaction is invalid.
  static const String invalidAccountIndex = 'InvalidAccountIndex';

  /// The address lookup table data is invalid.
  static const String invalidAddressLookupTableData =
      'InvalidAddressLookupTableData';

  /// The address lookup table index is invalid.
  static const String invalidAddressLookupTableIndex =
      'InvalidAddressLookupTableIndex';

  /// The address lookup table owner is invalid.
  static const String invalidAddressLookupTableOwner =
      'InvalidAddressLookupTableOwner';

  /// The loaded accounts data size limit is invalid.
  static const String invalidLoadedAccountsDataSizeLimit =
      'InvalidLoadedAccountsDataSizeLimit';

  /// The program selected for execution is invalid.
  static const String invalidProgramForExecution = 'InvalidProgramForExecution';

  /// A rent-paying account in the transaction is invalid.
  static const String invalidRentPayingAccount = 'InvalidRentPayingAccount';

  /// An account marked writable in the transaction is invalid.
  static const String invalidWritableAccount = 'InvalidWritableAccount';

  /// The maximum loaded accounts data size was exceeded.
  static const String maxLoadedAccountsDataSizeExceeded =
      'MaxLoadedAccountsDataSizeExceeded';

  /// A required signature for the fee payer is missing.
  static const String missingSignatureForFee = 'MissingSignatureForFee';

  /// A referenced program account could not be found.
  static const String programAccountNotFound = 'ProgramAccountNotFound';

  /// The transaction needs to be resanitized before processing.
  static const String resanitizationNeeded = 'ResanitizationNeeded';

  /// The transaction failed sanitization.
  static const String sanitizeFailure = 'SanitizeFailure';

  /// A signature in the transaction is invalid.
  static const String signatureFailure = 'SignatureFailure';

  /// The transaction would acquire too many account locks.
  static const String tooManyAccountLocks = 'TooManyAccountLocks';

  /// The transaction's account credits and debits do not balance.
  static const String unbalancedTransaction = 'UnbalancedTransaction';

  /// The transaction version is not supported.
  static const String unsupportedVersion = 'UnsupportedVersion';

  /// The transaction would exceed the per-block account data limit.
  static const String wouldExceedAccountDataBlockLimit =
      'WouldExceedAccountDataBlockLimit';

  /// The transaction would exceed the total account data limit.
  static const String wouldExceedAccountDataTotalLimit =
      'WouldExceedAccountDataTotalLimit';

  /// The transaction would exceed the maximum per-account cost limit.
  static const String wouldExceedMaxAccountCostLimit =
      'WouldExceedMaxAccountCostLimit';

  /// The transaction would exceed the maximum block cost limit.
  static const String wouldExceedMaxBlockCostLimit =
      'WouldExceedMaxBlockCostLimit';

  /// The transaction would exceed the maximum vote cost limit.
  static const String wouldExceedMaxVoteCostLimit =
      'WouldExceedMaxVoteCostLimit';
}
