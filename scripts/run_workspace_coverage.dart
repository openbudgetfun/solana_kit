import 'dart:io';

Future<void> main(List<String> args) async {
  await _ensurePackageConfig();

  final testDirectories = _discoverPackageTestDirectories();
  if (testDirectories.isEmpty) {
    stderr.writeln('No package test directories were found.');
    exitCode = 1;
    return;
  }

  final testArgs = _withDefaultTestArgs(args);

  stdout
    ..writeln(
      'Running coverage for ${testDirectories.length} package test directories.',
    )
    ..writeln(
      'Skipping Flutter plugin packages; they are covered by dedicated checks.',
    );

  final stopwatch = Stopwatch()..start();
  final result = await Process.start(
    'dart',
    [
      'run',
      'coverage:test_with_coverage',
      '--',
      '--exclude-tags',
      'integration',
      ...testArgs,
      ...testDirectories,
    ],
    mode: ProcessStartMode.inheritStdio,
  );

  final code = await result.exitCode;
  stopwatch.stop();
  stdout.writeln(
    'Workspace coverage finished in ${_formatDuration(stopwatch.elapsed)}.',
  );
  exitCode = code;
}

List<String> _discoverPackageTestDirectories() {
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
    final testDirectory = Directory('${packageDirectory.path}/test');
    if (!testDirectory.existsSync() || !_hasDartTests(testDirectory)) {
      continue;
    }

    if (_isFlutterPackage(packageDirectory)) {
      continue;
    }

    testDirectories.add(testDirectory.path);
  }

  return testDirectories;
}

List<String> _withDefaultTestArgs(List<String> args) {
  return [
    if (!_hasOption(args, 'reporter')) ...['--reporter', 'compact'],
    if (!_hasConcurrencyOption(args)) ...[
      '-j',
      _defaultConcurrency().toString(),
    ],
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

int _defaultConcurrency() {
  final processors = Platform.numberOfProcessors;
  if (processors < 1) {
    return 1;
  }
  return processors > 12 ? 12 : processors;
}

bool _isFlutterPackage(Directory packageDirectory) {
  final pubspec = File(
    '${packageDirectory.path}/pubspec.yaml',
  ).readAsStringSync();
  return pubspec.contains(RegExp(r'^flutter:\s*$', multiLine: true));
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
  final result = await Process.start(
    'fvm',
    ['flutter', 'pub', 'get'],
    mode: ProcessStartMode.inheritStdio,
  );
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
