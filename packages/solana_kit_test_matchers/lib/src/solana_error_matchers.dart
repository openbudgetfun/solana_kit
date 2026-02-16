import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

/// Returns a matcher that verifies an object is a [SolanaError] with the
/// given [code].
///
/// ```dart
/// expect(error, isSolanaErrorWithCode(SolanaErrorCode.someCode));
/// ```
Matcher isSolanaErrorWithCode(int code) =>
    isA<SolanaError>().having((e) => e.code, 'code', code);

/// Returns a matcher that verifies a function throws a [SolanaError] with
/// the given [code].
///
/// ```dart
/// expect(() => doSomething(), throwsSolanaErrorWithCode(SolanaErrorCode.someCode));
/// ```
Matcher throwsSolanaErrorWithCode(int code) =>
    throwsA(isSolanaErrorWithCode(code));

/// Returns a matcher that verifies an object is a [SolanaError] with the
/// given [code] and whose [SolanaError.context] contains the specified
/// key-value entries.
///
/// ```dart
/// expect(
///   error,
///   isSolanaErrorWithCodeAndContext(
///     SolanaErrorCode.someCode,
///     {'key': 'value'},
///   ),
/// );
/// ```
Matcher isSolanaErrorWithCodeAndContext(
  int code,
  Map<String, Object?> expectedContext,
) {
  var matcher = isSolanaErrorWithCode(code);
  for (final entry in expectedContext.entries) {
    matcher = isA<SolanaError>()
        .having((e) => e.code, 'code', code)
        .having(
          (e) => e.context[entry.key],
          'context[${entry.key}]',
          entry.value,
        );
  }
  return matcher;
}

/// A matcher that verifies an object is a [SolanaError].
///
/// ```dart
/// expect(error, isSolanaError);
/// ```
const Matcher isSolanaErrorMatcher = TypeMatcher<SolanaError>();

/// A matcher that verifies a function throws a [SolanaError].
///
/// ```dart
/// expect(() => doSomething(), throwsSolanaError);
/// ```
final Matcher throwsSolanaError = throwsA(isSolanaErrorMatcher);
