// ignore_for_file: cascade_invocations

import 'dart:io';

final _entryPattern = RegExp(
  r'^"?(?<target>[A-Za-z0-9_-]+)"?\s*:\s*(?<bump>patch|minor|major)\s*$',
);

void main(List<String> args) {
  final paths = args.isEmpty
      ? Directory('.changeset')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.md'))
            .map((file) => file.path)
            .toList()
      : args;
  paths.sort();

  final errors = <String>[];
  for (final path in paths) {
    if (!path.startsWith('.changeset/') || !path.endsWith('.md')) continue;
    final file = File(path);
    if (!file.existsSync()) continue;

    final lines = file.readAsLinesSync();
    if (lines.isEmpty || lines.first.trim() != '---') continue;

    final closingIndex = lines
        .skip(1)
        .toList()
        .indexWhere((line) => line.trim() == '---');
    if (closingIndex == -1) continue;

    final entries = lines
        .sublist(1, closingIndex + 1)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);

    for (final entry in entries) {
      final match = _entryPattern.firstMatch(entry);
      if (match == null) continue;
      if (match.namedGroup('target') == 'main') {
        errors.add(
          '$path: targets the `main` release group. Target the granular package ids instead.',
        );
      }
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('Changeset package target validation failed:');
    for (final error in errors) {
      stderr.writeln('- $error');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Validated ${paths.length} changeset file(s): none target the `main` group.',
  );
}
