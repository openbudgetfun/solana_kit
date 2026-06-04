import 'dart:io';

const _noReleasablePackages =
    'no releaseable packages were found in discovered changesets';
const _actionsCannotCreatePullRequests =
    'GitHub Actions is not permitted to create or approve pull requests';

Future<void> main(List<String> args) async {
  final result = await Process.run('monochange', [
    'run',
    'release-pr',
    ...args,
  ]);
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

  if (output.contains(_actionsCannotCreatePullRequests)) {
    stderr.writeln(
      'GitHub Actions cannot create pull requests in this repository; '
      'skipping release PR update. Enable the repository Actions setting or '
      'run monochange run release-pr manually.',
    );
    return;
  }

  exitCode = result.exitCode;
}
