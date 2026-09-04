import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

/// Parses a JSON string, converting all integer values to [BigInt].
///
/// Floating-point numbers (those containing a decimal point or a negative
/// exponent) are preserved as [double]. All other numerical values are
/// converted to [BigInt] to avoid precision loss with large integers.
///
/// Positive integer exponents must not exceed 10,000. Larger exponents throw
/// [FormatException] before expansion to bound work on untrusted JSON.
/// JSON objects and strings are never interpreted as BigInt markers.
///
/// This is a Dart port of the `parseJsonWithBigInts` function from the
/// `@solana/rpc-spec-types` TypeScript package.
Object? parseJsonWithBigInts(String json) {
  final numbers = <String>[];
  return jsonDecode(
    _indexNumbers(json, numbers),
    reviver: (key, value) =>
        value is int ? _parseJsonNumber(numbers[value]) : value,
  );
}

/// Parses a JSON string using [parseJsonWithBigInts], optionally in an isolate.
///
/// Set [runInIsolate] to `true` for large payloads where moving CPU work off
/// the current isolate can improve responsiveness. Values smaller than
/// [isolateThreshold] are always decoded on the current isolate.
///
/// If isolate execution is unavailable on the current platform, this function
/// automatically falls back to same-isolate decoding.
Future<Object?> parseJsonWithBigIntsAsync(
  String json, {
  bool runInIsolate = false,
  int isolateThreshold = 262144,
}) async {
  if (!runInIsolate || json.length < isolateThreshold) {
    return parseJsonWithBigInts(json);
  }

  try {
    return await Isolate.run<Object?>(
      () => _parseJsonWithBigIntsInIsolate(json),
    );
  } catch (error) {
    if (error is UnsupportedError || error is UnimplementedError) {
      return parseJsonWithBigInts(json);
    }
    rethrow;
  }
}

/// Converts a value to a JSON string, rendering [BigInt] values as large
/// unsafe integers (without quotes).
///
/// This is a Dart port of the `stringifyJsonWithBigInts` function from the
/// `@solana/rpc-spec-types` TypeScript package.
String stringifyJsonWithBigInts(Object? value, {Object? space}) {
  final out = StringBuffer();
  _writeJson(value, out, Set<Object>.identity());
  return out.toString();
}

/// Regex for a valid JSON number.
final _jsonNumberRegExp = RegExp(
  r'-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?',
);

/// Regex to detect numbers with decimals or negative exponents (which should
/// remain as doubles, not BigInts).
final _floatIndicatorRegExp = RegExp(r'\.|[eE]-');

/// Regex to match first character of a possible number.
final _numberStartRegExp = RegExp(r'[-\d]');

final _numberEndRegExp = RegExp(r'[ \t\r\n,\]}]');

String _indexNumbers(String json, List<String> numbers) {
  final out = StringBuffer();
  var inQuote = false;

  for (var ii = 0; ii < json.length; ii++) {
    var isEscaped = false;
    if (json[ii] == r'\') {
      out.write(json[ii]);
      ii++;
      isEscaped = !isEscaped;
    }

    if (ii >= json.length) break;

    if (json[ii] == '"') {
      out.write(json[ii]);
      if (!isEscaped) {
        inQuote = !inQuote;
      }
      continue;
    }

    if (!inQuote) {
      final consumedNumber = _consumeNumber(json, ii);
      if (consumedNumber != null && consumedNumber.isNotEmpty) {
        ii += consumedNumber.length - 1;
        // Every number becomes an index into this private list. Original
        // objects, strings, and integer-valued doubles cannot collide with it.
        out.write(numbers.length);
        numbers.add(consumedNumber);
        continue;
      }
    }

    out.write(json[ii]);
  }

  return out.toString();
}

String? _consumeNumber(String json, int ii) {
  // Stop early if the first character isn't a digit or a minus sign.
  if (!_numberStartRegExp.hasMatch(json[ii])) {
    return null;
  }

  // Otherwise, check if the next characters form a valid JSON number.
  final match = _jsonNumberRegExp.matchAsPrefix(json, ii);
  if (match == null) {
    throw FormatException('Invalid JSON number', json, ii);
  }
  if (match.end < json.length && !_numberEndRegExp.hasMatch(json[match.end])) {
    throw FormatException('Invalid JSON number', json, ii);
  }
  return match.group(0);
}

Object? _parseJsonWithBigIntsInIsolate(String json) {
  return parseJsonWithBigInts(json);
}

Object _parseJsonNumber(String value) {
  if (_floatIndicatorRegExp.hasMatch(value)) {
    return double.parse(value);
  }
  if (RegExp('[eE]').hasMatch(value)) {
    final parts = value.split(RegExp('[eE]'));
    final exponent = int.tryParse(parts[1]);
    if (exponent == null || exponent > 10000) {
      throw FormatException('JSON integer exponent exceeds 10,000', value);
    }
    final units = BigInt.parse(parts[0]);
    return units * BigInt.from(10).pow(exponent);
  }
  return BigInt.parse(value);
}

void _writeJson(Object? value, StringBuffer out, Set<Object> ancestors) {
  if (value is BigInt) {
    out.write(value);
    return;
  }
  if (value is! List<Object?> && value is! Map<Object?, Object?>) {
    out.write(
      jsonEncode(
        value,
        toEncodable: (unsupported) => throw JsonUnsupportedObjectError(
          unsupported,
        ),
      ),
    );
    return;
  }
  if (!ancestors.add(value!)) {
    throw JsonCyclicError(value);
  }
  if (value is List<Object?>) {
    out.write('[');
    for (var index = 0; index < value.length; index++) {
      if (index > 0) out.write(',');
      _writeJson(value[index], out, ancestors);
    }
    out.write(']');
  } else if (value is Map<Object?, Object?>) {
    out.write('{');
    var first = true;
    for (final entry in value.entries) {
      if (entry.key is! String) throw JsonUnsupportedObjectError(value);
      if (!first) out.write(',');
      first = false;
      out
        ..write(jsonEncode(entry.key))
        ..write(':');
      _writeJson(entry.value, out, ancestors);
    }
    out.write('}');
  }
  ancestors.remove(value);
}
