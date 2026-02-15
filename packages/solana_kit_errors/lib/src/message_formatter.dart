import 'package:solana_kit_errors/src/messages.dart';

/// Returns the human-readable error message for the given error [code],
/// with `$variable` placeholders interpolated from [context].
String getErrorMessage(int code, [Map<String, Object?> context = const {}]) {
  final template = solanaErrorMessages[code];
  if (template == null || template.isEmpty) {
    return 'Solana error #$code';
  }
  return _interpolate(template, context);
}

String _interpolate(String template, Map<String, Object?> context) {
  final buffer = StringBuffer();
  var i = 0;
  while (i < template.length) {
    final char = template[i];
    if (char == r'\' && i + 1 < template.length) {
      // Escape sequence: skip backslash, emit next char.
      i++;
      buffer.write(template[i]);
      i++;
    } else if (char == r'$') {
      // Variable reference: collect word characters after $.
      i++;
      final start = i;
      while (i < template.length && _isWordChar(template[i])) {
        i++;
      }
      final variableName = template.substring(start, i);
      if (variableName.isNotEmpty && context.containsKey(variableName)) {
        buffer.write(context[variableName]);
      } else if (variableName.isNotEmpty) {
        buffer
          ..write(r'$')
          ..write(variableName);
      } else {
        buffer.write(r'$');
      }
    } else {
      buffer.write(char);
      i++;
    }
  }
  return buffer.toString();
}

bool _isWordChar(String char) {
  final c = char.codeUnitAt(0);
  return (c >= 0x30 && c <= 0x39) || // 0-9
      (c >= 0x41 && c <= 0x5A) || // A-Z
      (c >= 0x61 && c <= 0x7A) || // a-z
      c == 0x5F; // _
}
