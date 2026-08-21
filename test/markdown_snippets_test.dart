// Tests that every Dart code block in Markdown documentation is a complete,
// analyzable snippet.
//
// READMEs and the workspace readme contain runnable examples. If one of those
// examples drifts from the real API, this test fails: it extracts each ```dart
// block, writes it to a scratch directory, and runs `dart analyze` over the
// result. Keeping documentation in sync becomes a compile-time concern.

import 'dart:io';

import 'package:test/test.dart';

void main() {
  final repoRoot = Directory.current;
  final snippetRoot = Directory(
    '${repoRoot.path}${Platform.pathSeparator}.dart_tool'
    '${Platform.pathSeparator}markdown_snippets',
  );
  final filter = Platform.environment['SNIPPET_FILTER'];
  final markdownFiles = _findMarkdownFiles(repoRoot, filter);

  group('Markdown Dart snippets', () {
    test('Markdown files export analyzable Dart blocks', () {
      expect(markdownFiles, isNotEmpty);
      var snippetCount = 0;
      for (final relativePath in markdownFiles) {
        final file = File(
          '${repoRoot.path}${Platform.pathSeparator}$relativePath',
        );
        final snippets = _extractDartCodeBlocks(file.readAsStringSync());
        snippetCount += snippets.length;
      }
      expect(snippetCount, greaterThan(0));
    });

    test('Markdown Dart snippets analyze cleanly', () async {
      if (snippetRoot.existsSync()) {
        snippetRoot.deleteSync(recursive: true);
      }
      snippetRoot.createSync(recursive: true);
      addTearDown(() {
        if (snippetRoot.existsSync()) {
          snippetRoot.deleteSync(recursive: true);
        }
      });

      var snippetCount = 0;
      for (final relativePath in markdownFiles) {
        final file = File(
          '${repoRoot.path}${Platform.pathSeparator}$relativePath',
        );
        final snippets = _extractDartCodeBlocks(file.readAsStringSync());
        for (var index = 0; index < snippets.length; index++) {
          File(
            '${snippetRoot.path}${Platform.pathSeparator}'
            '${_slugify(relativePath)}_${index + 1}.dart',
          ).writeAsStringSync('${snippets[index]}\n');
          snippetCount++;
        }
      }

      expect(snippetCount, greaterThan(0));

      final result = await Process.run(
        'dart',
        ['analyze', snippetRoot.path],
        workingDirectory: repoRoot.path,
      );
      if (result.exitCode != 0) {
        fail(
          'Expected Markdown Dart snippets to analyze cleanly.\n'
          'stdout:\n${result.stdout}\n'
          'stderr:\n${result.stderr}',
        );
      }
    });
  });
}

List<String> _findMarkdownFiles(Directory repoRoot, String? filter) {
  final wanted = filter
      ?.split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  final files = <String>[];
  final candidates = <String>[
    'readme.md',
    for (final entity in Directory(
      '${repoRoot.path}${Platform.pathSeparator}packages',
    ).listSync())
      if (entity is Directory)
        'packages/${entity.path.split(Platform.pathSeparator).last}/README.md',
  ];
  for (final relativePath in candidates) {
    // codama-renderers-dart is an npm package; its README shows generated
    // Dart output patterns that are not standalone-compilable.
    if (relativePath.startsWith('packages/codama-renderers-dart/')) {
      continue;
    }
    final file = File(
      '${repoRoot.path}${Platform.pathSeparator}$relativePath',
    );
    if (file.existsSync()) {
      if (wanted == null || wanted.any(relativePath.toLowerCase().contains)) {
        files.add(relativePath);
      }
    }
  }
  files.sort();
  return files;
}

List<String> _extractDartCodeBlocks(String markdown) {
  final expression = RegExp(r'```dart\n([\s\S]*?)\n```');
  return [
    for (final match in expression.allMatches(markdown)) match.group(1)!.trim(),
  ];
}

String _slugify(String value) =>
    value.replaceAll('/', '_').replaceAll(r'\', '_').replaceAll('.', '_');
