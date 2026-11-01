/// A small server-side syntax highlighter for the languages the docs use.
///
/// It emits CSS token classes (`tok-k`, `tok-s`, …) instead of inline
/// colours, so code blocks follow the site's light and dark palettes.
library;

/// A run of source text and the token class that colours it, if any.
typedef HighlightSpan = ({String? token, String text});

/// Splits [source] into highlighted spans for [language].
///
/// Unknown languages are returned as a single uncoloured span: they still
/// render, just without colour.
List<HighlightSpan> highlight(String source, String? language) {
  final rules = switch (language?.toLowerCase()) {
    'dart' => _dartRules,
    'yaml' || 'yml' => _yamlRules,
    'bash' || 'sh' || 'shell' || 'console' => _shellRules,
    'json' => _jsonRules,
    _ => null,
  };

  if (rules == null) return [(token: null, text: source)];

  final spans = <HighlightSpan>[];
  final plain = StringBuffer();

  void flushPlain() {
    if (plain.isEmpty) return;
    spans.add((token: null, text: plain.toString()));
    plain.clear();
  }

  var index = 0;

  outer:
  while (index < source.length) {
    for (final rule in rules) {
      final match = rule.pattern.matchAsPrefix(source, index);

      if (match == null || match.end == index) continue;
      final text = match[0]!;
      final token = rule.classify(text, source, match.end);

      if (token == null) {
        plain.write(text);
      } else {
        flushPlain();
        spans.add((token: token, text: text));
      }

      index = match.end;
      continue outer;
    }

    plain.write(source[index]);
    index++;
  }

  flushPlain();

  return spans;
}

final class _Rule {
  _Rule(String pattern, String token, {bool multiLine = false})
    : pattern = RegExp(pattern, multiLine: multiLine),
      classify = ((_, _, _) => token);

  _Rule.classified(String pattern, this.classify, {bool multiLine = false})
    : pattern = RegExp(pattern, multiLine: multiLine);

  final RegExp pattern;

  /// Picks the token for a match from its text and what follows it.
  final String? Function(String text, String source, int end) classify;
}

const _dartKeywords = {
  'abstract', 'as', 'assert', 'async', 'await', 'base', 'break', 'case', //
  'catch', 'class', 'const', 'continue', 'covariant', 'default', 'deferred',
  'do', 'dynamic', 'else', 'enum', 'export', 'extends', 'extension',
  'external', 'factory', 'false', 'final', 'finally', 'for', 'Function', 'get',
  'hide', 'if', 'implements', 'import', 'in', 'interface', 'is', 'late',
  'library', 'mixin', 'new', 'null', 'on', 'operator', 'part', 'required',
  'rethrow', 'return', 'sealed', 'set', 'show', 'static', 'super', 'switch',
  'sync', 'this', 'throw', 'true', 'try', 'type', 'typedef', 'var', 'void',
  'when', 'while', 'with', 'yield',
};

/// Classifies a Dart identifier as a keyword, call, type, or plain name.
String? _dartIdentifier(String text, String source, int end) {
  if (_dartKeywords.contains(text)) return 'tok-k';
  var next = end;

  while (next < source.length && source[next] == ' ') {
    next++;
  }

  final first = text.codeUnitAt(0);

  if (first >= 0x41 && first <= 0x5a) return 'tok-t';

  return next < source.length && source[next] == '(' ? 'tok-f' : null;
}

final _dartRules = [
  _Rule(r'///[^\n]*|//[^\n]*', 'tok-c'),
  _Rule(r'/\*[\s\S]*?\*/', 'tok-c'),
  _Rule(
    r"r?'''[\s\S]*?'''|"
        r'r?"""[\s\S]*?"""',
    'tok-s',
  ),
  _Rule(
    r"r?'(?:[^'\\\n]|\\.)*'|"
        r'r?"(?:[^"\\\n]|\\.)*"',
    'tok-s',
  ),
  _Rule(r'@[A-Za-z_]\w*', 'tok-a'),
  _Rule(
    r'\b(?:0x[0-9a-fA-F_]+|\d[\d_]*(?:\.\d[\d_]*)?(?:e[+-]?\d+)?)\b',
    'tok-n',
  ),
  _Rule.classified(r'[A-Za-z_$][\w$]*', _dartIdentifier),
];

final _yamlRules = [
  _Rule(r'#[^\n]*', 'tok-c'),
  _Rule(r'^[ \t-]*[\w./-]+(?=\s*:)', 'tok-t', multiLine: true),
  _Rule(
    r"'[^'\n]*'|"
        r'"(?:[^"\\\n]|\\.)*"',
    'tok-s',
  ),
  _Rule(r'[\^~]?\d[\w.+-]*', 'tok-n'),
  _Rule(r'\b(?:true|false|null)\b', 'tok-k'),
];

final _shellRules = [
  _Rule(r'#[^\n]*', 'tok-c'),
  _Rule(
    r"'[^'\n]*'|"
        r'"(?:[^"\\\n]|\\.)*"',
    'tok-s',
  ),
  _Rule(r'^\s*\$?\s*[\w./:-]+', 'tok-f', multiLine: true),
  _Rule(r'(?<=\s)--?[\w-]+(?:=\S*)?', 'tok-k'),
  _Rule(r'\$\{?\w+\}?', 'tok-t'),
];

final _jsonRules = [
  _Rule(r'"(?:[^"\\\n]|\\.)*"(?=\s*:)', 'tok-t'),
  _Rule(r'"(?:[^"\\\n]|\\.)*"', 'tok-s'),
  _Rule(r'-?\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b', 'tok-n'),
  _Rule(r'\b(?:true|false|null)\b', 'tok-k'),
];
