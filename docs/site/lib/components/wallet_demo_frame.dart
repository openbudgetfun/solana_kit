import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:solana_kit_docs_site/components/site_paths.dart';

/// Embeds the live wallet UI demo built from the `solana_kit_wallet_ui`
/// example app.
///
/// The demo is produced by `scripts/build_wallet_demo.dart` into
/// `docs/site/web/wallet-demo/` and is served at
/// `<basePath>wallet-demo/`. Usage in a documentation page:
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
    final height = switch (attributes['height']) {
      null => 720.0,
      final raw =>
        double.tryParse(raw) ??
            (throw FormatException(
              '<WalletDemo> height must be a number of pixels.',
              raw,
            )),
    };
    final src = _frameUrl(attributes['src'] ?? 'wallet-demo/');

    return _WalletDemoSurface(src: src, height: height);
  }

  String _frameUrl(String path) {
    final basePath = normalizeBasePath(_rawDocsBasePath);

    return path.startsWith('/')
        ? '$basePath${path.substring(1)}'
        : '$basePath$path';
  }
}

/// Renders the framed demo inside a documentation page.
class _WalletDemoSurface extends StatelessComponent {
  const _WalletDemoSurface({required this.src, required this.height});

  final String src;
  final double height;

  @override
  Component build(BuildContext context) {
    return WiredBox(
      seed: 64,
      roughness: 0.8,
      tag: 'section',
      classes: 'wallet-demo-frame',
      attributes: const {'data-wallet-demo': 'true'},
      child: Component.fragment([
        div(classes: 'wallet-demo-chrome', [
          const span(classes: 'wallet-demo-dot wallet-demo-dot-coral', []),
          const span(classes: 'wallet-demo-dot wallet-demo-dot-sun', []),
          const span(classes: 'wallet-demo-dot wallet-demo-dot-mint', []),
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
      ]),
    );
  }
}
