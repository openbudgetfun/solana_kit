import 'dart:io';

Future<void> main(List<String> args) async {
  final root = Directory.current;
  final testDirectories = <String>[];

  final packagesDirectory = Directory('packages');
  if (packagesDirectory.existsSync()) {
    final packageDirectories =
        packagesDirectory
            .listSync()
            .whereType<Directory>()
            .where(
              (directory) =>
                  File('${directory.path}/pubspec.yaml').existsSync(),
            )
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    for (final packageDirectory in packageDirectories) {
      final testDirectory = Directory('${packageDirectory.path}/test');
      if (!testDirectory.existsSync() || !_hasDartTests(testDirectory)) {
        continue;
      }

      final pubspec = File(
        '${packageDirectory.path}/pubspec.yaml',
      ).readAsStringSync();
      if (pubspec.contains(RegExp(r'^flutter:\s*$', multiLine: true))) {
        continue;
      }

      testDirectories.add(testDirectory.path);
    }
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

  if (testDirectories.isEmpty) {
    stderr.writeln('No Dart test directories were found.');
    exitCode = 1;
    return;
  }

  stdout
    ..writeln(
      'Running ${testDirectories.length} test directories in one Dart test process.',
    )
    ..writeln(
      'Skipping Flutter plugin packages; they are covered by dedicated checks.',
    );

  final stopwatch = Stopwatch()..start();
  final result = await Process.start(
    'fvm',
    [
      'dart',
      'test',
      '--exclude-tags',
      'integration',
      ...args,
      ...testDirectories,
    ],
    workingDirectory: root.path,
    mode: ProcessStartMode.inheritStdio,
  );

  final code = await result.exitCode;
  stopwatch.stop();
  stdout.writeln(
    'Workspace tests finished in ${_formatDuration(stopwatch.elapsed)}.',
  );
  exitCode = code;
}

bool _hasDartTests(Directory directory) {
  return directory
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .any((file) => file.path.endsWith('_test.dart'));
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:${seconds}s';
}
