import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:solana_kit_docs_site/components/site_paths.dart';

/// The lettering every page waits for before it paints, so text never
/// flashes in a fallback face and then reflows.
const criticalFonts = [
  ('SkribbleNotoSketch', 'SkribbleNotoSketch-Regular.woff'),
  ('SkribbleMonoPlayful', 'SkribbleMonoPlayful-Regular.woff'),
];

/// Marks the page as scripted and applies a saved theme before first paint,
/// so dark paper never flashes light.
const _bootScript = '''
(function (root) {
  root.classList.add("js");
  try {
    var theme = localStorage.getItem("solana-kit-docs:theme");
    if (theme === "light" || theme === "dark") root.dataset.theme = theme;
  } catch (error) {}
})(document.documentElement);''';

/// The base for the site's layouts: the shared `<head>` (fonts, theme,
/// stylesheets, scripts) and the deployment base path.
abstract class SiteLayout extends PageLayoutBase {
  /// Creates a layout whose links resolve under [basePath].
  const SiteLayout({required this.basePath});

  /// Base path where the site is deployed, such as `/` or `/solana_kit/`.
  final String basePath;

  /// Classes for `<body>`, which select the page's layout styles.
  String get bodyClasses;

  /// The absolute path of a site asset or route.
  String asset(String path) => docsRoute(basePath, path);

  @override
  Iterable<Component> buildHead(Page page) sync* {
    yield* super.buildHead(page);
    yield const meta(name: 'color-scheme', content: 'light dark');
    yield const meta(
      name: 'theme-color',
      content: '#fffaf0',
      attributes: {'media': '(prefers-color-scheme: light)'},
    );
    yield const meta(
      name: 'theme-color',
      content: '#1f1a24',
      attributes: {'media': '(prefers-color-scheme: dark)'},
    );
    yield const meta(
      attributes: {'property': 'og:site_name', 'content': 'Solana Kit'},
    );

    for (final (_, file) in criticalFonts) {
      yield link(
        rel: 'preload',
        href: asset('/fonts/$file'),
        attributes: const {
          'as': 'font',
          'type': 'font/woff',
          'crossorigin': '',
        },
      );
    }

    yield const script(content: _bootScript);
    yield const Component.element(
      tag: 'style',
      children: [RawText(skribbleCss)],
    );
    yield link(rel: 'stylesheet', href: asset('/site.css'));
    yield script(src: asset('/site.js'), defer: true);
  }

  @override
  Component buildLayout(Page page, Component child) {
    return Document(
      lang: 'en',
      base: basePath,
      head: buildHead(page).toList(),
      body: Component.fragment([
        Document.body(attributes: {'class': 'site-page $bodyClasses'}),
        buildBody(page, child),
      ]),
    );
  }
}
