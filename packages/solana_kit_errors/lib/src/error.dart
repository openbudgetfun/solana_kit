// ignore_for_file: public_member_api_docs
import 'package:solana_kit_errors/src/codes.dart';
import 'package:solana_kit_errors/src/message_formatter.dart';

/// The core error class for all Solana Kit errors.
///
/// Each error carries a [SolanaErrorCode] [code] and an optional
/// [context] map containing structured data about the error.
class SolanaError implements Exception {
  SolanaError(this.code, [Map<String, Object?>? context])
    : context = context != null
          ? Map<String, Object?>.unmodifiable(context)
          : const {} {
    _message = getErrorMessage(code, this.context);
  }

  /// The error code from `SolanaErrorCode`.
  final SolanaErrorCode code;

  /// Structured context data for this error.
  final Map<String, Object?> context;

  late final String _message;

  @override
  String toString() => 'SolanaError#${code.value}: $_message';
}

/// Returns `true` if [e] is a [SolanaError].
///
/// If [code] is provided, also checks that the error's code matches.
bool isSolanaError(Object? e, [SolanaErrorCode? code]) {
  if (e is SolanaError) {
    if (code != null) {
      return e.code == code;
    }
    return true;
  }
  return false;
}
