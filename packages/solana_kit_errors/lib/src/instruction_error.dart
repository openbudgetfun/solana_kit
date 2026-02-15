import 'package:solana_kit_errors/src/codes.dart';
import 'package:solana_kit_errors/src/error.dart';
import 'package:solana_kit_errors/src/rpc_enum_errors.dart';

/// Ordered list of instruction error names from the Solana runtime.
///
/// Keep synced with:
/// https://github.com/anza-xyz/solana-sdk/blob/master/instruction-error/src/lib.rs
const _orderedErrorNames = [
  'GenericError',
  'InvalidArgument',
  'InvalidInstructionData',
  'InvalidAccountData',
  'AccountDataTooSmall',
  'InsufficientFunds',
  'IncorrectProgramId',
  'MissingRequiredSignature',
  'AccountAlreadyInitialized',
  'UninitializedAccount',
  'UnbalancedInstruction',
  'ModifiedProgramId',
  'ExternalAccountLamportSpend',
  'ExternalAccountDataModified',
  'ReadonlyLamportChange',
  'ReadonlyDataModified',
  'DuplicateAccountIndex',
  'ExecutableModified',
  'RentEpochModified',
  'NotEnoughAccountKeys',
  'AccountDataSizeChanged',
  'AccountNotExecutable',
  'AccountBorrowFailed',
  'AccountBorrowOutstanding',
  'DuplicateAccountOutOfSync',
  'Custom',
  'InvalidError',
  'ExecutableDataModified',
  'ExecutableLamportChange',
  'ExecutableAccountNotRentExempt',
  'UnsupportedProgramId',
  'CallDepth',
  'MissingAccount',
  'ReentrancyNotAllowed',
  'MaxSeedLengthExceeded',
  'InvalidSeeds',
  'InvalidRealloc',
  'ComputationalBudgetExceeded',
  'PrivilegeEscalation',
  'ProgramEnvironmentSetupFailure',
  'ProgramFailedToComplete',
  'ProgramFailedToCompile',
  'Immutable',
  'IncorrectAuthority',
  'BorshIoError',
  'AccountNotRentExempt',
  'InvalidAccountOwner',
  'ArithmeticOverflow',
  'UnsupportedSysvar',
  'IllegalOwner',
  'MaxAccountsDataAllocationsExceeded',
  'MaxAccountsExceeded',
  'MaxInstructionTraceLengthExceeded',
  'BuiltinProgramsMustConsumeComputeUnits',
];

/// Converts an instruction error from the Solana RPC into a [SolanaError].
///
/// [index] is the instruction index within the transaction.
/// [instructionError] is the RPC error value (either a string or a map).
SolanaError getSolanaErrorFromInstructionError(
  num index,
  Object instructionError,
) {
  final numberIndex = index.toInt();
  return getSolanaErrorFromRpcError(
    RpcEnumErrorConfig(
      errorCodeBaseOffset:
          SolanaErrorCode.instructionErrorGenericError, // 4615001
      orderedErrorNames: _orderedErrorNames,
      getErrorContext: (errorCode, rpcErrorName, rpcErrorContext) {
        if (errorCode == SolanaErrorCode.instructionErrorUnknown) {
          return {
            'errorName': rpcErrorName,
            'index': numberIndex,
            if (rpcErrorContext != null)
              'instructionErrorContext': rpcErrorContext,
          };
        } else if (errorCode == SolanaErrorCode.instructionErrorCustom) {
          return {
            'code': rpcErrorContext is num
                ? rpcErrorContext.toInt()
                : rpcErrorContext,
            'index': numberIndex,
          };
        }
        return {'index': numberIndex};
      },
    ),
    instructionError,
  );
}
