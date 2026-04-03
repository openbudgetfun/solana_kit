/// Extension that adds a [pipe] method to any value, enabling functional
/// pipeline composition.
///
/// This is the Dart equivalent of the `pipe()` function from the
/// TypeScript `@solana/functional` package. It allows you to perform
/// successive transforms of a value using functions.
///
/// ```dart
/// final result = 'test'
///     .pipe((value) => value.toUpperCase())
///     .pipe((value) => '$value!');
/// ```
extension Pipe<T> on T {
  /// Transforms this value using [transform] and returns the result.
  R pipe<R>(R Function(T value) transform) => transform(this);
}
