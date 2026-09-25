import 'dart:typed_data';

import 'package:test/test.dart';

/// Returns a matcher that verifies a [Uint8List] is byte-for-byte equal to
/// [expected].
///
/// This is the Dart equivalent of the TS `toEqualArrayBuffer` Jest matcher.
///
/// ```dart
/// expect(actualBytes, equalsBytes(Uint8List.fromList([0x01, 0x02])));
/// ```
Matcher equalsBytes(Uint8List expected) => _EqualsBytesMatcher(expected);

class _EqualsBytesMatcher extends Matcher {
  const _EqualsBytesMatcher(this._expected);

  final Uint8List _expected;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! Uint8List) return false;
    if (item.length != _expected.length) return false;
    for (var i = 0; i < _expected.length; i++) {
      if (item[i] != _expected[i]) return false;
    }
    return true;
  }

  @override
  Description describe(Description description) =>
      description.add('equals bytes ${_formatBytes(_expected)}');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is! Uint8List) {
      return mismatchDescription.add('is not a Uint8List');
    }
    if (item.length != _expected.length) {
      return mismatchDescription.add(
        'has length ${item.length}, expected ${_expected.length}',
      );
    }
    for (var i = 0; i < _expected.length; i++) {
      if (item[i] != _expected[i]) {
        return mismatchDescription.add(
          'differs at index $i: '
          'got 0x${item[i].toRadixString(16).padLeft(2, '0')}, '
          'expected 0x${_expected[i].toRadixString(16).padLeft(2, '0')}',
        );
      }
    }
    return mismatchDescription;
  }

  static String _formatBytes(Uint8List bytes) {
    if (bytes.length <= 8) {
      return '[${bytes.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(', ')}]';
    }
    final first = bytes
        .take(4)
        .map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}')
        .join(', ');
    final last = bytes
        .skip(bytes.length - 4)
        .map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}')
        .join(', ');
    return '[$first, ...(${bytes.length} bytes), $last]';
  }
}

/// Returns a matcher that verifies a [Uint8List] has the given [length].
///
/// ```dart
/// expect(bytes, hasByteLength(32));
/// ```
Matcher hasByteLength(int length) =>
    isA<Uint8List>().having((b) => b.length, 'length', length);

/// Returns a matcher that verifies a [Uint8List] starts with the given
/// [prefix] bytes.
///
/// ```dart
/// expect(bytes, startsWith Bytes(Uint8List.fromList([0x01, 0x02])));
/// ```
Matcher startsWithBytes(Uint8List prefix) => _StartsWithBytesMatcher(prefix);

class _StartsWithBytesMatcher extends Matcher {
  const _StartsWithBytesMatcher(this._prefix);

  final Uint8List _prefix;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! Uint8List) return false;
    if (item.length < _prefix.length) return false;
    for (var i = 0; i < _prefix.length; i++) {
      if (item[i] != _prefix[i]) return false;
    }
    return true;
  }

  @override
  Description describe(Description description) => description.add(
    'starts with bytes ${_EqualsBytesMatcher._formatBytes(_prefix)}',
  );

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is! Uint8List) {
      return mismatchDescription.add('is not a Uint8List');
    }
    if (item.length < _prefix.length) {
      return mismatchDescription.add(
        'has length ${item.length}, which is shorter than prefix length '
        '${_prefix.length}',
      );
    }
    return mismatchDescription;
  }
}
