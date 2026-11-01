import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:solana_kit_docs_site/components/brand_mark.dart';
import 'package:solana_kit_docs_site/components/site_paths.dart';
import 'package:solana_kit_docs_site/components/site_search.dart';
import 'package:solana_kit_docs_site/site/links.dart';

/// The sticky header shared by the landing page and the docs.
class SiteHeader extends StatelessComponent {
  /// Creates a header whose links resolve under [basePath].
  ///
  /// [currentRoute] highlights the matching top-level link. [showMenuButton]
  /// adds the button that opens the docs sidebar on small screens.
  const SiteHeader({
    required this.basePath,
    required this.currentRoute,
    this.showMenuButton = false,
    super.key,
  });

  /// Base path where the site is deployed.
  final String basePath;

  /// The route of the page being rendered, such as `/docs/core/codecs`.
  final String currentRoute;

  /// Whether to render the sidebar toggle for small screens.
  final bool showMenuButton;

  @override
  Component build(BuildContext context) {
    String link(String route) => docsRoute(basePath, route);

    final items = [
      ('Docs', '/docs', currentRoute == '/docs'),
      (
        'Guides',
        '/docs/guides/build-rpc-service',
        currentRoute.startsWith('/docs/guides') ||
            currentRoute.startsWith('/docs/programs'),
      ),
      (
        'Packages',
        '/docs/reference/package-catalog',
        currentRoute.startsWith('/docs/reference'),
      ),
    ];

    return header(classes: 'site-header', [
      div(classes: 'site-header-inner', [
        if (showMenuButton)
          const button(
            classes: 'menu-button',
            attributes: {
              'type': 'button',
              'data-sidebar-toggle': '',
              'aria-label': 'Open the docs menu',
              'aria-controls': 'docs-sidebar',
              'aria-expanded': 'false',
            },
            [
              span([]),
              span([]),
              span([]),
            ],
          ),
        a(
          classes: 'brand',
          href: link('/'),
          attributes: const {'aria-label': 'Solana Kit home'},
          const [
            BrandMark(),
            span(classes: 'brand-name', [
              Component.text('Solana Kit'),
            ]),
          ],
        ),
        nav(
          classes: 'site-nav',
          attributes: const {'aria-label': 'Main'},
          [
            ul([
              for (final (label, route, active) in items)
                li([
                  a(
                    href: link(route),
                    attributes: {if (active) 'aria-current': 'page'},
                    [Component.text(label)],
                  ),
                ]),
              const li([
                a(
                  href: SiteLinks.repository,
                  classes: 'external',
                  [Component.text('GitHub')],
                ),
              ]),
            ]),
          ],
        ),
        div(classes: 'site-header-tools', [
          SiteSearch(basePath: basePath),
          const ThemeToggle(),
        ]),
      ]),
    ]);
  }
}
