import 'package:solana_kit_errors/src/codes.dart';
import 'package:solana_kit_errors/src/error.dart';
import 'package:solana_kit_errors/src/transaction_error.dart';

/// Converts a JSON-RPC error response into a [SolanaError].
///
/// [putativeErrorResponse] should be a map with `code`, `message`, and
/// optional `data` fields (standard JSON-RPC error format).
SolanaError getSolanaErrorFromJsonRpcError(Object? putativeErrorResponse) {
  if (_isRpcErrorResponse(putativeErrorResponse)) {
    final response = putativeErrorResponse! as Map<String, Object?>;
    final rawCode = response['code']!;
    final code = rawCode is num ? rawCode.toInt() : rawCode as int;
    final message = response['message']! as String;
    final data = response['data'];

    if (code ==
        SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure) {
      final preflightData = data as Map<String, Object?>? ?? {};
      final err = preflightData['err'];
      final preflightContext = Map<String, Object?>.from(preflightData)
        ..remove('err');

      if (err != null) {
        final cause = getSolanaErrorFromTransactionError(err);
        preflightContext['cause'] = cause;
      }

      return SolanaError(
        SolanaErrorCode.jsonRpcServerErrorSendTransactionPreflightFailure,
        preflightContext,
      );
    }

    Map<String, Object?>? errorContext;
    switch (code) {
      case SolanaErrorCode.jsonRpcInternalError:
      case SolanaErrorCode.jsonRpcInvalidParams:
      case SolanaErrorCode.jsonRpcInvalidRequest:
      case SolanaErrorCode.jsonRpcMethodNotFound:
      case SolanaErrorCode.jsonRpcParseError:
      case SolanaErrorCode.jsonRpcScanError:
      case SolanaErrorCode.jsonRpcServerErrorBlockCleanedUp:
      case SolanaErrorCode.jsonRpcServerErrorBlockNotAvailable:
      case SolanaErrorCode.jsonRpcServerErrorBlockStatusNotAvailableYet:
      case SolanaErrorCode.jsonRpcServerErrorKeyExcludedFromSecondaryIndex:
      case SolanaErrorCode.jsonRpcServerErrorLongTermStorageSlotSkipped:
      case SolanaErrorCode.jsonRpcServerErrorSlotSkipped:
      case SolanaErrorCode
          .jsonRpcServerErrorTransactionPrecompileVerificationFailure:
      case SolanaErrorCode.jsonRpcServerErrorUnsupportedTransactionVersion:
        errorContext = {'__serverMessage': message};
      default:
        if (data is Map<String, Object?>) {
          errorContext = data;
        }
    }

    return SolanaError(code, errorContext);
  }

  // Malformed JSON-RPC error.
  final message =
      putativeErrorResponse is Map<String, Object?> &&
          putativeErrorResponse['message'] is String
      ? putativeErrorResponse['message']! as String
      : 'Malformed JSON-RPC error with no message attribute';
  return SolanaError(SolanaErrorCode.malformedJsonRpcError, {
    'error': putativeErrorResponse,
    'message': message,
  });
}

bool _isRpcErrorResponse(Object? value) {
  if (value is! Map<String, Object?>) return false;
  final code = value['code'];
  final message = value['message'];
  return (code is num || code is int) && message is String;
}
