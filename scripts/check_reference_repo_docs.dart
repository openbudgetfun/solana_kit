import 'dart:convert';
import 'dart:io';

/// Validates that `docs/agents/reference-repos.md` documents the same pinned
/// references as `config/reference-repos.json`.
///
/// Every configured repository must appear in the guide, and each documented
/// pin must mention the configured tag, a short commit prefix, or the checked
/// commit for branch-pinned clones. Run through `docs:check`.
void main(List<String> args) {
  if (args.isNotEmpty && args.first != '--check') {
    stderr.writeln(
      'Usage: dart run scripts/check_reference_repo_docs.dart [--check]',
    );
    exitCode = 2;
    return;
  }

  const configPath = 'config/reference-repos.json';
  const docsPath = 'docs/agents/reference-repos.md';

  final configFile = File(configPath);
  final docsFile = File(docsPath);
  if (!configFile.existsSync() || !docsFile.existsSync()) {
    stderr.writeln('Expected both $configPath and $docsPath to exist.');
    exitCode = 1;
    return;
  }

  final config =
      jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  final docLines = docsFile.readAsLinesSync();

  final errors = <String>[];
  for (final repo
      in (config['repos'] as List<dynamic>).cast<Map<String, dynamic>>()) {
    final path = repo['path'] as String;
    final documentedLine = docLines.firstWhere(
      (line) => line.contains(path),
      orElse: () => '',
    );

    if (documentedLine.isEmpty) {
      errors.add('$path: no documented reference in $docsPath');
      continue;
    }

    final expectedToken = _expectedToken(repo, documentedLine);
    if (expectedToken != null && !documentedLine.contains(expectedToken)) {
      errors.add(
        '$path: documented pin does not mention the configured '
        'reference `$expectedToken`',
      );
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('$docsPath drifted from $configPath:');
    for (final error in errors) {
      stderr.writeln('  - $error');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Reference repo documentation matches $configPath '
    '(${(config['repos'] as List<dynamic>).length} repos).',
  );
}

/// The pin fragment the guide must mention for [repo], or null when the
/// documented line makes no verifiable pin claim.
///
/// Tags must appear verbatim, commits as a short prefix, and branch pins are
/// only held to their checked commit when the guide states a
/// `last checked` revision; a branch name alone cannot pin a moving ref.
String? _expectedToken(Map<String, dynamic> repo, String documentedLine) {
  final ref = repo['ref'] as Map<String, dynamic>;
  switch (ref['type'] as String) {
    case 'tag':
      return ref['value'] as String;
    case 'commit':
      return (ref['value'] as String).substring(0, 8);
    case 'branch':
      if (!documentedLine.contains('last checked')) {
        return null;
      }
      final checkedCommit = repo['checkedCommit'] as String?;
      return checkedCommit?.substring(0, 8);
    default:
      stderr.writeln('${repo['path']}: unknown ref type ${ref['type']}');
      exitCode = 1;
      return null;
  }
}
