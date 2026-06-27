import 'dart:async';

import 'package:solana_kit_errors/solana_kit_errors.dart';

int? getHttpStatus(Object error) {
  if (error is SolanaError) {
    final status = error.context[SolanaErrorContextKeys.statusCode];
    if (status is int) return status;
  }
  return null;
}

bool isRetryableError(Object error) {
  final status = getHttpStatus(error);
  if (status != null) return status >= 500;
  return true;
}

Future<T> retryWithBackoff<T>(
  Future<T> Function() fn, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 2),
  Future<void> Function(Duration delay)? sleep,
}) async {
  Object? lastError;
  final wait = sleep ?? Future<void>.delayed;

  for (var attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } on Object catch (error) {
      lastError = error;
      if (!isRetryableError(error)) rethrow;
      if (attempt < maxRetries - 1) await wait(delay);
    }
  }

  Error.throwWithStackTrace(lastError!, StackTrace.current);
}
