import 'dart:io';

const _noReleasablePackages =
    'no releaseable packages were found in discovered changesets';

Future<void> main(List<String> args) async {
  final result = await Process.run('mc', ['release-pr', ...args]);
  final stdoutText = result.stdout.toString();
  final stderrText = result.stderr.toString();

  stdout.write(stdoutText);
  stderr.write(stderrText);

  if (result.exitCode == 0) {
    return;
  }

  final output = '$stdoutText\n$stderrText';
  if (output.contains(_noReleasablePackages)) {
    stderr.writeln(
      'No releasable monochange entries were found; skipping release PR update.',
    );
    return;
  }

  exitCode = result.exitCode;
}
