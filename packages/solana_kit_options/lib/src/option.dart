import 'package:meta/meta.dart';

/// A Rust-like `Option<T>` type for representing optional values.
///
/// In Rust, optional values use `Option<T>`, which is either:
/// - `Some(T)` — a present value.
/// - `None` — the absence of a value.
///
/// Dart already has nullable types (`T?`), but they fail with nested options.
/// For example, `Option<Option<T>>` cannot be represented as `T??` because
/// there is no way to distinguish between `Some(None)` and `None`.
///
/// This sealed class hierarchy mirrors Rust's `Option<T>`:
///
/// ```dart
/// final option = some(42); // Some<int>(42)
/// final empty = none<int>(); // None<int>()
/// ```
@immutable
sealed class Option<T> {
  /// Creates an [Option].
  const Option();
}

/// Represents an [Option] that contains a value.
///
/// ```dart
/// final value = Some(42);
/// value.value; // 42
/// ```
final class Some<T> extends Option<T> {
  /// Creates a [Some] with the given [value].
  const Some(this.value);

  /// The contained value.
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Some<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Some($value)';
}

/// Represents an [Option] that contains no value.
///
/// ```dart
/// final empty = const None<int>();
/// ```
final class None<T> extends Option<T> {
  /// Creates a [None].
  const None();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is None<T> && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'None';
}

/// Creates a new [Option] containing [value].
///
/// ```dart
/// some(42); // Some<int>(42)
/// some<int?>(null); // Some<int?>(null)
/// ```
Option<T> some<T>(T value) => Some<T>(value);

/// Creates a new [Option] with no value.
///
/// ```dart
/// none<int>(); // None<int>()
/// ```
Option<T> none<T>() => None<T>();

/// Returns `true` if [input] is an [Option] (either [Some] or [None]).
///
/// ```dart
/// isOption(some(42)); // true
/// isOption(none()); // true
/// isOption(42); // false
/// isOption(null); // false
/// ```
bool isOption(Object? input) => input is Option;

/// Returns `true` if [option] is a [Some].
///
/// ```dart
/// isSome(some(42)); // true
/// isSome(none()); // false
/// ```
bool isSome<T>(Option<T> option) => option is Some<T>;

/// Returns `true` if [option] is a [None].
///
/// ```dart
/// isNone(some(42)); // false
/// isNone(none()); // true
/// ```
bool isNone<T>(Option<T> option) => option is None<T>;
