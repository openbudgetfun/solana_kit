import 'dart:io';

Future<void> main() async {
  final rootResult = await Process.run('git', ['rev-parse', '--show-toplevel']);
  if (rootResult.exitCode != 0) {
    stderr.write(rootResult.stderr);
    exitCode = rootResult.exitCode;
    return;
  }

  final rootDirectory = Directory(rootResult.stdout.toString().trim());
  final pluginDirectory = Directory(
    '${rootDirectory.path}/packages/solana_kit_mobile_wallet_adapter',
  );
  if (!pluginDirectory.existsSync()) {
    stderr.writeln('Expected plugin path not found: ${pluginDirectory.path}');
    exitCode = 1;
    return;
  }

  final tempParent = await Directory.systemTemp.createTemp(
    'mwa_compile_check_',
  );
  try {
    final tempApp = Directory('${tempParent.path}/mwa_compile_check');

    stdout.writeln(
      'Creating temporary Flutter Android app for compile verification...',
    );
    var code = await _inherit('flutter', [
      'create',
      '--platforms=android',
      '--project-name',
      'mwa_compile_check',
      '--org',
      'com.example',
      tempApp.path,
    ]);
    if (code != 0) {
      exitCode = code;
      return;
    }

    stdout.writeln('Adding local plugin dependency and workspace overrides');
    _rewritePubspec(
      rootDirectory,
      pluginDirectory,
      File('${tempApp.path}/pubspec.yaml'),
    );

    code = await _inherit('flutter', [
      'pub',
      'get',
    ], workingDirectory: tempApp.path);
    if (code != 0) {
      exitCode = code;
      return;
    }

    File('${tempApp.path}/lib/main.dart').writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart';

void main() {
  // Reference exported plugin API to ensure integration survives tree-shaking.
  final _ = MwaClientHostApi;
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('MWA compile check')))));
}
''');

    stdout.writeln(
      'Building debug APK to validate Android native compilation...',
    );
    code = await _inherit('flutter', [
      'build',
      'apk',
      '--debug',
      '--target-platform',
      'android-arm64',
    ], workingDirectory: tempApp.path);
    if (code != 0) {
      exitCode = code;
      return;
    }

    stdout.writeln('Android compile verification passed.');
  } finally {
    if (tempParent.existsSync()) {
      tempParent.deleteSync(recursive: true);
    }
  }
}

void _rewritePubspec(
  Directory rootDirectory,
  Directory pluginDirectory,
  File pubspec,
) {
  final overrides = <(String, String)>[];
  final packagesDirectory = Directory('${rootDirectory.path}/packages');
  for (final entity in packagesDirectory.listSync().whereType<Directory>()) {
    final packagePubspec = File('${entity.path}/pubspec.yaml');
    if (!packagePubspec.existsSync()) continue;
    final name = _readPackageName(packagePubspec);
    if (name != null && name.startsWith('solana_kit_')) {
      overrides.add((name, entity.path));
    }
  }
  overrides.sort((a, b) => a.$1.compareTo(b.$1));

  final lines = pubspec.readAsLinesSync();
  final output = <String>[];
  var insertedDependency = false;
  for (final line in lines) {
    output.add(line);
    if (line.trim() == 'dependencies:' && !insertedDependency) {
      output
        ..add('  solana_kit_mobile_wallet_adapter:')
        ..add('    path: ${pluginDirectory.path}');
      insertedDependency = true;
    }
  }

  if (!insertedDependency) {
    throw StateError(
      'Could not find dependencies section in generated pubspec.yaml',
    );
  }

  output
    ..add('')
    ..add('dependency_overrides:');
  for (final (name, path) in overrides) {
    output
      ..add('  $name:')
      ..add('    path: $path');
  }

  pubspec.writeAsStringSync('${output.join('\n')}\n');
}

String? _readPackageName(File pubspec) {
  for (final line in pubspec.readAsLinesSync()) {
    final match = RegExp(r'^name:\s*([^\s#]+)').firstMatch(line);
    if (match != null) return match.group(1);
  }
  return null;
}

Future<int> _inherit(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}
