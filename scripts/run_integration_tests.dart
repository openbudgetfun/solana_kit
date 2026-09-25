import 'dart:io';

Future<void> main(List<String> args) async {
  await _ensurePackageConfig();

  final testDirectories = _discoverIntegrationTestDirectories();
  if (testDirectories.isEmpty) {
    stderr.writeln('No integration test directories were found.');
    exitCode = 1;
    return;
  }

  final stopwatch = Stopwatch()..start();

  // Each test file starts its own Surfpool instance via the Surfpool SDK
  // (auto-allocated ports), so no shared instance needs to be launched here.
  final testArgs = _withDefaultTestArgs(args);
  stdout.writeln(
    'Running ${testDirectories.length} integration test directories.',
  );
  final result = await Process.start('fvm', [
    'dart',
    'test',
    '--tags',
    'integration',
    ...testArgs,
    ...testDirectories,
  ], mode: ProcessStartMode.inheritStdio);

  exitCode = await result.exitCode;

  stopwatch.stop();
  stdout.writeln(
    'Integration tests finished in ${_formatDuration(stopwatch.elapsed)}.',
  );
}

List<String> _discoverIntegrationTestDirectories() {
  final packagesDirectory = Directory('packages');
  if (!packagesDirectory.existsSync()) {
    return const [];
  }

  final testDirectories = <String>[];
  final packageDirectories =
      packagesDirectory
          .listSync()
          .whereType<Directory>()
          .where(
            (directory) => File('${directory.path}/pubspec.yaml').existsSync(),
          )
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  for (final packageDirectory in packageDirectories) {
    final integrationDirectory = Directory(
      '${packageDirectory.path}/test/integration',
    );
    if (!integrationDirectory.existsSync() ||
        !_hasDartTests(integrationDirectory)) {
      continue;
    }
    testDirectories.add(integrationDirectory.path);
  }

  return testDirectories;
}

List<String> _withDefaultTestArgs(List<String> args) {
  return [
    if (!_hasOption(args, 'reporter')) ...['--reporter', 'compact'],
    if (!_hasConcurrencyOption(args)) ...['-j', '4'],
    ...args,
  ];
}

bool _hasOption(List<String> args, String option) {
  return args.any((arg) => arg == '--$option' || arg.startsWith('--$option='));
}

bool _hasConcurrencyOption(List<String> args) {
  return args.any(
    (arg) =>
        arg == '-j' ||
        arg == '--concurrency' ||
        arg.startsWith('--concurrency='),
  );
}

bool _hasDartTests(Directory directory) {
  return directory
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .any((file) => file.path.endsWith('_test.dart'));
}

Future<void> _ensurePackageConfig() async {
  if (File('.dart_tool/package_config.json').existsSync()) {
    return;
  }

  stdout.writeln(
    'Resolving workspace dependencies with `fvm flutter pub get`...',
  );
  final result = await Process.start('fvm', [
    'flutter',
    'pub',
    'get',
  ], mode: ProcessStartMode.inheritStdio);
  final code = await result.exitCode;
  if (code != 0) {
    exitCode = code;
    throw const ProcessException('fvm', ['flutter', 'pub', 'get']);
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:${seconds}s';
}
