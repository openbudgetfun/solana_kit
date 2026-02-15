import 'package:solana_kit_errors/src/message_formatter.dart';

/// The core error class for all Solana Kit errors.
///
/// Each error carries an integer [code] from `SolanaErrorCode` and an optional
/// [context] map containing structured data about the error.
class SolanaError implements Exception {
  SolanaError(this.code, [Map<String, Object?>? context])
    : context = context != null
          ? Map<String, Object?>.unmodifiable(context)
          : const {} {
    _message = getErrorMessage(code, this.context);
  }

  /// The numeric error code from `SolanaErrorCode`.
  final int code;

  /// Structured context data for this error.
  final Map<String, Object?> context;

  late final String _message;

  @override
  String toString() => 'SolanaError#$code: $_message';
}

/// Returns `true` if [e] is a [SolanaError].
///
/// If [code] is provided, also checks that the error's code matches.
bool isSolanaError(Object? e, [int? code]) {
  if (e is SolanaError) {
    if (code != null) {
      return e.code == code;
    }
    return true;
  }
  return false;
}
