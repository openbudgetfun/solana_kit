// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:convert';
import 'dart:io';

import 'build_wallet_demo.dart' show composeDemoBaseHref;

/// A failed smoke check.
final class SmokeFailure implements Exception {
  /// Creates a failure with a human-readable [message].
  SmokeFailure(this.message);

  /// Why the smoke check failed.
  final String message;

  @override
  String toString() => message;
}

/// Fails the smoke test with a descriptive message.
Never _fail(String message) => throw SmokeFailure(message);

Future<void> main(List<String> args) async {
  final repoRoot = Directory.current;
  final siteDirectory = Directory('${repoRoot.path}/docs/site');
  final port = int.parse(Platform.environment['DOCS_SMOKE_PORT'] ?? '4173');
  final basePath = Platform.environment['DOCS_BASE_PATH'] ?? '/';
  final demoBaseHref = composeDemoBaseHref(basePath);

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

  code = await _inherit('dart', [
    'run',
    'scripts/build_wallet_demo.dart',
    '--base-path=$basePath',
  ], workingDirectory: repoRoot.path);
  if (code != 0) {
    exitCode = code;
    return;
  }

  // The demo must be built for the base path it will be served at. A build
  // that ignores the base path flag bakes a base href that 404s every asset
  // once the site is deployed under a subdirectory (for example
  // /solana_kit/ on GitHub Pages).
  try {
    _assertDemoBaseHref(repoRoot, basePath, demoBaseHref);
  } on SmokeFailure catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
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
      basePath,
    );

    await _waitForServer(port);

    try {
      // Every documented page must render with the shared site chrome.
      await _verifyContentPages(port, repoRoot);

      // The embedded wallet demo must serve its page and all referenced assets
      // under the deployment base path, and must be compiled in demo mode so
      // it renders deterministically without network access or keys.
      await _verifyWalletDemo(port, repoRoot, basePath, demoBaseHref);

      stdout.writeln('Docs smoke test passed.');
    } on SmokeFailure catch (error) {
      stderr.writeln(error.message);
      exitCode = 1;
    } finally {
      await server.close(force: true);
      await serverDone;
    }
  } finally {
    await server.close(force: true);
  }
}

void _assertDemoBaseHref(Directory repoRoot, String basePath, String expected) {
  final file = File('${repoRoot.path}/docs/site/web/wallet-demo/index.html');
  if (!file.existsSync()) {
    _fail('wallet demo build output is missing (${file.path}).');
  }
  final match = RegExp(
    r'<base\s+href="([^"]*)"',
  ).firstMatch(file.readAsStringSync());
  final actual = match?.group(1);
  if (actual != expected) {
    _fail(
      'wallet demo base href is "$actual" but the demo is served at '
      '"$expected" (basePath "$basePath"). Assets would 404 when deployed.',
    );
  }
  stdout.writeln('Wallet demo base href matches "$expected".');
}

/// Maps every Markdown file under [contentDirectoryPath] to its served route.
List<String> _contentRoutes(String contentDirectoryPath) {
  final directory = Directory(contentDirectoryPath);
  if (!directory.existsSync()) return const [];
  final routes = <String>[];
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.md')) continue;
    final relative = entity.path
        .substring(directory.path.length + 1)
        .replaceAll(r'\\', '/');
    if (relative == 'index.md') {
      routes.add('/');
    } else {
      routes.add('/${relative.substring(0, relative.length - '.md'.length)}/');
    }
  }
  routes.sort();
  return routes;
}

Future<void> _verifyContentPages(int port, Directory repoRoot) async {
  final routes = _contentRoutes('${repoRoot.path}/docs/site/content');
  if (routes.isEmpty) {
    _fail('no content pages were found under docs/site/content.');
  }
  for (final route in routes) {
    final html = await _fetchText(port, route);
    if (!html.contains('</html>')) {
      _fail('page $route did not render a complete HTML document.');
    }
    if (!html.contains('Solana Kit')) {
      _fail('page $route is missing the shared site chrome.');
    }
  }
  stdout.writeln('Verified ${routes.length} content pages render.');
}

/// Resolves asset URLs the way a browser would: relative to the page's base
/// href, absolute URLs fetched as-is.
Future<void> _verifyWalletDemo(
  int port,
  Directory repoRoot,
  String basePath,
  String demoBaseHref,
) async {
  final demoPagePath = _demoPath(basePath);
  final demoHtml = await _fetchText(port, demoPagePath);
  if (!demoHtml.contains('flutter_bootstrap.js')) {
    _fail('wallet demo page did not load.');
  }

  final assets = <String>{};
  final assetPattern = RegExp('(?:src|href)="([^"]+)"');
  for (final match in assetPattern.allMatches(demoHtml)) {
    final raw = match.group(1)!;
    if (raw.startsWith('data:') || raw.startsWith('http')) continue;
    assets.add(raw.startsWith('/') ? raw : '$demoBaseHref$raw');
  }
  // main.dart.js is loaded dynamically by flutter_bootstrap.js, so it never
  // appears in index.html; fetch it explicitly.
  assets.add('${demoBaseHref}main.dart.js');

  for (final url in assets) {
    final response = await _get(port, url);
    if (response.statusCode != HttpStatus.ok) {
      _fail('wallet demo asset $url returned ${response.statusCode}.');
    }
    if (response.bytes.isEmpty) {
      _fail('wallet demo asset $url is empty.');
    }
  }

  final mainDartJs = utf8.decode(
    (await _get(port, '${demoBaseHref}main.dart.js')).bytes,
    allowMalformed: true,
  );
  // DEMO_WALLET=true must be compiled into the deployed bundle so the demo
  // renders the deterministic demo wallet instead of probing real wallets.
  if (!mainDartJs.contains('Surfpool demo wallet')) {
    _fail(
      'wallet demo bundle was not built with --dart-define=DEMO_WALLET=true.',
    );
  }

  stdout.writeln('Wallet demo verified at "$demoPagePath".');
}

Future<void> _serveStatic(
  HttpServer server,
  Directory root,
  String basePath,
) async {
  await for (final request in server) {
    try {
      final path = _stripBasePath(request.uri.path, basePath);
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
    } on Object catch (error) {
      stderr.writeln('Static server request failed: $error');
      try {
        await request.response.close();
      } on Object {
        // The client may already have closed the connection.
      }
    }
  }
}

/// Rewrites a served URL into a path under the static file root, mirroring how
/// GitHub Pages serves the site under the deployment base path.
String _stripBasePath(String path, String basePath) {
  if (basePath == '/') return path;
  final normalized = basePath.endsWith('/') ? basePath : '$basePath/';
  if (path == normalized || path == '${normalized}index.html') {
    return '/index.html';
  }
  if (path.startsWith(normalized)) {
    return path.substring(normalized.length - 1);
  }
  return path;
}

String _demoPath(String basePath) {
  final normalized = basePath.endsWith('/') ? basePath : '$basePath/';
  return '${normalized}wallet-demo/index.html';
}

ContentType _contentType(String path) {
  if (path.endsWith('.html')) return ContentType.html;
  if (path.endsWith('.js')) return ContentType('application', 'javascript');
  if (path.endsWith('.css')) return ContentType('text', 'css');
  return ContentType.binary;
}

Future<void> _waitForServer(int port) async {
  Object? lastError;
  for (var attempt = 0; attempt < 20; attempt += 1) {
    try {
      await _fetchText(port, '/');
      return;
    } catch (error) {
      lastError = error;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  throw StateError('Docs smoke server did not respond: $lastError');
}

Future<({int statusCode, List<int> bytes})> _get(int port, String path) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse('http://127.0.0.1:$port$path'),
    );
    final response = await request.close();
    final bytes = await response.fold<List<int>>(
      <int>[],
      (accumulator, chunk) => accumulator..addAll(chunk),
    );
    return (statusCode: response.statusCode, bytes: bytes);
  } finally {
    client.close();
  }
}

Future<String> _fetchText(int port, String path) async {
  final response = await _get(port, path);
  if (response.statusCode != HttpStatus.ok) {
    throw SmokeFailure('GET $path returned ${response.statusCode}');
  }
  return utf8.decode(response.bytes, allowMalformed: true);
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
