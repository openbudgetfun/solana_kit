// ignore_for_file: cascade_invocations

import 'dart:io';

Future<void> main() async {
  var baseSha = Platform.environment['BASE_SHA'] ?? '';
  var headSha = Platform.environment['HEAD_SHA'] ?? '';

  if (baseSha.isEmpty || headSha.isEmpty) {
    final originMain = await _run('git', [
      'rev-parse',
      '--verify',
      '--quiet',
      'origin/main',
    ]);
    if (originMain.exitCode != 0) {
      stderr.writeln(
        'BASE_SHA/HEAD_SHA are required when origin/main is unavailable.',
      );
      exitCode = 2;
      return;
    }

    final mergeBase = await _run('git', ['merge-base', 'origin/main', 'HEAD']);
    if (mergeBase.exitCode != 0) {
      stderr.write(mergeBase.stderr);
      exitCode = mergeBase.exitCode;
      return;
    }
    baseSha = mergeBase.stdout.trim();
    headSha = 'HEAD';
  }

  final diff = await _run('git', [
    'diff',
    '--name-only',
    '$baseSha...$headSha',
  ]);
  if (diff.exitCode != 0) {
    stderr.write(diff.stderr);
    exitCode = diff.exitCode;
    return;
  }

  final changedFiles = diff.stdout
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  if (changedFiles.isEmpty) {
    stdout.writeln('No changed files detected.');
    return;
  }

  final changesetChanges = changedFiles
      .where((path) => path.startsWith('.changeset/') && path.endsWith('.md'))
      .toList();

  if (changesetChanges.isNotEmpty) {
    stdout.writeln('Validating changed changeset frontmatter.');
    final validation = await _run('dart', [
      'run',
      'scripts/check_changeset_frontmatter.dart',
      ...changesetChanges,
    ], inherit: true);
    if (validation.exitCode != 0) {
      exitCode = validation.exitCode;
      return;
    }
  }

  final packageChanges = changedFiles
      .where((path) => path.startsWith('packages/'))
      .toList();
  if (packageChanges.isEmpty) {
    stdout.writeln('No package changes detected; changeset not required.');
    return;
  }

  if (changesetChanges.isNotEmpty) {
    stdout.writeln('Changeset requirement satisfied.');
    return;
  }

  stderr.writeln(
    'Package changes were detected without a changeset file under .changeset/*.md.',
  );
  stderr.writeln(
    'Run `monochange run document` to create a properly formatted changeset, then commit the file.',
  );
  stderr.writeln('Changed package files:');
  for (final path in packageChanges) {
    stderr.writeln(path);
  }
  exitCode = 1;
}

Future<({int exitCode, String stdout, String stderr})> _run(
  String executable,
  List<String> arguments, {
  bool inherit = false,
}) async {
  if (inherit) {
    final process = await Process.start(
      executable,
      arguments,
      mode: ProcessStartMode.inheritStdio,
    );
    return (exitCode: await process.exitCode, stdout: '', stderr: '');
  }

  final result = await Process.run(executable, arguments);
  return (
    exitCode: result.exitCode,
    stdout: result.stdout.toString(),
    stderr: result.stderr.toString(),
  );
}
