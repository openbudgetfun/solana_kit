import 'dart:convert';

/// Encodes a context [Map] into a compact string representation.
///
/// Uses URL query parameter format, then base64-encodes the result.
String encodeContextObject(Map<String, Object?> context) {
  if (context.isEmpty) return '';
  final params = context.entries
      .map((e) => '${Uri.encodeComponent(e.key)}=${_encodeValue(e.value)}')
      .join('&');
  return base64Encode(utf8.encode(params));
}

/// Decodes a base64-encoded context string back into a [Map].
Map<String, Object?> decodeEncodedContext(String encodedContext) {
  if (encodedContext.isEmpty) return {};
  final decoded = utf8.decode(base64Decode(encodedContext));
  final params = Uri.splitQueryString(decoded);
  return params.map((key, value) => MapEntry(key, _decodeValue(value)));
}

String _encodeValue(Object? value) {
  if (value == null) return Uri.encodeComponent('null');
  if (value is List) {
    return Uri.encodeComponent(value.map(_encodeValue).join(','));
  }
  if (value is Map) {
    final json = jsonEncode(value);
    return Uri.encodeComponent(json);
  }
  return Uri.encodeComponent(value.toString());
}

Object? _decodeValue(String value) {
  if (value == 'null') return null;
  // Try to parse as int.
  final asInt = int.tryParse(value);
  if (asInt != null) return asInt;
  // Try to parse as JSON object/array.
  if (value.startsWith('{') || value.startsWith('[')) {
    try {
      return jsonDecode(value);
    } on FormatException {
      // Not JSON, return as string.
    }
  }
  return value;
}
