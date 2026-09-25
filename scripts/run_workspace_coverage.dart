import 'dart:io';

Future<void> main(List<String> args) async {
  await _ensurePackageConfig();

  final testDirectories = _discoverPackageTestDirectories();
  final flutterPackages = _discoverFlutterPackages();
  if (testDirectories.isEmpty && flutterPackages.isEmpty) {
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
      'Running Flutter coverage for ${flutterPackages.length} packages; '
      'native plugins remain covered by dedicated checks.',
    );

  final stopwatch = Stopwatch()..start();
  var code = 0;
  if (testDirectories.isNotEmpty) {
    final result = await Process.start('dart', [
      'run',
      'coverage:test_with_coverage',
      '--',
      '--exclude-tags',
      'integration',
      ...testArgs,
      ...testDirectories,
    ], mode: ProcessStartMode.inheritStdio);
    code = await result.exitCode;
  }
  if (code == 0) {
    code = await _runFlutterCoverage(flutterPackages, testArgs);
  }
  stopwatch.stop();
  stdout.writeln(
    'Workspace coverage finished in ${_formatDuration(stopwatch.elapsed)}.',
  );
  exitCode = code;
}

Future<int> _runFlutterCoverage(
  List<Directory> packages,
  List<String> testArgs,
) async {
  if (packages.isEmpty) return 0;
  final coverageDirectory = Directory('coverage')..createSync(recursive: true);
  final workspaceCoverage = File('${coverageDirectory.path}/lcov.info');
  for (final package in packages) {
    final name = package.uri.pathSegments.where((part) => part.isNotEmpty).last;
    final packageCoverage = File(
      '${coverageDirectory.absolute.path}/$name.lcov',
    );
    stdout.writeln('Running Flutter coverage for $name.');
    final result = await Process.start(
      'fvm',
      [
        'flutter',
        'test',
        '--coverage',
        '--coverage-path=${packageCoverage.path}',
        '--exclude-tags',
        'integration',
        ...testArgs,
        'test',
      ],
      workingDirectory: package.path,
      mode: ProcessStartMode.inheritStdio,
    );
    final code = await result.exitCode;
    if (code != 0) return code;
    _appendPackageCoverage(
      package: package,
      packageCoverage: packageCoverage,
      workspaceCoverage: workspaceCoverage,
    );
  }
  return 0;
}

void _appendPackageCoverage({
  required Directory package,
  required File packageCoverage,
  required File workspaceCoverage,
}) {
  final packagePath = package.path.replaceAll(r'\', '/');
  final absolutePackagePath = package.absolute.path.replaceAll(r'\', '/');
  final records = packageCoverage.readAsStringSync().split('end_of_record');
  final output = StringBuffer();
  for (final record in records) {
    final trimmed = record.trim();
    if (trimmed.isEmpty) continue;
    final lines = trimmed.split('\n');
    final sourceIndex = lines.indexWhere((line) => line.startsWith('SF:'));
    if (sourceIndex < 0) continue;
    final source = lines[sourceIndex].substring(3).replaceAll(r'\', '/');
    final normalized = switch (source) {
      final value when value.startsWith('$absolutePackagePath/lib/') =>
        '$packagePath/${value.substring(absolutePackagePath.length + 1)}',
      final value when value.startsWith('$packagePath/lib/') => value,
      final value when value.startsWith('lib/') => '$packagePath/$value',
      _ => null,
    };
    if (normalized == null) continue;
    lines[sourceIndex] = 'SF:$normalized';
    output
      ..writeln(lines.join('\n'))
      ..writeln('end_of_record');
  }
  workspaceCoverage.writeAsStringSync(output.toString(), mode: FileMode.append);
}

List<String> _discoverPackageTestDirectories() {
  final testDirectories = <String>[];
  for (final packageDirectory in _packageDirectories()) {
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

List<Directory> _discoverFlutterPackages() => _packageDirectories().where((
  package,
) {
  final testDirectory = Directory('${package.path}/test');
  return _isFlutterPackage(package) &&
      !_isFlutterPlugin(package) &&
      testDirectory.existsSync() &&
      _hasDartTests(testDirectory);
}).toList();

List<Directory> _packageDirectories() {
  final packagesDirectory = Directory('packages');
  if (!packagesDirectory.existsSync()) return const [];
  return packagesDirectory
      .listSync()
      .whereType<Directory>()
      .where((directory) => File('${directory.path}/pubspec.yaml').existsSync())
      .toList()
    ..sort((left, right) => left.path.compareTo(right.path));
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
  return pubspec.contains(RegExp(r'^  flutter:\s*$', multiLine: true));
}

bool _isFlutterPlugin(Directory packageDirectory) {
  final pubspec = File(
    '${packageDirectory.path}/pubspec.yaml',
  ).readAsStringSync();
  return pubspec.contains(RegExp(r'^  plugin:\s*$', multiLine: true));
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
