import 'dart:convert';

/// Parses a JSON string, converting all integer values to [BigInt].
///
/// Floating-point numbers (those containing a decimal point or a negative
/// exponent) are preserved as [double]. All other numerical values are
/// converted to [BigInt] to avoid precision loss with large integers.
///
/// This is a Dart port of the `parseJsonWithBigInts` function from the
/// `@solana/rpc-spec-types` TypeScript package.
Object? parseJsonWithBigInts(String json) {
  return jsonDecode(
    _wrapIntegersInBigIntValueObject(json),
    reviver: (key, value) {
      if (_isBigIntValueObject(value)) {
        return _unwrapBigIntValueObject(value! as Map<String, Object?>);
      }
      return value;
    },
  );
}

/// Converts a value to a JSON string, rendering [BigInt] values as large
/// unsafe integers (without quotes).
///
/// This is a Dart port of the `stringifyJsonWithBigInts` function from the
/// `@solana/rpc-spec-types` TypeScript package.
String stringifyJsonWithBigInts(Object? value, {Object? space}) {
  final jsonString = jsonEncode(
    value,
    toEncodable: (v) {
      if (v is BigInt) {
        return {r'$n': v.toString()};
      }
      throw JsonUnsupportedObjectError(v);
    },
  );
  return _unwrapBigIntStringValueObject(jsonString);
}

/// Regex for a valid JSON number.
final _jsonNumberRegExp = RegExp(
  r'^-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?',
);

/// Regex to detect numbers with decimals or negative exponents (which should
/// remain as doubles, not BigInts).
final _floatIndicatorRegExp = RegExp(r'\.|[eE]-');

/// Regex to match first character of a possible number.
final _numberStartRegExp = RegExp(r'[-\d]');

String _wrapIntegersInBigIntValueObject(String json) {
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
        // Don't wrap numbers that contain a decimal point or negative exponent.
        if (_floatIndicatorRegExp.hasMatch(consumedNumber)) {
          out.write(consumedNumber);
        } else {
          out.write(_wrapBigIntValueObject(consumedNumber));
        }
        continue;
      }
    }

    out.write(json[ii]);
  }

  return out.toString();
}

String? _consumeNumber(String json, int ii) {
  // Stop early if the first character isn't a digit or a minus sign.
  if (ii >= json.length || !_numberStartRegExp.hasMatch(json[ii])) {
    return null;
  }

  // Otherwise, check if the next characters form a valid JSON number.
  final match = _jsonNumberRegExp.firstMatch(json.substring(ii));
  return match?.group(0);
}

String _wrapBigIntValueObject(String value) {
  return '{"\$n":"$value"}';
}

BigInt _unwrapBigIntValueObject(Map<String, Object?> obj) {
  final value = obj[r'$n']! as String;
  if (RegExp('[eE]').hasMatch(value)) {
    final parts = value.split(RegExp('[eE]'));
    final units = BigInt.parse(parts[0]);
    final exponent = BigInt.parse(parts[1]);
    return units * BigInt.from(10).pow(exponent.toInt());
  }
  return BigInt.parse(value);
}

bool _isBigIntValueObject(Object? value) {
  if (value is Map<String, Object?> &&
      value.length == 1 &&
      value.containsKey(r'$n') &&
      value[r'$n'] is String) {
    return true;
  }
  return false;
}

/// Regex to unwrap BigInt value objects from a JSON string.
final _bigIntValueObjectRegExp = RegExp(r'\{\s*"\$n"\s*:\s*"(-?\d+)"\s*\}');

String _unwrapBigIntStringValueObject(String value) {
  return value.replaceAllMapped(
    _bigIntValueObjectRegExp,
    (match) => match.group(1)!,
  );
}
