import 'package:solana_kit_options/src/option.dart';

/// Unwraps the value of an [Option], returning its contained value or `null`.
///
/// - If the option is [Some], returns the contained value `T`.
/// - If the option is [None], returns `null`.
///
/// ```dart
/// unwrapOption(some(42)); // 42
/// unwrapOption(none<int>()); // null
/// ```
T? unwrapOption<T>(Option<T> option) {
  return switch (option) {
    Some<T>(:final value) => value,
    None<T>() => null,
  };
}

/// Unwraps the value of an [Option], returning its contained value or the
/// result of [fallback].
///
/// - If the option is [Some], returns the contained value.
/// - If the option is [None], calls [fallback] and returns the result.
///
/// ```dart
/// unwrapOptionOr(some(42), () => 0); // 42
/// unwrapOptionOr(none<int>(), () => 0); // 0
/// ```
T unwrapOptionOr<T>(Option<T> option, T Function() fallback) {
  return switch (option) {
    Some<T>(:final value) => value,
    None<T>() => fallback(),
  };
}

/// Wraps a nullable value into an [Option].
///
/// - If [nullable] is `null`, returns [None].
/// - Otherwise, returns [Some] containing the value.
///
/// ```dart
/// wrapNullable(42); // Some(42)
/// wrapNullable<int>(null); // None<int>()
/// ```
Option<T> wrapNullable<T>(T? nullable) {
  if (nullable == null) return none<T>();
  return some(nullable);
}
