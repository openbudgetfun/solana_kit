import 'package:solana_kit_errors/src/codes.dart';
import 'package:solana_kit_errors/src/error.dart';
import 'package:solana_kit_errors/src/instruction_error.dart';
import 'package:solana_kit_errors/src/rpc_enum_errors.dart';

/// Ordered list of transaction error names from the Solana runtime.
///
/// Keep synced with:
/// https://github.com/anza-xyz/agave/blob/master/sdk/src/transaction/error.rs
const _orderedErrorNames = [
  'AccountInUse',
  'AccountLoadedTwice',
  'AccountNotFound',
  'ProgramAccountNotFound',
  'InsufficientFundsForFee',
  'InvalidAccountForFee',
  'AlreadyProcessed',
  'BlockhashNotFound',
  // `InstructionError` intentionally omitted; delegated to
  // `getSolanaErrorFromInstructionError`
  'CallChainTooDeep',
  'MissingSignatureForFee',
  'InvalidAccountIndex',
  'SignatureFailure',
  'InvalidProgramForExecution',
  'SanitizeFailure',
  'ClusterMaintenance',
  'AccountBorrowOutstanding',
  'WouldExceedMaxBlockCostLimit',
  'UnsupportedVersion',
  'InvalidWritableAccount',
  'WouldExceedMaxAccountCostLimit',
  'WouldExceedAccountDataBlockLimit',
  'TooManyAccountLocks',
  'AddressLookupTableNotFound',
  'InvalidAddressLookupTableOwner',
  'InvalidAddressLookupTableData',
  'InvalidAddressLookupTableIndex',
  'InvalidRentPayingAccount',
  'WouldExceedMaxVoteCostLimit',
  'WouldExceedAccountDataTotalLimit',
  'DuplicateInstruction',
  'InsufficientFundsForRent',
  'MaxLoadedAccountsDataSizeExceeded',
  'InvalidLoadedAccountsDataSizeLimit',
  'ResanitizationNeeded',
  'ProgramExecutionTemporarilyRestricted',
  'UnbalancedTransaction',
];

/// Converts a transaction error from the Solana RPC into a [SolanaError].
///
/// If the error contains an `InstructionError`, it delegates to
/// [getSolanaErrorFromInstructionError].
SolanaError getSolanaErrorFromTransactionError(Object transactionError) {
  if (transactionError is Map<String, Object?> &&
      transactionError.containsKey('InstructionError')) {
    final args = transactionError['InstructionError']! as List<Object?>;
    return getSolanaErrorFromInstructionError(args[0]! as num, args[1]!);
  }
  return getSolanaErrorFromRpcError(
    RpcEnumErrorConfig(
      errorCodeBaseOffset:
          SolanaErrorCode.transactionErrorAccountInUse, // 7050001
      orderedErrorNames: _orderedErrorNames,
      getErrorContext: (errorCode, rpcErrorName, rpcErrorContext) {
        if (errorCode == SolanaErrorCode.transactionErrorUnknown) {
          return {
            'errorName': rpcErrorName,
            if (rpcErrorContext != null)
              'transactionErrorContext': rpcErrorContext,
          };
        } else if (errorCode ==
            SolanaErrorCode.transactionErrorDuplicateInstruction) {
          return {
            'index': rpcErrorContext is num
                ? rpcErrorContext.toInt()
                : rpcErrorContext,
          };
        } else if (errorCode ==
                SolanaErrorCode.transactionErrorInsufficientFundsForRent ||
            errorCode ==
                SolanaErrorCode
                    .transactionErrorProgramExecutionTemporarilyRestricted) {
          final ctx = rpcErrorContext as Map<String, Object?>?;
          return {
            'accountIndex': ctx != null
                ? (ctx['account_index']! as num).toInt()
                : null,
          };
        }
        return null;
      },
    ),
    transactionError,
  );
}
