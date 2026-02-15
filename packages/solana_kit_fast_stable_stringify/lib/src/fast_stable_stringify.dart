import 'dart:convert';

/// Deterministic JSON stringification with sorted object keys.
///
/// Unlike `jsonEncode`, this function sorts map keys alphabetically to produce
/// a deterministic output for the same input regardless of insertion order.
///
/// Handles the following Dart types:
/// - `null` → `"null"`
/// - `bool` → `"true"` / `"false"`
/// - `int` / `double` → number string (non-finite values become `"null"`)
/// - `BigInt` → `"<value>n"` (matches JavaScript BigInt serialization)
/// - `String` → JSON-escaped string
/// - `List` → JSON array (recursively stringified)
/// - `Map<String, Object?>` → JSON object with sorted keys (recursively
///   stringified)
/// - Objects with a `toJson()` method → recursively stringified
///
/// Returns `null` for values that have no JSON representation (like
/// `Function`).
String? fastStableStringify(Object? value) {
  final result = _stringify(value, false);
  if (result != null) {
    return result;
  }
  return null;
}

String? _stringify(Object? val, bool isArrayProp) {
  if (val == null) {
    return 'null';
  }

  if (val is bool) {
    return val ? 'true' : 'false';
  }

  if (val is String) {
    return jsonEncode(val);
  }

  if (val is int) {
    return val.isFinite ? '$val' : 'null';
  }

  if (val is double) {
    if (val.isNaN || val.isInfinite) {
      return 'null';
    }
    return '$val';
  }

  if (val is BigInt) {
    return '${val}n';
  }

  if (val is List) {
    final buffer = StringBuffer('[');
    final max = val.length - 1;
    for (var i = 0; i < max; i++) {
      buffer
        ..write(_stringify(val[i], true) ?? 'null')
        ..write(',');
    }
    if (max > -1) {
      buffer.write(_stringify(val[max], true) ?? 'null');
    }
    buffer.write(']');
    return buffer.toString();
  }

  if (val is Map<String, Object?>) {
    final keys = val.keys.toList()..sort();
    final buffer = StringBuffer();
    for (final key in keys) {
      final propVal = _stringify(val[key], false);
      if (propVal != null) {
        if (buffer.isNotEmpty) {
          buffer.write(',');
        }
        buffer
          ..write(jsonEncode(key))
          ..write(':')
          ..write(propVal);
      }
    }
    return '{$buffer}';
  }

  // Try toJson() method via reflection-free approach
  if (val is ToJsonable) {
    return _stringify(val.toJson(), isArrayProp);
  }

  // For other objects, try to encode with jsonEncode
  try {
    return jsonEncode(val);
  } on Object {
    return isArrayProp ? 'null' : null;
  }
}

/// Mixin for objects that implement a `toJson()` method, enabling
/// deterministic stringification via [fastStableStringify].
mixin ToJsonable {
  /// Converts this object to a JSON-compatible value.
  Object? toJson();
}
