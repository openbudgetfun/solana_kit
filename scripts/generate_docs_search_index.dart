import 'dart:convert';
import 'dart:io';

const _contentRoot = 'docs/site/content';
const _outputPath = 'docs/site/web/search-index.json';

void main(List<String> args) {
  final checkOnly = args.contains('--check');
  final root = Directory(_contentRoot);

  if (!root.existsSync()) {
    stderr.writeln('Docs content directory not found: $_contentRoot');
    exitCode = 1;
    return;
  }

  final entries =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.md'))
          .map(_entryForFile)
          .toList()
        ..sort(
          (a, b) => (a['route']! as String).compareTo(b['route']! as String),
        );

  final json = '${const JsonEncoder.withIndent('  ').convert(entries)}\n';
  final output = File(_outputPath);

  if (checkOnly) {
    if (!output.existsSync()) {
      stderr.writeln('Search index is missing: $_outputPath');
      exitCode = 1;
      return;
    }

    final current = output.readAsStringSync();
    if (current != json) {
      stderr.writeln(
        'Search index is stale. Run: dart run scripts/generate_docs_search_index.dart',
      );
      exitCode = 1;
    }
    return;
  }

  output.parent.createSync(recursive: true);
  output.writeAsStringSync(json);
  stdout.writeln('Wrote ${entries.length} docs search entries to $_outputPath');
}

Map<String, Object> _entryForFile(File file) {
  final relativePath = file.path
      .replaceAll(r'\', '/')
      .substring(_contentRoot.length + 1);
  final source = file.readAsStringSync();
  final (frontMatter, markdown) = _splitFrontMatter(source);
  final headings = _headings(markdown).toList();
  final title =
      frontMatter['title'] ??
      headings.firstOrNull ??
      _titleFromPath(relativePath);
  final description = frontMatter['description'] ?? '';
  final text = _plainText(markdown);

  return {
    'title': title,
    if (description.isNotEmpty) 'description': description,
    'route': _routeForPath(relativePath),
    if (headings.isNotEmpty) 'headings': headings,
    'content': text,
  };
}

(Map<String, String>, String) _splitFrontMatter(String source) {
  final normalized = source.replaceAll('\r\n', '\n');
  if (!normalized.startsWith('---\n')) {
    return ({}, normalized);
  }

  final end = normalized.indexOf('\n---\n', 4);
  if (end == -1) {
    return ({}, normalized);
  }

  final frontMatter = <String, String>{};
  for (final line in normalized.substring(4, end).split('\n')) {
    final separator = line.indexOf(':');
    if (separator == -1) {
      continue;
    }

    final key = line.substring(0, separator).trim();
    final value = line.substring(separator + 1).trim();
    if (key.isNotEmpty && value.isNotEmpty) {
      frontMatter[key] = _unquote(value);
    }
  }

  return (frontMatter, normalized.substring(end + 5));
}

Iterable<String> _headings(String markdown) sync* {
  for (final match in RegExp(
    r'^#{1,3}\s+(.+)$',
    multiLine: true,
  ).allMatches(markdown)) {
    final heading = _cleanInlineMarkdown(match.group(1) ?? '').trim();
    if (heading.isNotEmpty) {
      yield heading;
    }
  }
}

String _plainText(String markdown) {
  final withoutCodeBlocks = markdown.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');
  final withoutComments = withoutCodeBlocks.replaceAll(
    RegExp(r'<!--[\s\S]*?-->'),
    ' ',
  );
  final withoutLinks = withoutComments.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\([^)]+\)'),
    (match) => match.group(1) ?? '',
  );
  final withoutMarkup = _cleanInlineMarkdown(withoutLinks)
      .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
      .replaceAll(RegExp(r'^>\s?', multiLine: true), '')
      .replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  const maxLength = 12000;
  if (withoutMarkup.length <= maxLength) {
    return withoutMarkup;
  }

  return withoutMarkup.substring(0, maxLength);
}

String _cleanInlineMarkdown(String value) {
  return value
      .replaceAllMapped(RegExp('`([^`]+)`'), (match) => match.group(1) ?? '')
      .replaceAll(RegExp('[*_~]+'), '')
      .replaceAll(RegExp('<[^>]+>'), '');
}

String _routeForPath(String relativePath) {
  final withoutExtension = relativePath.substring(
    0,
    relativePath.length - '.md'.length,
  );
  if (withoutExtension == 'index') {
    return '/';
  }

  if (withoutExtension.endsWith('/index')) {
    return '/${withoutExtension.substring(0, withoutExtension.length - '/index'.length)}';
  }

  return '/$withoutExtension';
}

String _titleFromPath(String relativePath) {
  final name = relativePath.split('/').last.replaceFirst(RegExp(r'\.md$'), '');
  return name
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _unquote(String value) {
  if (value.length < 2) {
    return value;
  }

  final first = value[0];
  final last = value[value.length - 1];
  if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
    return value.substring(1, value.length - 1);
  }

  return value;
}
