import 'dart:io';

import 'package:solana_kit_docs_site/landing/landing_examples.dart';
import 'package:solana_kit_docs_site/site/highlighter.dart';
import 'package:solana_kit_docs_site/site/ink.dart';
import 'package:solana_kit_docs_site/site/navigation.dart';
import 'package:solana_kit_docs_site/site/workspace_data.dart';
import 'package:test/test.dart';

void main() {
  // The workspace runner starts tests from the repository root, `dart test`
  // in docs/site starts them here; resolve the content folder either way.
  final contentDirectory = Directory(
    '${findWorkspaceRoot(Directory.current).path}/docs/site/content',
  );

  group('navigation', () {
    test('lists every docs page exactly once', () {
      final files = Directory('${contentDirectory.path}/docs')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.md'))
          .map(
            (file) => file.path.substring(contentDirectory.path.length + 1),
          )
          .toSet();
      final listed = allDocsPages.map(contentPathFor).toList();

      expect(listed.toSet(), hasLength(listed.length), reason: 'duplicates');
      expect(listed.toSet(), files);
    });

    test('keeps legacy routes unique and clear of current routes', () {
      final legacy = [
        for (final page in allDocsPages) ?page.legacyRoute,
      ];
      final current = allDocsPages.map((page) => page.route).toSet();

      expect(legacy.toSet(), hasLength(legacy.length));
      expect(legacy.toSet().intersection(current), isEmpty);
      expect(legacy, isNot(contains('/')), reason: '/ is the landing page');
    });

    test('finds neighbours in reading order', () {
      final first = neighboursOf(allDocsPages.first.route);
      final last = neighboursOf(allDocsPages.last.route);

      expect(first.previous, isNull);
      expect(first.next, allDocsPages[1]);
      expect(last.next, isNull);
      expect(neighboursOf('/not-a-page').next, isNull);
    });

    test('ignores trailing slashes when matching routes', () {
      expect(docsPageFor('/docs/core/codecs/')?.title, 'Codecs');
      expect(docsSectionFor('/docs/core/codecs')?.title, 'Core concepts');
      expect(docsPageFor('/core/codecs'), isNull);
    });
  });

  group('extractRegion', () {
    const source = '''
void main() {
  // #docregion demo
  final a = 1;
  // #enddocregion demo
  print(a);
  // #docregion other
  final ignored = 0;
  // #enddocregion other
  // #docregion demo
  final b = 2;
  // #enddocregion demo
}
''';

    test('joins and dedents every piece of a region', () {
      expect(extractRegion(source, 'demo'), 'final a = 1;\n\nfinal b = 2;');
    });

    test('throws for a missing region', () {
      expect(() => extractRegion(source, 'absent'), throwsStateError);
    });

    test('throws for an unclosed region', () {
      expect(
        () => extractRegion('// #docregion open\nfinal a = 1;\n', 'open'),
        throwsFormatException,
      );
    });

    test('throws for a region closed before it opens', () {
      expect(
        () => extractRegion('// #enddocregion early\n', 'early'),
        throwsFormatException,
      );
    });
  });

  group('workspace data', () {
    final workspace = WorkspaceData.load();

    test('reads versions and package counts from the workspace', () {
      expect(workspace.upstreamKitVersion, matches(RegExp(r'^\d+\.\d+\.\d+')));
      expect(workspace.umbrellaVersion, matches(RegExp(r'^\d+\.\d+\.\d+')));
      expect(workspace.packageCount, greaterThan(10));
    });

    for (final example in landingExamples) {
      test('quotes a landing region from ${example.file}', () {
        final source = workspace.exampleRegion(example.file, 'landing');

        expect(source.trim(), isNotEmpty);
        expect(source, isNot(contains('#docregion')));
        expect(source, isNot(contains('#enddocregion')));
      });

      test('links ${example.id} to a real docs route', () {
        final route = example.guideRoute.split('#').first;

        expect(docsPageFor(route), isNotNull, reason: route);
      });
    }
  });

  group('highlight', () {
    test('reassembles the original source', () {
      const source = "final rpc = createSolanaRpc(url: 'https://x'); // hi";
      final spans = highlight(source, 'dart');

      expect(spans.map((span) => span.text).join(), source);
    });

    test('classifies Dart tokens', () {
      final tokens = {
        for (final span in highlight(
          "@override final x = Address('a'); // note\nfoo(42);",
          'dart',
        ))
          span.text: ?span.token,
      };

      expect(tokens, {
        '@override': 'tok-a',
        'final': 'tok-k',
        'Address': 'tok-t',
        "'a'": 'tok-s',
        '// note': 'tok-c',
        'foo': 'tok-f',
        '42': 'tok-n',
      });
    });

    test('leaves unknown languages uncoloured', () {
      expect(highlight('plain text', 'brainfuck'), [
        (token: null, text: 'plain text'),
      ]);
      expect(highlight('plain text', null), hasLength(1));
    });
  });

  test('seedFor is stable and positive', () {
    expect(seedFor('codecs'), seedFor('codecs'));
    expect(seedFor('codecs'), isNot(seedFor('signers')));
    expect(seedFor(''), greaterThan(0));
  });
}
