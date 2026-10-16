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
/// Pass [space] to pretty-print the output, exactly like `JSON.stringify`'s
/// space argument: an [int] indents by that many spaces (clamped to 10, zero
/// or negative for compact output) and a [String] is repeated at each nesting
/// level (first 10 characters). Compact output is the default.
///
/// This is a Dart port of the `stringifyJsonWithBigInts` function from the
/// `@solana/rpc-spec-types` TypeScript package.
String stringifyJsonWithBigInts(Object? value, {Object? space}) {
  final gap = _gapFor(space);
  final out = StringBuffer();
  _writeJson(value, out, Set<Object>.identity(), gap: gap);

  return out.toString();
}

/// The per-level indent string for JSON.stringify's space argument, or null
/// for compact output.
String? _gapFor(Object? space) {
  if (space is int) {
    if (space <= 0) return null;
    return ' ' * (space > 10 ? 10 : space);
  }
  if (space is String) {
    if (space.isEmpty) return null;
    return space.length > 10 ? space.substring(0, 10) : space;
  }
  return null;
}

/// Regex for a valid JSON number.
final _jsonNumberRegExp = RegExp(
  r'-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?',
);

/// Regex to detect numbers with decimals or negative exponents (which should
/// remain as doubles, not BigInts).
final _floatIndicatorRegExp = RegExp(r'\.|[eE]-');

/// Regex to match a JSON integer's exponent separator.
final _exponentSeparatorRegExp = RegExp('[eE]');

/// Replaces every number in [json] with the index of its text in [numbers].
///
/// Scanning is done by code unit rather than by character: the previous
/// implementation allocated a one-character string and ran up to two regular
/// expressions for every character of the payload, then rebuilt the whole
/// document a character at a time. Strings are copied in runs and numbers are
/// recognised by their first code unit, so the per-character work no longer
/// depends on the regular-expression engine.
String _indexNumbers(String json, List<String> numbers) {
  final length = json.length;
  final out = StringBuffer();
  var chunkStart = 0;
  var inQuote = false;
  var ii = 0;

  while (ii < length) {
    final codeUnit = json.codeUnitAt(ii);

    if (codeUnit == _quote) {
      // A quote toggles string context unless it is backslash-escaped.
      var backslashes = 0;

      for (var j = ii - 1; j >= 0 && json.codeUnitAt(j) == _backslash; j--) {
        backslashes++;
      }

      if (backslashes.isEven) inQuote = !inQuote;
      ii++;
      continue;
    }

    if (inQuote) {
      ii++;
      continue;
    }

    if (codeUnit == _minus || (codeUnit >= _zero && codeUnit <= _nine)) {
      final consumed = _consumeNumber(json, ii);

      if (consumed != null) {
        // Flush the literal run, then emit this number's index marker.
        out
          ..write(json.substring(chunkStart, ii))
          ..write(numbers.length);
        numbers.add(consumed);
        ii += consumed.length;
        chunkStart = ii;
        continue;
      }
    }

    ii++;
  }

  out.write(json.substring(chunkStart));

  return out.toString();
}

const int _quote = 0x22;
const int _backslash = 0x5c;
const int _minus = 0x2d;
const int _zero = 0x30;
const int _nine = 0x39;

/// Consumes a complete JSON number at [start], or returns null when the text
/// there is not a number.
///
/// The regular expression is anchored with [RegExp.matchAsPrefix] and checked
/// only once per candidate; characters inside strings never reach it because
/// the caller skips string contents.
String? _consumeNumber(String json, int start) {
  final match = _jsonNumberRegExp.matchAsPrefix(json, start);

  if (match == null) {
    throw FormatException('Invalid JSON number', json, start);
  }
  if (match.end < json.length &&
      !_isNumberTerminator(json.codeUnitAt(match.end))) {
    throw FormatException('Invalid JSON number', json, start);
  }

  return match.group(0);
}

/// Whether [codeUnit] may follow a JSON number.
bool _isNumberTerminator(int codeUnit) {
  return codeUnit == 0x20 || // space
      codeUnit == 0x09 || // tab
      codeUnit == 0x0d || // carriage return
      codeUnit == 0x0a || // newline
      codeUnit == 0x2c || // ,
      codeUnit == 0x5d || // ]
      codeUnit == 0x7d; // }
}

Object? _parseJsonWithBigIntsInIsolate(String json) {
  return parseJsonWithBigInts(json);
}

Object _parseJsonNumber(String value) {
  if (_floatIndicatorRegExp.hasMatch(value)) {
    return double.parse(value);
  }

  if (value.contains(_exponentSeparatorRegExp)) {
    final separator = value.indexOf(_exponentSeparatorRegExp);
    final exponent = int.tryParse(value.substring(separator + 1));

    if (exponent == null || exponent > 10000) {
      throw FormatException('JSON integer exponent exceeds 10,000', value);
    }

    final units = BigInt.parse(value.substring(0, separator));

    return units * BigInt.from(10).pow(exponent);
  }

  return BigInt.parse(value);
}

void _writeJson(
  Object? value,
  StringBuffer out,
  Set<Object> ancestors, {
  String? gap,
  int depth = 0,
}) {
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

  final pretty = gap != null;
  final indent = pretty ? gap : null;

  String indentAt(int level) => pretty ? indent! * level : '';

  if (value is List<Object?>) {
    if (value.isEmpty) {
      out.write('[]');
      ancestors.remove(value);
      return;
    }
    out.write(pretty ? '[\n' : '[');

    for (var index = 0; index < value.length; index++) {
      if (index > 0) out.write(pretty ? ',\n' : ',');
      out.write(indentAt(depth + 1));
      _writeJson(
        value[index],
        out,
        ancestors,
        gap: gap,
        depth: depth + 1,
      );
    }

    out
      ..write(pretty ? '\n' : '')
      ..write('${indentAt(depth)}]');
  } else if (value is Map<Object?, Object?>) {
    if (value.isEmpty) {
      out.write('{}');
      ancestors.remove(value);
      return;
    }
    out.write(pretty ? '{\n' : '{');

    var first = true;

    for (final entry in value.entries) {
      if (entry.key is! String) throw JsonUnsupportedObjectError(value);

      if (!first) out.write(pretty ? ',\n' : ',');
      first = false;
      out
        ..write(indentAt(depth + 1))
        ..write(jsonEncode(entry.key))
        ..write(pretty ? ': ' : ':');
      _writeJson(entry.value, out, ancestors, gap: gap, depth: depth + 1);
    }

    out
      ..write(pretty ? '\n' : '')
      ..write('${indentAt(depth)}}');
  }

  ancestors.remove(value);
}
