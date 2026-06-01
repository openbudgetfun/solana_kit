import 'dart:convert';
import 'dart:io';

const _versionPattern = r'[0-9]+\.[0-9]+\.[0-9]+';

Future<void> main(List<String> args) async {
  var code = await _inherit('dart', [
    'run',
    'scripts/check_upstream_compatibility.dart',
    ...args,
  ]);
  if (code != 0) {
    exitCode = code;
    return;
  }

  final trackedVersion = RegExp(
    'Latest supported `@solana/kit` version: `($_versionPattern)`',
  ).firstMatch(File('readme.md').readAsStringSync())?.group(1);
  if (trackedVersion == null) {
    stderr.writeln(
      'Failed to determine the tracked @solana/kit version from readme.md.',
    );
    exitCode = 1;
    return;
  }

  final cacheDirectory = Directory('.dart_tool/upstream-kit-node');
  final fixturesDirectory = Directory('.dart_tool/upstream-parity')
    ..createSync(recursive: true);
  final fixturesJson = File('${fixturesDirectory.path}/fixtures.json');
  final installedPackageJson = File(
    '${cacheDirectory.path}/node_modules/@solana/kit/package.json',
  );

  var installedVersion = '';
  if (installedPackageJson.existsSync()) {
    final json =
        jsonDecode(installedPackageJson.readAsStringSync())
            as Map<String, Object?>;
    installedVersion = json['version'] as String? ?? '';
  }

  if (installedVersion != trackedVersion) {
    stdout.writeln(
      'Preparing upstream @solana/kit@$trackedVersion runtime fixture environment...',
    );
    if (cacheDirectory.existsSync()) {
      cacheDirectory.deleteSync(recursive: true);
    }
    cacheDirectory.createSync(recursive: true);
    File('${cacheDirectory.path}/package.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'private': true,
        'type': 'module',
        'dependencies': {'@solana/kit': trackedVersion},
      }),
    );

    code = await _inherit('npm', [
      'install',
      '--ignore-scripts',
      '--no-audit',
      '--no-fund',
      '--silent',
    ], workingDirectory: cacheDirectory.path);
    if (code != 0) {
      exitCode = code;
      return;
    }
  }

  final node = await Process.run(
    'node',
    ['scripts/generate-upstream-parity-fixtures.mjs'],
    environment: {
      'UPSTREAM_KIT_NODE_MODULES': '${cacheDirectory.path}/node_modules',
    },
  );
  stderr.write(node.stderr);
  if (node.exitCode != 0) {
    stdout.write(node.stdout);
    exitCode = node.exitCode;
    return;
  }
  fixturesJson.writeAsStringSync(node.stdout.toString());

  stdout.writeln('Generated upstream parity fixtures at ${fixturesJson.path}');
  code = await _inherit(
    'dart',
    ['test', 'packages/solana_kit/test/upstream_parity_test.dart'],
    environment: {'UPSTREAM_PARITY_FIXTURES_JSON': fixturesJson.path},
  );
  if (code != 0) {
    exitCode = code;
    return;
  }

  stdout.writeln(
    'Upstream parity checks passed against @solana/kit@$trackedVersion.',
  );
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
