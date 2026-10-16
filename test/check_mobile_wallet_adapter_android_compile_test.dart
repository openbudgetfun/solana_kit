import 'dart:io';

import 'package:test/test.dart';

import '../scripts/check_mobile_wallet_adapter_android_compile.dart';

void main() {
  group('dependencyClosure', () {
    test('includes transitive workspace dependencies', () {
      final closure = dependencyClosure([
        _package('plugin', dependencies: ['protocol']),
        _package('protocol', dependencies: ['addresses']),
        _package('addresses'),
      ], 'plugin');

      expect(closure.map((package) => package.name), ['addresses', 'protocol']);
    });

    test('excludes the root package itself', () {
      final closure = dependencyClosure([
        _package('plugin', dependencies: ['protocol']),
        _package('protocol'),
      ], 'plugin');

      expect(closure.map((package) => package.name), ['protocol']);
    });

    // Regression: the check used to pin every `solana_kit_*` directory under
    // `packages/`, which pub treats as a root dependency of the temp app. That
    // pulled `solana_kit_integration_tests` into the resolve graph, and its
    // `solana_kit: ^0.10.0` constraint failed the whole build because the
    // umbrella package was never pinned alongside it. Unreachable members must
    // stay out so their constraints cannot break the check.
    test('excludes workspace members the root cannot reach', () {
      final closure = dependencyClosure([
        _package('plugin', dependencies: ['protocol']),
        _package('protocol'),
        _package(
          'solana_kit_integration_tests',
          dependencies: ['solana_kit', 'protocol'],
        ),
        _package('solana_kit'),
      ], 'plugin');

      expect(closure.map((package) => package.name), ['protocol']);
    });

    // The umbrella `solana_kit` package does not start with `solana_kit_`, so a
    // prefix-based directory scan could never pin it. The closure walks the
    // declared dependency graph instead of matching names.
    test('reaches packages whose name breaks the solana_kit_ prefix', () {
      final closure = dependencyClosure([
        _package('plugin', dependencies: ['solana_kit']),
        _package('solana_kit'),
      ], 'plugin');

      expect(closure.map((package) => package.name), ['solana_kit']);
    });

    test('excludes dev dependencies', () {
      final closure = dependencyClosure([
        _package('plugin', dependencies: ['protocol']),
        _package('protocol'),
      ], 'plugin');

      expect(
        closure.map((package) => package.name),
        isNot(contains('solana_kit_lints')),
      );
    });

    test('returns results sorted by name', () {
      final closure = dependencyClosure([
        _package('plugin', dependencies: ['zeta', 'alpha']),
        _package('zeta'),
        _package('alpha'),
      ], 'plugin');

      expect(closure.map((package) => package.name), ['alpha', 'zeta']);
    });

    test('does not loop on dependency cycles', () {
      final closure = dependencyClosure([
        _package('plugin', dependencies: ['a']),
        _package('a', dependencies: ['b']),
        _package('b', dependencies: ['a']),
      ], 'plugin');

      expect(closure.map((package) => package.name), ['a', 'b']);
    });

    test('ignores dependencies outside the workspace', () {
      final closure = dependencyClosure([
        _package('plugin', dependencies: ['meta', 'protocol']),
        _package('protocol'),
      ], 'plugin');

      expect(closure.map((package) => package.name), ['protocol']);
    });
  });

  group('readWorkspacePackages', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('workspace_');
    });

    tearDown(() {
      if (root.existsSync()) root.deleteSync(recursive: true);
    });

    test('reads members listed in the root pubspec', () {
      _writePackage(root, 'packages/a', 'a', dependencies: ['b']);
      _writePackage(root, 'packages/b', 'b');
      _writeRootPubspec(root, ['packages/a', 'packages/b']);

      final packages = readWorkspacePackages(root);

      expect(packages.map((package) => package.name), ['a', 'b']);
      expect(
        packages.singleWhere((package) => package.name == 'a').dependencies,
        ['b'],
      );
    });

    // `packages/` holds directories that are not workspace members, so the
    // workspace list is the only safe source of members.
    test('ignores directories absent from the workspace list', () {
      _writePackage(root, 'packages/a', 'a');
      _writePackage(root, 'packages/stray', 'stray');
      _writeRootPubspec(root, ['packages/a']);

      final packages = readWorkspacePackages(root);

      expect(packages.map((package) => package.name), ['a']);
    });

    test('reads dev dependencies separately from runtime dependencies', () {
      _writePackage(root, 'packages/a', 'a', devDependencies: ['lints']);
      _writeRootPubspec(root, ['packages/a']);

      final packages = readWorkspacePackages(root);

      expect(packages.single.dependencies, isEmpty);
    });

    test('throws when a listed member has no pubspec', () {
      _writeRootPubspec(root, ['packages/missing']);

      expect(() => readWorkspacePackages(root), throwsA(isA<StateError>()));
    });
  });

  group('stripNdkVersion', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('mwa_app_');
    });

    tearDown(() {
      if (root.existsSync()) root.deleteSync(recursive: true);
    });

    File _writeGradleFile(String name, String contents) {
      final app = Directory('${root.path}/android/app')
        ..createSync(recursive: true);
      return File('${app.path}/$name')..writeAsStringSync(contents);
    }

    // Regression: AGP resolves the template's `ndkVersion` and downloads an
    // NDK mid-build; a corrupt download fails the whole CI check. The plugin
    // has no native code, so the declaration must be removed before building.
    test('removes the ndkVersion assignment from the kotlin dsl script', () {
      _writeGradleFile('build.gradle.kts', '''
android {
    namespace = "com.example.app"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
    }
}
''');

      stripNdkVersion(root);

      final rewritten = File(
        '${root.path}/android/app/build.gradle.kts',
      ).readAsStringSync();
      expect(rewritten, isNot(contains('ndkVersion')));
      expect(rewritten, contains('compileSdk = 35'));
    });

    test('handles a groovy script with a pinned ndk version string', () {
      _writeGradleFile('build.gradle', '''
android {
    ndkVersion = "28.2.13676358"
}
''');

      stripNdkVersion(root);

      expect(
        File('${root.path}/android/app/build.gradle').readAsStringSync(),
        isNot(contains('28.2.13676358')),
      );
    });

    test('leaves scripts without ndkVersion untouched', () {
      _writeGradleFile('build.gradle.kts', 'android {\n}\n');
      final file = File('${root.path}/android/app/build.gradle.kts');

      stripNdkVersion(root);

      expect(file.readAsStringSync(), 'android {\n}\n');
    });

    test('throws when the app has no gradle build script', () {
      Directory('${root.path}/android/app').createSync(recursive: true);

      expect(() => stripNdkVersion(root), throwsA(isA<StateError>()));
    });
  });
}

WorkspacePackage _package(
  String name, {
  List<String> dependencies = const [],
}) => WorkspacePackage(
  name: name,
  directory: '/tmp/$name',
  dependencies: dependencies,
);

void _writeRootPubspec(Directory root, List<String> members) {
  File('${root.path}/pubspec.yaml').writeAsStringSync('''
name: solana_kit_workspace
publish_to: none

environment:
  sdk: ^3.13.0
workspace:
${members.map((member) => '  - $member').join('\n')}
''');
}

void _writePackage(
  Directory root,
  String relativePath,
  String name, {
  List<String> dependencies = const [],
  List<String> devDependencies = const [],
}) {
  final directory = Directory('${root.path}/$relativePath')
    ..createSync(recursive: true);
  final buffer = StringBuffer()
    ..writeln('name: $name')
    ..writeln('version: 0.1.0')
    ..writeln('environment:')
    ..writeln('  sdk: ^3.13.0');
  if (dependencies.isNotEmpty) {
    buffer
      ..writeln('dependencies:')
      ..writeln(
        dependencies.map((dependency) => '  $dependency: ^0.1.0').join('\n'),
      );
  }
  if (devDependencies.isNotEmpty) {
    buffer
      ..writeln('dev_dependencies:')
      ..writeln(
        devDependencies.map((dependency) => '  $dependency: ^0.1.0').join('\n'),
      );
  }
  File('${directory.path}/pubspec.yaml').writeAsStringSync(buffer.toString());
}
