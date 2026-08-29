// Builds the solana_kit_wallet_ui example app for the documentation site.
//
// The example runs in deterministic demo mode (DEMO_WALLET=true), so the
// embedded demo needs no network access or keys. The output is copied into
// `docs/site/web/wallet-demo/` so Jaspr ships it as a static asset at
// `<basePath>demo/wallet-ui/`, matching the `--base-href` handed to Flutter.
//
// Usage:
//   dart run scripts/build_wallet_demo.dart --base-path=/solana_kit/

import 'dart:io';

const String _exampleDirectory = 'packages/solana_kit_wallet_ui/example';
const String _outputTarget = 'docs/site/web/wallet-demo';

Future<void> main(List<String> args) async {
  final basePath = _option(args, '--base-path') ?? '/';
  final demoBaseHref = composeDemoBaseHref(basePath);

  stdout.writeln('[wallet-demo] building example app (DEMO_WALLET mode)…');
  final pubGet = await _run([
    'pub',
    'get',
  ], _exampleDirectory);
  if (pubGet != 0) {
    exitCode = pubGet;
    return;
  }

  final buildWeb = await _run([
    'build',
    'web',
    '--quiet',
    '--pwa-strategy=none',
    '--dart-define=DEMO_WALLET=true',
    '--base-href=$demoBaseHref',
  ], _exampleDirectory);
  if (buildWeb != 0) {
    exitCode = buildWeb;
    return;
  }

  final source = Directory('$_exampleDirectory/build/web');
  final target = Directory(_outputTarget);
  if (target.existsSync()) {
    target.deleteSync(recursive: true);
  }
  _copyDirectory(source, target);
  stdout.writeln(
    '[wallet-demo] copied example build → $_outputTarget '
    '(base href $demoBaseHref)',
  );
}

/// Composes the Flutter web base href for the embedded demo directory.
String composeDemoBaseHref(String basePath) {
  var base = basePath.trim();
  if (base.isEmpty) base = '/';
  if (!base.startsWith('/')) base = '/$base';
  if (!base.endsWith('/')) base = '$base/';
  return '${base}wallet-demo/';
}

Future<int> _run(List<String> arguments, String workingDirectory) async {
  final process = await Process.start(
    'fvm',
    ['flutter', ...arguments],
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}

/// Resolves the [flag] occurrence followed by its value, if present.
String? _option(List<String> arguments, String flag) {
  final index = arguments.indexOf(flag);
  if (index < 0 || index + 1 >= arguments.length) return null;
  return arguments[index + 1];
}

void _copyDirectory(Directory source, Directory target) {
  for (final entity in source.listSync(recursive: true)) {
    final relative = entity.path.substring(source.path.length);
    final destination = '${target.path}$relative';
    if (entity is Directory) {
      Directory(destination).createSync(recursive: true);
    } else if (entity is File) {
      File(destination)
        ..createSync(recursive: true)
        ..writeAsBytesSync(entity.readAsBytesSync());
    }
  }
}
