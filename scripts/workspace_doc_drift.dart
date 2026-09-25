// ignore_for_file: cascade_invocations

import 'dart:io';

void main(List<String> args) {
  final mode = args.isEmpty ? '--check' : args.single;
  if (mode != '--check' && mode != '--write') {
    stderr.writeln(
      'Usage: dart run scripts/workspace_doc_drift.dart [--check|--write]',
    );
    exitCode = 2;
    return;
  }

  final publishingGuide = File('docs/publishing-guide.md');
  if (!publishingGuide.existsSync()) {
    stderr.writeln('Missing required file: ${publishingGuide.path}');
    exitCode = 2;
    return;
  }

  final pubspecs =
      Directory('packages')
          .listSync()
          .whereType<Directory>()
          .map((directory) => File('${directory.path}/pubspec.yaml'))
          .where((file) => file.existsSync())
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final packages = <String>{};
  final internalPackages = <String>{};
  final packageDependencies = <String, Set<String>>{};

  for (final pubspec in pubspecs) {
    final lines = pubspec.readAsLinesSync();
    final packageName = _readPackageName(lines, pubspec.path);
    packages.add(packageName);
    if (lines.any(
      (line) => RegExp(r'^publish_to:\s*none\s*$').hasMatch(line),
    )) {
      internalPackages.add(packageName);
    }
    packageDependencies[packageName] = _readDependencies(lines);
  }

  final sortedPackages = packages.toList()..sort();
  final sortedInternalPackages = internalPackages.toList()..sort();
  final graphLines = <String>[];
  for (final package in sortedPackages) {
    final deps =
        (packageDependencies[package] ?? const <String>{})
            .where(packages.contains)
            .toList()
          ..sort();
    graphLines.add('$package -> ${deps.isEmpty ? '(none)' : deps.join(', ')}');
  }

  final totalPackages = sortedPackages.length;
  final internalCount = sortedInternalPackages.length;
  final publishablePackages = totalPackages - internalCount;
  final internalList = sortedInternalPackages.isEmpty
      ? '(none)'
      : sortedInternalPackages.map((package) => '`$package`').join(', ');

  final summary =
      '\n\n'
      'This monorepo contains **$totalPackages packages** under `packages/`: '
      '**$publishablePackages publishable** and **$internalCount internal** '
      '($internalList).\n\n';
  final graph = '\n\n```text\n${graphLines.join('\n')}\n```\n\n';

  final original = publishingGuide.readAsStringSync();
  var updated = _replaceBlock(
    original,
    '<!-- workspace-summary:start -->',
    '<!-- workspace-summary:end -->',
    summary,
    publishingGuide.path,
  );
  updated = _replaceBlock(
    updated,
    '<!-- workspace-dependency-graph:start -->',
    '<!-- workspace-dependency-graph:end -->',
    graph,
    publishingGuide.path,
  );

  if (mode == '--write') {
    publishingGuide.writeAsStringSync(updated);
    stdout.writeln('Updated workspace summary and dependency graph blocks.');
    return;
  }

  if (original != updated) {
    stderr.writeln(
      'Workspace documentation drift detected in ${publishingGuide.path}',
    );
    stderr.writeln('Run `dart run scripts/workspace_doc_drift.dart --write`.');
    exitCode = 1;
    return;
  }

  stdout.writeln('Workspace documentation blocks are up to date.');
}

String _replaceBlock(
  String input,
  String startMarker,
  String endMarker,
  String content,
  String path,
) {
  final start = input.indexOf(startMarker);
  final end = input.indexOf(endMarker);
  if (start == -1 && end == -1) {
    stdout.writeln(
      'Workspace documentation blocks are not configured in $path; skipping.',
    );
    return input;
  }
  if (start == -1 || end == -1 || end < start) {
    stderr.writeln('Incomplete workspace documentation markers in $path');
    exit(3);
  }

  final replacementStart = start + startMarker.length;
  return input.replaceRange(replacementStart, end, content);
}

String _readPackageName(List<String> lines, String path) {
  for (final line in lines) {
    final match = RegExp(r'^name:\s*([^\s#]+)').firstMatch(line);
    if (match != null) return match.group(1)!;
  }
  stderr.writeln('Failed to parse package name from $path');
  exit(2);
}

Set<String> _readDependencies(List<String> lines) {
  final dependencies = <String>{};
  var inDependencies = false;
  for (final line in lines) {
    if (RegExp(r'^dependencies:\s*$').hasMatch(line)) {
      inDependencies = true;
      continue;
    }
    if (!inDependencies) continue;
    if (line.isNotEmpty && !line.startsWith(' ')) break;
    final match = RegExp(r'^\s{2}([A-Za-z0-9_]+):').firstMatch(line);
    if (match != null) dependencies.add(match.group(1)!);
  }
  return dependencies;
}
