import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:solana_kit_docs_site/components/site_paths.dart';
import 'package:solana_kit_docs_site/site/navigation.dart';

/// Pages that keep the pre-`/docs/` URLs working.
///
/// Every page with a [DocsPage.legacyRoute] gets a tiny static page at the
/// old URL that forwards to the new one, keeping any `#fragment` (package
/// READMEs deep-link into the package catalog by anchor).
List<MemoryPage> legacyRedirectPages(String basePath) => [
  for (final page in allDocsPages)
    if (page.legacyRoute case final legacy?)
      MemoryPage.builder(
        path: '${legacy.substring(1)}.html',
        applyLayout: false,
        builder: (_) => RedirectDocument(
          target: docsRoute(basePath, page.route),
          title: page.title,
        ),
      ),
];

/// A document that immediately forwards the browser to [target].
class RedirectDocument extends StatelessComponent {
  /// Creates a redirect to [target], naming the destination [title].
  const RedirectDocument({
    required this.target,
    required this.title,
    super.key,
  });

  /// The absolute path to forward to.
  final String target;

  /// The destination page's title.
  final String title;

  @override
  Component build(BuildContext context) {
    final escaped = target.replaceAll(r'\', r'\\').replaceAll('"', r'\"');

    return Document(
      title: '$title | Solana Kit',
      lang: 'en',
      meta: const {'robots': 'noindex'},
      head: [
        link(rel: 'canonical', href: target),
        meta(httpEquiv: 'refresh', content: '0; url=$target'),
        script(
          content:
              'location.replace("$escaped" + location.search + location.hash);',
        ),
      ],
      body: p([
        const Component.text('Solana Kit docs moved. Continue to '),
        a(href: target, [Component.text(title)]),
        const Component.text('.'),
      ]),
    );
  }
}
