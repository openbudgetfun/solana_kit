// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:io';

Future<void> main(List<String> args) async {
  final repoRoot = Directory.current;
  final siteDirectory = Directory('${repoRoot.path}/docs/site');
  final port = int.parse(Platform.environment['DOCS_SMOKE_PORT'] ?? '4173');
  final basePath = Platform.environment['DOCS_BASE_PATH'] ?? '/';

  var code = await _inherit('fvm', [
    'flutter',
    'pub',
    'get',
  ], workingDirectory: siteDirectory.path);
  if (code != 0) {
    exitCode = code;
    return;
  }

  code = await _inherit('fvm', [
    'dart',
    'run',
    'build_runner',
    'clean',
  ], workingDirectory: siteDirectory.path);
  if (code != 0) {
    exitCode = code;
    return;
  }

  code = await _inherit(
    'fvm',
    [
      'dart',
      'run',
      'jaspr_cli:jaspr',
      'build',
      '--dart-define=DOCS_BASE_PATH=$basePath',
    ],
    workingDirectory: siteDirectory.path,
    environment: {'PORT': Platform.environment['DOCS_BUILD_PORT'] ?? '9080'},
  );
  if (code != 0) {
    exitCode = code;
    return;
  }

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  try {
    final serverDone = _serveStatic(
      server,
      Directory('${siteDirectory.path}/build/jaspr'),
    );

    await _waitForServer(port);
    final home = await _fetch(port, '/');
    final quickStart = await _fetch(port, '/getting-started/quick-start/');

    if (!home.contains('Solana Kit')) {
      stderr.writeln(
        'Smoke check failed: homepage did not contain expected text.',
      );
      exitCode = 1;
      return;
    }
    if (!quickStart.contains('Quick Start')) {
      stderr.writeln(
        'Smoke check failed: quick-start page did not contain expected text.',
      );
      exitCode = 1;
      return;
    }

    stdout.writeln('Docs smoke test passed.');
    await server.close(force: true);
    await serverDone;
  } finally {
    await server.close(force: true);
  }
}

Future<void> _serveStatic(HttpServer server, Directory root) async {
  await for (final request in server) {
    final path = request.uri.path == '/' ? '/index.html' : request.uri.path;
    final file = File(
      '${root.path}${path.endsWith('/') ? '${path}index.html' : path}',
    );
    if (!file.existsSync()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      continue;
    }
    request.response.headers.contentType = _contentType(file.path);
    await request.response.addStream(file.openRead());
    await request.response.close();
  }
}

ContentType _contentType(String path) {
  if (path.endsWith('.html')) return ContentType.html;
  if (path.endsWith('.js')) return ContentType('application', 'javascript');
  if (path.endsWith('.css')) return ContentType('text', 'css');
  return ContentType.binary;
}

Future<void> _waitForServer(int port) async {
  for (var attempt = 0; attempt < 20; attempt += 1) {
    try {
      await _fetch(port, '/');
      return;
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }
}

Future<String> _fetch(int port, String path) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse('http://127.0.0.1:$port$path'),
    );
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('GET $path returned ${response.statusCode}');
    }
    return response.transform(const SystemEncoding().decoder).join();
  } finally {
    client.close(force: true);
  }
}

Future<int> _inherit(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  Map<String, String>? environment,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    environment: environment,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}
