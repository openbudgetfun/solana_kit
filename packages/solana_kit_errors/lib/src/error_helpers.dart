import 'package:solana_kit_errors/src/error.dart';

/// Shared context key conventions for structured Solana diagnostics.
abstract final class SolanaErrorContextKeys {
  static const String address = 'address';
  static const String cause = 'cause';
  static const String causeCode = 'causeCode';
  static const String causeContext = 'causeContext';
  static const String causeType = 'causeType';
  static const String methodName = 'methodName';
  static const String operation = 'operation';
  static const String path = 'path';
  static const String statusCode = 'statusCode';
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
  int code, {
  Map<String, Object?> context = const {},
  Object? cause,
}) {
  return SolanaError(
    code,
    createSolanaErrorContext(context, cause: cause),
  );
}

/// Creates a [SolanaError] that wraps an underlying [cause].
SolanaError wrapSolanaError(
  int code,
  Object cause, {
  Map<String, Object?> context = const {},
}) {
  return createSolanaError(code, context: context, cause: cause);
}
