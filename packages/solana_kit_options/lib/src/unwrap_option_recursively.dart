import 'dart:typed_data';

import 'package:solana_kit_options/src/option.dart';

/// Recursively unwraps all nested [Option] types within a value.
///
/// This function traverses a given value and removes all instances
/// of [Option], replacing them with their contained values.
///
/// - If an [Option] is encountered, its value is extracted.
/// - If a [Map] or [List] is encountered, its elements are traversed
///   recursively.
/// - If [None] is encountered, it is replaced with `null` or the result of
///   [fallback] if provided.
///
/// ```dart
/// unwrapOptionRecursively(some(some('Hello'))); // "Hello"
/// unwrapOptionRecursively(some(none<String>())); // null
///
/// unwrapOptionRecursively({
///   'a': 'hello',
///   'b': none<String>(),
///   'c': [some(42), none<int>()],
/// });
/// // {'a': 'hello', 'b': null, 'c': [42, null]}
/// ```
Object? unwrapOptionRecursively(Object? input, [Object? Function()? fallback]) {
  // Null and typed data pass through.
  if (input == null || input is TypedData) {
    return input;
  }

  // Primitive types pass through.
  if (input is num || input is bool || input is String) {
    return input;
  }

  Object? next(Object? x) => unwrapOptionRecursively(x, fallback);

  // Handle Option.
  if (input is Option) {
    return switch (input) {
      Some(:final value) => next(value),
      None() => fallback != null ? fallback() : null,
    };
  }

  // Handle List.
  if (input is List) {
    return input.map(next).toList();
  }

  // Handle Map.
  if (input is Map) {
    return input.map((key, value) => MapEntry(key, next(value)));
  }

  // Everything else passes through.
  return input;
}
