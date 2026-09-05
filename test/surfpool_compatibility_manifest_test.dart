import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  final manifest =
      jsonDecode(
            File('config/surfpool-compatibility.json').readAsStringSync(),
          )!
          as Map<String, Object?>;
  final groups = (manifest['groups']! as List<Object?>)
      .cast<Map<String, Object?>>();

  test('every workspace package has one compatibility validation lane', () {
    final packageDirectories = Directory('packages')
        .listSync()
        .whereType<Directory>()
        .where(
          (directory) => File('${directory.path}/pubspec.yaml').existsSync(),
        )
        .map((directory) => directory.uri.pathSegments.reversed.skip(1).first)
        .toSet();
    final declaredPackages = groups
        .expand(
          (group) => (group['packages']! as List<Object?>).cast<String>(),
        )
        .toList();

    expect(declaredPackages.toSet(), packageDirectories);
    expect(declaredPackages, hasLength(declaredPackages.toSet().length));
  });

  test('every lane states its expected result and points to real evidence', () {
    for (final group in groups) {
      expect(
        group['name'],
        isA<String>().having((value) => value, 'name', isNotEmpty),
      );
      expect(
        group['validationMode'],
        isIn(['surfpool', 'contract', 'platform', 'tooling']),
      );
      expect(
        group['expectedOutcome'],
        isA<String>().having((value) => value, 'expectedOutcome', isNotEmpty),
      );
      final evidence = (group['evidence']! as List<Object?>).cast<String>();
      expect(evidence, isNotEmpty);
      for (final path in evidence) {
        expect(
          FileSystemEntity.typeSync(path),
          isNot(FileSystemEntityType.notFound),
          reason: '${group['name']} refers to missing evidence $path',
        );
      }
    }
  });
}
