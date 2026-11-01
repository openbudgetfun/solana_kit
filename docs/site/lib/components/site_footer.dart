import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:solana_kit_docs_site/components/brand_mark.dart';
import 'package:solana_kit_docs_site/components/site_paths.dart';
import 'package:solana_kit_docs_site/site/links.dart';

/// The footer shared by every page.
class SiteFooter extends StatelessComponent {
  /// Creates a footer whose links resolve under [basePath].
  const SiteFooter({required this.basePath, super.key});

  /// Base path where the site is deployed.
  final String basePath;

  @override
  Component build(BuildContext context) {
    String link(String route) => docsRoute(basePath, route);

    final columns = [
      (
        'Learn',
        [
          ('Installation', link('/docs/getting-started/installation')),
          ('Quick start', link('/docs/getting-started/quick-start')),
          ('Core concepts', link('/docs/core/architecture')),
          ('Guides', link('/docs/guides/build-rpc-service')),
        ],
      ),
      (
        'Reference',
        [
          ('Package catalog', link('/docs/reference/package-catalog')),
          ('API reference', SiteLinks.apiReference),
          (
            'Upstream compatibility',
            link('/docs/reference/upstream-compatibility'),
          ),
        ],
      ),
      (
        'Project',
        [
          ('GitHub', SiteLinks.repository),
          ('pub.dev', SiteLinks.pubDev),
          ('Report an issue', SiteLinks.issues),
          ('Contributing', link('/docs/contributing')),
        ],
      ),
    ];

    return footer(classes: 'site-footer', [
      const WiredDivider(seed: 31, classes: 'site-footer-rule'),
      div(classes: 'site-footer-inner', [
        const div(classes: 'site-footer-brand', [
          BrandMark(height: 34, seed: 41),
          p([
            Component.text(
              'Solana Kit is a Dart and Flutter port of @solana/kit, '
              'released under the MIT licence.',
            ),
          ]),
          p(classes: 'muted', [
            Component.text('Drawn by hand with '),
            a(href: SiteLinks.skribble, [Component.text('skribble')]),
            Component.text('.'),
          ]),
        ]),
        for (final (title, links) in columns)
          nav(
            classes: 'site-footer-column',
            attributes: {'aria-label': title},
            [
              h2([Component.text(title)]),
              ul([
                for (final (label, href) in links)
                  li([
                    a(href: href, [Component.text(label)]),
                  ]),
              ]),
            ],
          ),
      ]),
    ]);
  }
}
