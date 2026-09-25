import 'dart:io';

Future<void> main(List<String> args) async {
  await _ensurePackageConfig();

  final root = Directory.current;
  final testDirectories = <String>[];
  final flutterPackages = <Directory>[];

  final packagesDirectory = Directory('packages');
  final packageDirectories = <Directory>[];
  if (packagesDirectory.existsSync()) {
    packageDirectories
      ..addAll(
        packagesDirectory.listSync().whereType<Directory>().where(
          (directory) => File('${directory.path}/pubspec.yaml').existsSync(),
        ),
      )
      ..sort((left, right) => left.path.compareTo(right.path));
  }

  for (final packageDirectory in packageDirectories) {
    final testDirectory = Directory('${packageDirectory.path}/test');
    if (!testDirectory.existsSync() || !_hasDartTests(testDirectory)) {
      continue;
    }

    final pubspec = File(
      '${packageDirectory.path}/pubspec.yaml',
    ).readAsStringSync();
    final isFlutter = pubspec.contains(
      RegExp(r'^  flutter:\s*$', multiLine: true),
    );
    if (isFlutter) {
      if (!pubspec.contains(RegExp(r'^  plugin:\s*$', multiLine: true))) {
        flutterPackages.add(packageDirectory);
      }
      continue;
    }

    testDirectories.add(testDirectory.path);
  }
  final generatedTestDirectory = Directory(
    'packages/codama-renderers-dart/test-generated/test',
  );
  if (generatedTestDirectory.existsSync() &&
      _hasDartTests(generatedTestDirectory) &&
      !testDirectories.contains(generatedTestDirectory.path)) {
    testDirectories.add(generatedTestDirectory.path);
  }

  final rootTestDirectory = Directory('test');
  if (rootTestDirectory.existsSync() && _hasDartTests(rootTestDirectory)) {
    testDirectories.add(rootTestDirectory.path);
  }

  // Example apps nest one level below their host package and run as Flutter
  // packages so their widget tests execute alongside the package tests.
  for (final packageDirectory in packageDirectories) {
    final exampleDirectory = Directory('${packageDirectory.path}/example');
    if (!File('${exampleDirectory.path}/pubspec.yaml').existsSync()) {
      continue;
    }
    final exampleTestDirectory = Directory('${exampleDirectory.path}/test');
    if (!exampleTestDirectory.existsSync() ||
        !_hasDartTests(exampleTestDirectory)) {
      continue;
    }
    if (!flutterPackages.any(
      (package) => package.path == exampleDirectory.path,
    )) {
      flutterPackages.add(exampleDirectory);
    }
  }

  if (testDirectories.isEmpty && flutterPackages.isEmpty) {
    stderr.writeln('No test directories were found.');
    exitCode = 1;
    return;
  }

  stdout
    ..writeln(
      'Running ${testDirectories.length} test directories in one Dart test process.',
    )
    ..writeln(
      'Running ${flutterPackages.length} Flutter packages separately; '
      'native plugins remain covered by dedicated checks.',
    );

  final testArgs = _withDefaultTestArgs(args);
  final stopwatch = Stopwatch()..start();
  var code = 0;
  if (testDirectories.isNotEmpty) {
    final result = await Process.start(
      'fvm',
      [
        'dart',
        'test',
        '--exclude-tags',
        'integration',
        ...testArgs,
        ...testDirectories,
      ],
      workingDirectory: root.path,
      mode: ProcessStartMode.inheritStdio,
    );
    code = await result.exitCode;
  }
  for (final package in flutterPackages) {
    if (code != 0) break;
    stdout.writeln('Running Flutter tests for ${package.path}.');
    final result = await Process.start(
      'fvm',
      [
        'flutter',
        'test',
        '--exclude-tags',
        'integration',
        ...testArgs,
        'test',
      ],
      workingDirectory: package.path,
      mode: ProcessStartMode.inheritStdio,
    );
    code = await result.exitCode;
  }
  stopwatch.stop();
  stdout.writeln(
    'Workspace tests finished in ${_formatDuration(stopwatch.elapsed)}.',
  );
  exitCode = code;
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
