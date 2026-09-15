/// A pipeline applies successive transforms to a value.
///
/// Dart has a method-chaining form of this (`value.pipe(fn)`) in
/// `package:solana_kit_transaction_messages`. This library provides the
/// standalone form, `pipe(init, fn1, fn2, …)`, which matches the `pipe()`
/// function from the TypeScript `@solana/functional` package and reads better
/// when a pipeline starts from a freshly constructed value.
///
/// ```dart
/// final total = pipe(
///   1,
///   (value) => value + 1,
///   (value) => value * 2,
///   (value) => value - 1,
/// ); // 3
/// ```
library;

export 'src/pipe.dart';
