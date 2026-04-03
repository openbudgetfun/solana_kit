/// Extension that adds a [pipe] method to any value, enabling functional
/// pipeline composition.
///
/// This is the Dart equivalent of the `pipe()` function from the
/// `@solana/functional` TypeScript package. It allows you to perform
/// successive transforms of a value using functions.
///
/// ```dart
/// final result = 'test'
///     .pipe((value) => value.toUpperCase())
///     .pipe((value) => '$value!');
/// // result == 'TEST!'
/// ```
///
/// This is particularly useful for building up Solana transaction messages:
///
/// ```dart
/// final message = createTransactionMessage(version: 0)
///     .pipe(setTransactionMessageFeePayer(myAddress))
///     .pipe(setTransactionMessageLifetimeUsingBlockhash(blockhash))
///     .pipe(appendTransactionMessageInstruction(instruction));
/// ```
@Deprecated(
  'Use the Pipe extension re-exported by '
  'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart '
  'or package:solana_kit/solana_kit.dart. This compatibility package will be '
  'removed in a future release.',
)
extension Pipe<T> on T {
  /// Transforms this value using the given [transform] function and returns
  /// the result.
  R pipe<R>(R Function(T value) transform) => transform(this);
}
