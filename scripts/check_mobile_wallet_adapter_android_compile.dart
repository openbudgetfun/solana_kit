import 'dart:io';

/// A workspace member's name, directory and declared dependencies.
class WorkspacePackage {
  /// Creates a workspace package description.
  const WorkspacePackage({
    required this.name,
    required this.directory,
    required this.dependencies,
  });

  /// The package name declared in its `pubspec.yaml`.
  final String name;

  /// Absolute path to the directory holding the package.
  final String directory;

  /// Names declared under the package's `dependencies:` section.
  ///
  /// Dev dependencies are deliberately excluded. Pub never resolves a
  /// dependency's dev dependencies, so they are absent from an application's
  /// build graph and pinning them would only drag unrelated packages in.
  final List<String> dependencies;
}

/// Returns every workspace package the dependency graph rooted at [root] reaches.
///
/// Only packages something in [root]'s graph actually requires need a local
/// override. Listing unrelated members is not harmless: a `dependency_overrides`
/// path entry makes pub treat that package as though the root declared it, so an
/// unrelated member with an unsatisfiable constraint fails the whole resolution.
List<WorkspacePackage> dependencyClosure(
  List<WorkspacePackage> packages,
  String root,
) {
  final byName = {for (final package in packages) package.name: package};
  final reached = <String, WorkspacePackage>{};
  final pending = <String>[root];
  while (pending.isNotEmpty) {
    final package = byName[pending.removeLast()];
    if (package == null) continue;
    for (final dependency in package.dependencies) {
      final resolved = byName[dependency];
      if (resolved == null || reached.containsKey(dependency)) continue;
      reached[dependency] = resolved;
      pending.add(dependency);
    }
  }
  return reached.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

/// Reads the workspace members declared in [rootDirectory]'s `pubspec.yaml`.
///
/// The workspace list is the source of truth rather than a directory scan:
/// `packages/` also holds directories that are not workspace members.
List<WorkspacePackage> readWorkspacePackages(Directory rootDirectory) {
  final rootPubspec = File('${rootDirectory.path}/pubspec.yaml');
  final packages = <WorkspacePackage>[];
  for (final member in _readWorkspaceMembers(rootPubspec)) {
    final directory = Directory('${rootDirectory.path}/$member');
    final pubspec = File('${directory.path}/pubspec.yaml');
    if (!pubspec.existsSync()) {
      throw StateError(
        'Workspace member "$member" has no pubspec.yaml at ${pubspec.path}',
      );
    }
    final name = _readPackageName(pubspec);
    if (name == null) {
      throw StateError('Could not read package name from ${pubspec.path}');
    }
    packages.add(
      WorkspacePackage(
        name: name,
        directory: directory.path,
        dependencies: _readDependencies(pubspec),
      ),
    );
  }
  return packages;
}

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

/// Rewrites the generated app's pubspec to depend on the plugin by path.
///
/// Every workspace package the plugin's own dependency graph reaches is pinned
/// to its local path so the check compiles against working-tree sources instead
/// of whatever is published. Pinning reachable members only keeps the temp app's
/// resolution graph as small as the plugin's real one.
void _rewritePubspec(
  Directory rootDirectory,
  Directory pluginDirectory,
  File pubspec,
) {
  final pluginPubspec = File('${pluginDirectory.path}/pubspec.yaml');
  final pluginName = _readPackageName(pluginPubspec);
  if (pluginName == null) {
    throw StateError('Could not read package name from ${pluginPubspec.path}');
  }
  final overrides = dependencyClosure(
    readWorkspacePackages(rootDirectory),
    pluginName,
  );

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
  for (final package in overrides) {
    output
      ..add('  ${package.name}:')
      ..add('    path: ${package.directory}');
  }

  pubspec.writeAsStringSync('${output.join('\n')}\n');
}

/// Reads the `workspace:` entries from the root pubspec.
List<String> _readWorkspaceMembers(File pubspec) {
  final members = <String>[];
  var inWorkspace = false;
  for (final line in pubspec.readAsLinesSync()) {
    if (line.startsWith('workspace:')) {
      inWorkspace = true;
      continue;
    }
    if (!inWorkspace) continue;
    final match = RegExp(r'^  - (.+)$').firstMatch(line);
    if (match == null) {
      // A non-list top-level key ends the workspace section.
      if (line.isNotEmpty && !line.startsWith(' ')) break;
      continue;
    }
    members.add(match.group(1)!.trim());
  }
  return members;
}

/// Reads the names declared under a pubspec's `dependencies:` section.
List<String> _readDependencies(File pubspec) {
  final dependencies = <String>[];
  var inDependencies = false;
  for (final line in pubspec.readAsLinesSync()) {
    if (line.startsWith('dependencies:')) {
      inDependencies = true;
      continue;
    }
    if (line.isNotEmpty && !line.startsWith(' ')) {
      inDependencies = false;
      continue;
    }
    if (!inDependencies) continue;
    final match = RegExp('^  ([A-Za-z0-9_]+):').firstMatch(line);
    if (match != null) dependencies.add(match.group(1)!);
  }
  return dependencies;
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
