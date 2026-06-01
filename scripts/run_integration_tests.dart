import 'dart:async';
import 'dart:io';

Future<void> main(List<String> args) async {
  await _ensurePackageConfig();

  final testDirectories = _discoverIntegrationTestDirectories();
  if (testDirectories.isEmpty) {
    stderr.writeln('No integration test directories were found.');
    exitCode = 1;
    return;
  }

  Process? surfpool;
  var startedSurfpool = false;
  final stopwatch = Stopwatch()..start();

  try {
    if (!await _isSurfpoolReady()) {
      stdout.writeln('Starting SurfPool...');
      surfpool = await _startSurfpool();
      startedSurfpool = true;
      await _waitForSurfpool();
    } else {
      stdout.writeln('Using existing SurfPool on localhost:8899.');
    }

    final testArgs = _withDefaultTestArgs(args);
    stdout.writeln(
      'Running ${testDirectories.length} integration test directories.',
    );
    final result = await Process.start(
      'fvm',
      [
        'dart',
        'test',
        '--tags',
        'integration',
        ...testArgs,
        ...testDirectories,
      ],
      mode: ProcessStartMode.inheritStdio,
    );

    exitCode = await result.exitCode;
  } finally {
    if (startedSurfpool) {
      stdout.writeln('Stopping SurfPool...');
      surfpool?.kill();
      await surfpool?.exitCode.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          surfpool?.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
      await Process.run('surfpool', ['stop']);
    }

    stopwatch.stop();
    stdout.writeln(
      'Integration tests finished in ${_formatDuration(stopwatch.elapsed)}.',
    );
  }
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

Future<Process> _startSurfpool() async {
  final args = Platform.isLinux
      ? ['start', '--daemon', '--ci']
      : ['start', '--ci', '--no-tui'];

  final process = await Process.start('surfpool', args);
  if (!Platform.isLinux) {
    process.stdout.listen(stdout.add);
    process.stderr.listen(stderr.add);
  } else {
    unawaited(process.stdout.drain<void>());
    unawaited(process.stderr.drain<void>());
  }
  return process;
}

Future<void> _waitForSurfpool() async {
  for (var attempt = 1; attempt <= 30; attempt += 1) {
    if (await _isSurfpoolReady()) {
      stdout.writeln('SurfPool is ready.');
      return;
    }
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  throw StateError('SurfPool failed to start within 30 seconds.');
}

Future<bool> _isSurfpoolReady() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 1);
  try {
    final request = await client.postUrl(Uri.parse('http://localhost:8899'));
    request.headers.contentType = ContentType.json;
    request.write('{"jsonrpc":"2.0","id":1,"method":"getHealth"}');
    final response = await request.close().timeout(const Duration(seconds: 1));
    await response.drain<void>();
    return response.statusCode >= 200 && response.statusCode < 500;
  } on Object {
    return false;
  } finally {
    client.close(force: true);
  }
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
