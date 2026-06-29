import 'package:solana_kit_errors/src/codes.dart';
import 'package:solana_kit_errors/src/error.dart';

/// Shared context key conventions for structured Solana diagnostics.
abstract final class SolanaErrorContextKeys {
  /// Context key for an address value.
  static const String address = 'address';

  /// Context key for the underlying cause of an error.
  static const String cause = 'cause';

  /// Context key for the code of a nested cause error.
  static const String causeCode = 'causeCode';

  /// Context key for the context map of a nested cause error.
  static const String causeContext = 'causeContext';

  /// Context key for the runtime type of a nested cause.
  static const String causeType = 'causeType';

  /// Context key for the name of the method that triggered the error.
  static const String methodName = 'methodName';

  /// Context key for the name of the operation that triggered the error.
  static const String operation = 'operation';

  /// Context key for a path associated with the error.
  static const String path = 'path';

  /// Context key for an HTTP status code.
  static const String statusCode = 'statusCode';

  /// Context key for a URL associated with the error.
  static const String url = 'url';
}

/// Creates a normalized Solana error context map.
///
/// Null values are dropped. When [cause] is provided, its string form is stored
/// under [SolanaErrorContextKeys.cause]. If the cause is another [SolanaError],
/// the nested error code and context are preserved as structured fields.
Map<String, Object?> createSolanaErrorContext(
  Map<String, Object?> context, {
  Object? cause,
}) {
  final normalized = <String, Object?>{
    for (final entry in context.entries)
      if (entry.value != null) entry.key: entry.value,
  };

  if (cause == null) {
    return normalized;
  }

  normalized
    ..putIfAbsent(SolanaErrorContextKeys.cause, cause.toString)
    ..putIfAbsent(
      SolanaErrorContextKeys.causeType,
      () => cause.runtimeType.toString(),
    );

  if (cause is SolanaError) {
    normalized.putIfAbsent(SolanaErrorContextKeys.causeCode, () => cause.code);
    if (cause.context.isNotEmpty) {
      normalized.putIfAbsent(
        SolanaErrorContextKeys.causeContext,
        () => cause.context,
      );
    }
  }

  return normalized;
}

/// Creates a [SolanaError] using normalized context conventions.
SolanaError createSolanaError(
  SolanaErrorCode code, {
  Map<String, Object?> context = const {},
  Object? cause,
}) {
  return SolanaError(code, createSolanaErrorContext(context, cause: cause));
}

/// Creates a [SolanaError] that wraps an underlying [cause].
SolanaError wrapSolanaError(
  SolanaErrorCode code,
  Object cause, {
  Map<String, Object?> context = const {},
}) {
  return createSolanaError(code, context: context, cause: cause);
}
