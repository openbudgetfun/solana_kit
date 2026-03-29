import 'dart:io';

import 'package:test/test.dart';

void main() {
  final repoRoot = Directory.current;
  final docSnippetRoot = Directory(
    '${repoRoot.path}${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}doc_comment_snippets',
  );
  final documentedLibraries = _findDocumentedLibraries(repoRoot);

  group('synchronized Dart doc comments', () {
    test('consumer blocks are up to date', () async {
      final result = await Process.run(
        'python3',
        ['scripts/sync-dart-doc-comments.py', '--check'],
        workingDirectory: repoRoot.path,
      );

      if (result.exitCode != 0) {
        fail(
          'Expected synchronized Dart doc comments to be up to date.\n'
          'stdout:\n${result.stdout}\n'
          'stderr:\n${result.stderr}',
        );
      }
    });

    test('doc comment code blocks analyze cleanly', () async {
      if (docSnippetRoot.existsSync()) {
        docSnippetRoot.deleteSync(recursive: true);
      }
      docSnippetRoot.createSync(recursive: true);
      addTearDown(() {
        if (docSnippetRoot.existsSync()) {
          docSnippetRoot.deleteSync(recursive: true);
        }
      });

      expect(documentedLibraries, isNotEmpty);

      var snippetCount = 0;
      for (final relativePath in documentedLibraries) {
        final file = File('${repoRoot.path}${Platform.pathSeparator}$relativePath');
        final docMarkdown = _extractTopLevelDocMarkdown(file.readAsStringSync());
        final snippets = _extractDartCodeBlocks(docMarkdown);
        expect(
          snippets,
          isNotEmpty,
          reason: 'Expected at least one Dart code block in $relativePath',
        );

        for (var index = 0; index < snippets.length; index++) {
          File(
            '${docSnippetRoot.path}${Platform.pathSeparator}${_slugify(relativePath)}_${index + 1}.dart',
          ).writeAsStringSync('${snippets[index]}\n');
          snippetCount++;
        }
      }

      expect(snippetCount, greaterThan(0));

      final result = await Process.run(
        'dart',
        ['analyze', docSnippetRoot.path],
        workingDirectory: repoRoot.path,
      );

      if (result.exitCode != 0) {
        fail(
          'Expected Dart doc comment snippets to analyze cleanly.\n'
          'stdout:\n${result.stdout}\n'
          'stderr:\n${result.stderr}',
        );
      }
    });
  });
}

List<String> _findDocumentedLibraries(Directory repoRoot) {
  final packagesDir = Directory(
    '${repoRoot.path}${Platform.pathSeparator}packages',
  );
  final libraries = <String>[];

  for (final entity in packagesDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final relativePath = entity.path.substring(repoRoot.path.length + 1);
    if (!RegExp(r'^packages/[^/]+/lib/[^/]+\.dart$').hasMatch(relativePath)) {
      continue;
    }

    final source = entity.readAsStringSync();
    if (source.contains('/// <!-- {=')) {
      libraries.add(relativePath);
    }
  }

  libraries.sort();
  return libraries;
}

String _extractTopLevelDocMarkdown(String source) {
  final lines = source.split('\n');
  final buffer = StringBuffer();
  var sawDocComment = false;

  for (final line in lines) {
    if (line.startsWith('///')) {
      sawDocComment = true;
      var text = line.substring(3);
      if (text.startsWith(' ')) {
        text = text.substring(1);
      }
      buffer.writeln(text);
      continue;
    }

    if (sawDocComment) {
      break;
    }
  }

  return buffer.toString();
}

List<String> _extractDartCodeBlocks(String markdown) {
  final expression = RegExp(r'```dart\n([\s\S]*?)\n```');
  return [
    for (final match in expression.allMatches(markdown)) match.group(1)!.trim(),
  ];
}

String _slugify(String value) =>
    value.replaceAll('/', '_').replaceAll(r'\\', '_').replaceAll('.', '_');
