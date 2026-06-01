// ignore_for_file: parameter_assignments

import 'dart:io';

final _providerStartPattern = RegExp(
  r'<!--\s*\{@([A-Za-z0-9_]+)(?::[^}]*)?\}\s*-->',
);
final _providerEndPattern = RegExp(r'<!--\s*\{/([A-Za-z0-9_]+)\}\s*-->');
final _consumerStartPattern = RegExp(
  r'^(?<indent>\s*)///\s*<!--\s*\{=(?<name>[A-Za-z0-9_]+)(?<transforms>[^}]*)\}\s*-->\s*$',
);
final _consumerEndPattern = RegExp(
  r'^(?<indent>\s*)///\s*<!--\s*\{/(?<name>[A-Za-z0-9_]+)\}\s*-->\s*$',
);
const _supportedTransforms = {'replace', 'trim', 'trimStart', 'trimEnd'};

void main(List<String> args) {
  try {
    final check = args.contains('--check');
    final write = !check || args.contains('--write');
    final providers = _parseProviders(Directory.current);
    final dartFiles = _dartLibraryFiles();

    final changedPaths = <String>[];
    var consumerCount = 0;
    for (final file in dartFiles) {
      final blocks = _consumerBlocks(file);
      if (blocks.isEmpty) continue;
      consumerCount += blocks.length;
      final changed = _updateFile(file, providers, write: write);
      if (changed) changedPaths.add(file.path);
    }

    final mode = write ? 'Updated' : 'Checked';
    if (changedPaths.isEmpty) {
      stdout.writeln(
        '$mode $consumerCount Dart doc comment consumer block(s); all are up to date.',
      );
      return;
    }

    if (write) {
      stdout.writeln(
        'Updated ${changedPaths.length} file(s) across $consumerCount Dart doc comment consumer block(s).',
      );
      return;
    }

    stderr.writeln(
      '${changedPaths.length} file(s) have stale Dart doc comment consumers across $consumerCount block(s).',
    );
    for (final path in changedPaths) {
      stderr.writeln('- $path');
    }
    exitCode = 1;
  } on _ParseError catch (error) {
    stderr.writeln('error: ${error.message}');
    exitCode = 2;
  }
}

Map<String, String> _parseProviders(Directory repoRoot) {
  final providers = <String, String>{};
  final templates =
      repoRoot
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.t.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final template in templates) {
    final lines = template.readAsLinesSync();
    var index = 0;
    while (index < lines.length) {
      final start = _providerStartPattern.firstMatch(lines[index]);
      if (start == null) {
        index += 1;
        continue;
      }

      final name = start.group(1)!;
      var endIndex = index + 1;
      while (endIndex < lines.length) {
        final end = _providerEndPattern.firstMatch(lines[endIndex]);
        if (end != null && end.group(1) == name) break;
        endIndex += 1;
      }
      if (endIndex >= lines.length) {
        throw _ParseError(
          'Missing provider end tag for `$name` in ${template.path}',
        );
      }
      if (providers.containsKey(name)) {
        throw _ParseError(
          'Duplicate provider `$name` found in ${template.path} and another template file.',
        );
      }
      providers[name] = lines.sublist(index + 1, endIndex).join('\n');
      index = endIndex + 1;
    }
  }
  return providers;
}

List<File> _dartLibraryFiles() {
  final packages = Directory('packages');
  if (!packages.existsSync()) return [];
  final files =
      packages
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (file) =>
                file.path.contains('/lib/') && file.path.endsWith('.dart'),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return files;
}

List<_ConsumerBlock> _consumerBlocks(File file) {
  final lines = file.readAsLinesSync();
  final blocks = <_ConsumerBlock>[];
  var index = 0;
  while (index < lines.length) {
    final start = _consumerStartPattern.firstMatch(lines[index]);
    if (start == null) {
      index += 1;
      continue;
    }

    final name = start.namedGroup('name')!;
    final transforms = _parseTransforms(start.namedGroup('transforms')!);
    var endIndex = index + 1;
    while (endIndex < lines.length) {
      final end = _consumerEndPattern.firstMatch(lines[endIndex]);
      if (end != null && end.namedGroup('name') == name) break;
      endIndex += 1;
    }
    if (endIndex >= lines.length) {
      throw _ParseError('Missing consumer end tag for `$name` in ${file.path}');
    }

    blocks.add(_ConsumerBlock(name, index, endIndex, transforms));
    index = endIndex + 1;
  }
  return blocks;
}

bool _updateFile(
  File file,
  Map<String, String> providers, {
  required bool write,
}) {
  final originalText = file.readAsStringSync();
  final lines = originalText.split('\n');
  if (lines.isNotEmpty && lines.last == '') lines.removeLast();
  final blocks = _consumerBlocks(file);
  if (blocks.isEmpty) return false;

  final updated = [...lines];
  var delta = 0;
  var changed = false;
  for (final block in blocks) {
    final provider = providers[block.name];
    if (provider == null) {
      throw _ParseError(
        'No provider found for consumer `${block.name}` in ${file.path}',
      );
    }

    final replacement = _renderDocComment(
      _applyTransforms(provider, block.transforms),
    );
    final start = block.startIndex + 1 + delta;
    final end = block.endIndex + delta;
    final current = updated.sublist(start, end);
    if (!_listEquals(current, replacement)) {
      updated.replaceRange(start, end, replacement);
      delta += replacement.length - current.length;
      changed = true;
    }
  }

  if (!changed) return false;
  var newText = updated.join('\n');
  if (originalText.endsWith('\n')) newText += '\n';
  if (write) file.writeAsStringSync(newText);
  return true;
}

List<String> _renderDocComment(String content) {
  final lines = content.split('\n');
  if (lines.length == 1 && lines.single.isEmpty) return ['///'];
  return [for (final line in lines) line.isEmpty ? '///' : '/// $line'];
}

String _applyTransforms(String content, List<_Transform> transforms) {
  var rendered = content;
  for (final transform in transforms) {
    switch (transform.name) {
      case 'replace':
        rendered = rendered.replaceAll(
          transform.oldValue!,
          transform.newValue!,
        );
      case 'trim':
        rendered = rendered.trim();
      case 'trimStart':
        rendered = rendered.trimLeft();
      case 'trimEnd':
        rendered = rendered.trimRight();
      default:
        throw _ParseError('Unsupported transform `${transform.name}`');
    }
  }
  return rendered;
}

List<_Transform> _parseTransforms(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return [];
  final transforms = <_Transform>[];
  var index = 0;
  while (index < text.length) {
    if (text[index] != '|') {
      throw _ParseError('Expected `|` in transform list: $text');
    }
    index += 1;

    final nameStart = index;
    while (index < text.length && text[index] != ':' && text[index] != '|') {
      index += 1;
    }
    final name = text.substring(nameStart, index).trim();
    if (!_supportedTransforms.contains(name)) {
      throw _ParseError('Unsupported transform `$name` in $text');
    }

    if (name == 'replace') {
      if (index >= text.length || text[index] != ':') {
        throw _ParseError('`replace` requires two quoted arguments: $text');
      }
      index += 1;
      final oldDecoded = _decodeQuoted(text, index);
      index = oldDecoded.$2;
      if (index >= text.length || text[index] != ':') {
        throw _ParseError('`replace` requires two quoted arguments: $text');
      }
      index += 1;
      final newDecoded = _decodeQuoted(text, index);
      index = newDecoded.$2;
      transforms.add(_Transform(name, oldDecoded.$1, newDecoded.$1));
    } else {
      transforms.add(_Transform(name));
    }
  }
  return transforms;
}

(String, int) _decodeQuoted(String text, int index) {
  if (index >= text.length || text[index] != '"') {
    throw _ParseError('Expected quoted string at offset $index: $text');
  }
  index += 1;
  final buffer = StringBuffer();
  while (index < text.length) {
    final char = text[index];
    if (char == r'\') {
      index += 1;
      if (index >= text.length) {
        throw _ParseError('Invalid trailing escape in transform: $text');
      }
      final escape = text[index];
      buffer.write(switch (escape) {
        '"' => '"',
        r'\' => r'\',
        'n' => '\n',
        'r' => '\r',
        't' => '\t',
        _ => escape,
      });
      index += 1;
      continue;
    }
    if (char == '"') return (buffer.toString(), index + 1);
    buffer.write(char);
    index += 1;
  }
  throw _ParseError('Unterminated quoted string in transform: $text');
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i += 1) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

final class _ConsumerBlock {
  const _ConsumerBlock(
    this.name,
    this.startIndex,
    this.endIndex,
    this.transforms,
  );
  final String name;
  final int startIndex;
  final int endIndex;
  final List<_Transform> transforms;
}

final class _Transform {
  const _Transform(this.name, [this.oldValue, this.newValue]);
  final String name;
  final String? oldValue;
  final String? newValue;
}

final class _ParseError implements Exception {
  const _ParseError(this.message);
  final String message;
}
