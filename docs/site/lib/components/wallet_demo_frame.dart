import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:solana_kit_docs_site/components/site_paths.dart';

/// Embeds the live wallet UI demo built from the `solana_kit_wallet_ui`
/// example app.
///
/// The demo is produced by `scripts/build_wallet_demo.dart` into
/// `docs/site/web/wallet-demo/` and is served at
/// `<basePath>demo/wallet-ui/`. Usage in a documentation page:
///
/// ```md
/// <WalletDemo height="720"></WalletDemo>
/// ```
class WalletDemoFrame extends CustomComponentBase {
  /// Creates the wallet demo embed component.
  WalletDemoFrame();

  static const String _rawDocsBasePath = String.fromEnvironment(
    'DOCS_BASE_PATH',
    defaultValue: '/',
  );

  @override
  final Pattern pattern = RegExp('WalletDemo', caseSensitive: false);

  @override
  Component apply(
    String name,
    Map<String, String> attributes,
    Component? child,
  ) {
    final height = double.tryParse(attributes['height'] ?? '') ?? 720;
    final src = _frameUrl(attributes['src'] ?? 'wallet-demo/');
    return _WalletDemoSurface(src: src, height: height);
  }

  String _frameUrl(String path) {
    final basePath = normalizeBasePath(_rawDocsBasePath);
    return path.startsWith('/')
        ? '$basePath${path.substring(1)}'
        : '$basePath$path';
  }

  /// Styles for the framed demo surface.
  @css
  static List<StyleRule> get styles => [
    css('.wallet-demo-frame', [
      css('&').styles(
        display: Display.block,
        maxWidth: 940.px,
        margin: Margin.only(top: 1.25.rem, bottom: 2.rem),
        overflow: Overflow.hidden,
        radius: BorderRadius.circular(18.px),
        border: const Border.all(color: Color('rgba(139, 92, 246, 0.35)')),
        backgroundColor: const Color('#070a14'),
      ),
      css('.wallet-demo-chrome').styles(
        display: Display.flex,
        alignItems: AlignItems.center,
        gap: Gap.column(0.6.rem),
        padding: Padding.symmetric(vertical: 0.65.rem, horizontal: 1.1.rem),
        border: Border.only(
          bottom: BorderSide(
            color: const Color('rgba(139, 92, 246, 0.28)'),
            width: 1.px,
          ),
        ),
        backgroundColor: const Color('#10132d'),
      ),
      css('.wallet-demo-dot').styles(
        width: 10.px,
        height: 10.px,
        radius: BorderRadius.circular(999.px),
      ),
      css('.wallet-demo-dot-violet').styles(
        backgroundColor: const Color('#8b5cf6'),
      ),
      css('.wallet-demo-dot-cyan').styles(
        backgroundColor: const Color('#22d3ee'),
      ),
      css('.wallet-demo-dot-pink').styles(
        backgroundColor: const Color('#f472b6'),
      ),
      css('.wallet-demo-title').styles(
        fontSize: 0.72.rem,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.px,
        color: const Color('#8f9bbd'),
        textTransform: TextTransform.upperCase,
      ),
      css('.wallet-demo-link').styles(
        margin: const Margin.only(left: Unit.auto),
        fontSize: 0.8.rem,
        color: const Color('#22d3ee'),
        textDecoration: const TextDecoration(line: TextDecorationLine.none),
      ),
      css('.wallet-demo-link:hover').styles(
        color: const Color('#67e8f9'),
        textDecoration: const TextDecoration(
          line: TextDecorationLineKeyword.underline,
        ),
      ),
      css('iframe').styles(
        display: Display.block,
        width: 100.percent,
        border: Border.none,
        backgroundColor: const Color('#070a14'),
      ),
    ]),
  ];
}

/// Renders the framed demo inside a documentation page.
class _WalletDemoSurface extends StatelessComponent {
  const _WalletDemoSurface({required this.src, required this.height});

  final String src;
  final double height;

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'wallet-demo-frame',
      attributes: const {'data-wallet-demo': 'true'},
      [
        div(classes: 'wallet-demo-chrome', [
          const span(classes: 'wallet-demo-dot wallet-demo-dot-violet', []),
          const span(classes: 'wallet-demo-dot wallet-demo-dot-cyan', []),
          const span(classes: 'wallet-demo-dot wallet-demo-dot-pink', []),
          const span(classes: 'wallet-demo-title', [
            Component.text('wallet-ui · live demo'),
          ]),
          a(
            classes: 'wallet-demo-link',
            href: src,
            target: Target.blank,
            attributes: const {'rel': 'noopener'},
            const [Component.text('Fullscreen ↗')],
          ),
        ]),
        iframe(
          const [],
          src: src,
          styles: Styles(height: height.px),
          attributes: const {'title': 'Interactive wallet UI demo'},
        ),
      ],
    );
  }
}
