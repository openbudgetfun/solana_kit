import 'dart:io';

const _sectionNames = {
  'dependencies',
  'dev_dependencies',
  'dependency_overrides',
};

void main() {
  final files = _listPubspecFiles();
  final violations = <String>[];

  for (final file in files) {
    _collectViolations(file, violations);
  }

  if (violations.isEmpty) {
    stdout.writeln(
      'All internal dependencies use workspace: true in pubspec.yaml files.',
    );
    return;
  }

  stderr.writeln(
    'Found internal dependencies that do not use workspace: true:\n'
    '${violations.join('\n')}\n',
  );
  exitCode = 1;
}

List<File> _listPubspecFiles() {
  final root = Directory.current;
  return root
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('pubspec.yaml'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

void _collectViolations(File file, List<String> violations) {
  final lines = file.readAsLinesSync();
  String? section;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final sectionMatch = RegExp(r'^([a-z_]+):\s*$').firstMatch(line);
    if (sectionMatch != null) {
      section = sectionMatch.group(1);
      continue;
    }

    if (section == null || !_sectionNames.contains(section)) {
      continue;
    }

    final depMatch = RegExp(
      r'^  (solana_kit[\w]*|codama_renderers_solana_kit_dart):(?:\s*(.*))?$',
    ).firstMatch(line);

    if (depMatch == null) {
      continue;
    }

    final packageName = depMatch.group(1)!;
    final value = (depMatch.group(2) ?? '').trim();

    if (RegExp(r'^\{\s*workspace:\s*true\s*\}$').hasMatch(value)) {
      continue;
    }

    if (value.isEmpty) {
      final nextLine = i + 1 < lines.length ? lines[i + 1].trim() : '';
      if (nextLine == 'workspace: true') {
        continue;
      }
    }

    final relativePath = file.path.replaceFirst('${Directory.current.path}/', '');
    violations.add(
      '$relativePath:${i + 1} `$packageName` must use `workspace: true`.',
    );
  }
}
