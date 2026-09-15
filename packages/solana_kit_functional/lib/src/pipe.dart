/// Applies each transform in [transforms] to [initial] in order and returns the
/// final result.
///
/// This is the standalone form of the pipeline, matching the `pipe()` function
/// from the TypeScript `@solana/functional` package. When no transforms are
/// given, [initial] is returned unchanged.
///
/// Each transform receives the previous result, so a transform must cast its
/// argument when the pipeline changes type. The return type is [Object?]
/// because Dart cannot express the per-step type threading upstream's overloads
/// encode. Pipelines that stay within one type read well with the standalone
/// form; pipelines that change type are usually clearer using the
/// method-chaining `pipe` extension in `package:solana_kit_transaction_messages`,
/// which infers the result type from each transform.
///
/// ```dart
/// final total = pipe(1, [
///   (value) => (value! as int) + 1,
///   (value) => (value! as int) * 2,
/// ]); // 4
/// ```
Object? pipe(
  Object? initial, [
  Iterable<Object? Function(Object? input)> transforms = const [],
]) {
  var result = initial;
  for (final transform in transforms) {
    result = transform(result);
  }
  return result;
}
