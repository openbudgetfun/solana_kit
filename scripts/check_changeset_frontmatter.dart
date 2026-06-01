// ignore_for_file: cascade_invocations

import 'dart:io';

const _allowedValues = {'patch', 'minor', 'major'};

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
    final file = File(path);
    if (!file.existsSync()) {
      errors.add('$path: file does not exist');
      continue;
    }

    final lines = file.readAsLinesSync();
    if (lines.isEmpty || lines.first.trim() != '---') {
      errors.add("$path: missing opening frontmatter delimiter '---'");
      continue;
    }

    final closingIndex = lines
        .skip(1)
        .toList()
        .indexWhere((line) => line.trim() == '---');
    if (closingIndex == -1) {
      errors.add("$path: missing closing frontmatter delimiter '---'");
      continue;
    }

    final entries = lines
        .sublist(1, closingIndex + 1)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (entries.length != 1) {
      if (entries.isEmpty) {
        errors.add(
          '$path: frontmatter must contain exactly one entry: `default: patch|minor|major`',
        );
      } else {
        final found = entries.map((entry) => '`$entry`').join(', ');
        errors.add(
          '$path: frontmatter must only contain one `default:` entry; found $found',
        );
      }
      continue;
    }

    final entry = entries.single;
    final separator = entry.indexOf(':');
    if (separator == -1) {
      errors.add(
        '$path: invalid frontmatter entry `$entry`; expected `default: patch|minor|major`',
      );
      continue;
    }

    final key = entry.substring(0, separator).trim();
    final value = entry.substring(separator + 1).trim();
    if (key != 'default' || !_allowedValues.contains(value)) {
      errors.add(
        '$path: expected `default: patch|minor|major`, found `$entry`',
      );
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('Changeset frontmatter validation failed:');
    for (final error in errors) {
      stderr.writeln('- $error');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Validated ${paths.length} changeset file(s): all use `default:` frontmatter.',
  );
}
