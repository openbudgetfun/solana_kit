import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:skribble_rough/skribble_rough.dart' show Drawable, PointD;
import 'package:solana_kit_docs_site/components/site_paths.dart';
import 'package:solana_kit_docs_site/components/sketch_code.dart';
import 'package:solana_kit_docs_site/landing/landing_examples.dart';
import 'package:solana_kit_docs_site/site/ink.dart';
import 'package:solana_kit_docs_site/site/links.dart';
import 'package:solana_kit_docs_site/site/navigation.dart';
import 'package:solana_kit_docs_site/site/workspace_data.dart';

/// The landing page: hero, live examples, features, paths into the docs,
/// and the package map.
class LandingPage extends StatelessComponent {
  /// Creates the landing page for a site deployed at [basePath].
  const LandingPage({
    required this.basePath,
    required this.workspace,
    super.key,
  });

  /// Base path where the site is deployed.
  final String basePath;

  /// Versions and example code read from the workspace.
  final WorkspaceData workspace;

  String _link(String route) => docsRoute(basePath, route);

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      _hero(),
      _facts(),
      _examples(),
      _features(),
      _paths(),
      _packages(),
      _closing(),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Hero

  Component _hero() {
    return section(
      classes: 'hero reveal',
      attributes: const {'aria-labelledby': 'hero-title'},
      [
        div(classes: 'hero-copy', [
          const p(classes: 'eyebrow', [
            Component.text('The Solana SDK for Dart & Flutter'),
          ]),
          h1(id: 'hero-title', [
            const Component.text('Build on Solana in '),
            WiredHighlight(
              kind: WiredHighlightKind.marker,
              seed: 5,
              color: Tone.sun.css,
              child: const Component.text('typed Dart'),
            ),
            const Component.text('.'),
          ]),
          const p(classes: 'hero-lede', [
            Component.text('A full port of '),
            a(href: SiteLinks.upstreamKit, [
              code([Component.text('@solana/kit')]),
            ]),
            Component.text(
              ': addresses, codecs, RPC, subscriptions, transactions, '
              'signers, and program clients, written with records, sealed '
              'classes, and extension types.',
            ),
          ]),
          div(classes: 'hero-actions', [
            WiredButton(
              seed: 12,
              href: _link('/docs/getting-started/installation'),
              child: const Component.text('Get started'),
            ),
            WiredButton(
              seed: 14,
              variant: WiredButtonVariant.secondary,
              href: '${_link('/')}#examples',
              child: const Component.text('See it in code'),
            ),
          ]),
          const _InstallCommand(command: 'dart pub add solana_kit'),
        ]),
        const div(classes: 'hero-art', [_TransactionSketch()]),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Facts strip

  Component _facts() {
    final facts = [
      ('${workspace.packageCount}', 'packages on pub.dev'),
      ('v${workspace.upstreamKitVersion}', '@solana/kit parity target'),
      ('Dart 3', 'records, patterns, sealed classes'),
      ('MIT', 'open-source licence'),
    ];

    return section(
      classes: 'facts reveal',
      attributes: const {'aria-label': 'Solana Kit at a glance'},
      [
        ul([
          for (final (index, (value, label)) in facts.indexed)
            li([
              WiredBox(
                seed: 90 + index,
                classes: 'fact',
                child: Component.fragment([
                  span(classes: 'fact-value', [Component.text(value)]),
                  span(classes: 'fact-label', [Component.text(label)]),
                ]),
              ),
            ]),
        ]),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Examples

  Component _examples() {
    return section(
      id: 'examples',
      classes: 'band examples reveal',
      attributes: const {'aria-labelledby': 'examples-title'},
      [
        _sectionHeading(
          id: 'examples-title',
          eyebrow: 'Examples',
          title: 'Real code, straight from the repo',
          lede:
              'Every snippet below is cut from a runnable file in examples/, '
              'which CI analyses on every change, so it cannot drift from the '
              'API.',
        ),
        div(
          classes: 'example-switcher',
          attributes: const {'data-tabs': ''},
          [
            div(
              classes: 'example-tabs',
              attributes: const {
                'role': 'tablist',
                'aria-label': 'Code examples',
              },
              [
                for (final (index, example) in landingExamples.indexed)
                  button(
                    id: 'tab-${example.id}',
                    classes: 'example-tab',
                    attributes: {
                      'type': 'button',
                      'role': 'tab',
                      'aria-controls': 'panel-${example.id}',
                      'aria-selected': index == 0 ? 'true' : 'false',
                      'tabindex': index == 0 ? '0' : '-1',
                    },
                    [Component.text(example.tab)],
                  ),
              ],
            ),
            for (final (index, example) in landingExamples.indexed)
              _examplePanel(example, selected: index == 0),
          ],
        ),
      ],
    );
  }

  Component _examplePanel(LandingExample example, {required bool selected}) {
    final source = workspace.exampleRegion(example.file, 'landing');

    return div(
      id: 'panel-${example.id}',
      classes: 'example-panel',
      attributes: {
        'role': 'tabpanel',
        'aria-labelledby': 'tab-${example.id}',
        'tabindex': '0',
        if (!selected) 'data-inactive': '',
      },
      [
        div(classes: 'example-copy', [
          h3([Component.text(example.title)]),
          p([Component.text(example.summary)]),
          ul(classes: 'checklist', [
            for (final point in example.points) li([Component.text(point)]),
          ]),
          p(classes: 'example-links', [
            a(href: _link(example.guideRoute), [
              Component.text('Read: ${example.guideLabel} →'),
            ]),
            a(href: SiteLinks.example(example.file), [
              Component.text('examples/${example.file}'),
            ]),
          ]),
        ]),
        SketchCode(
          source: source,
          language: 'dart',
          caption: example.file,
          classes: 'example-code',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Features

  Component _features() {
    final features = [
      (
        '{ }',
        Tone.sun,
        'Typed end to end',
        'Addresses, lamports, slots, signatures, and RPC responses are real '
            'Dart types, so mistakes surface in your editor, not on chain.',
      ),
      (
        '▦',
        Tone.mint,
        'Modular by design',
        'Import the umbrella solana_kit package, or depend on exactly the '
            '${workspace.packageCount} focused packages you need.',
      ),
      (
        '⇄',
        Tone.lilac,
        'Tracks upstream',
        'Ported from @solana/kit and pinned to '
            'v${workspace.upstreamKitVersion}, with executable parity checks '
            'for the behaviour that matters most.',
      ),
      (
        '◐',
        Tone.sky,
        'Flutter ready',
        'Mobile Wallet Adapter for Android, Wallet Standard contracts, and '
            'a wallet UI kit for your Flutter screens.',
      ),
      (
        '⚙',
        Tone.coral,
        'Program clients',
        'Clients for System, Token, Stake, Metaplex, and more, a runtime '
            'coder for Anchor IDLs, and a Codama renderer for your own.',
      ),
      (
        '!',
        Tone.pink,
        'Errors you can match',
        'Every failure is a SolanaError with an upstream-compatible code and '
            'context, ready for an exhaustive switch.',
      ),
    ];

    return section(
      classes: 'band features reveal',
      attributes: const {'aria-labelledby': 'features-title'},
      [
        _sectionHeading(
          id: 'features-title',
          eyebrow: 'Why Solana Kit',
          title: 'Everything @solana/kit does, the Dart way',
        ),
        ul(classes: 'feature-grid', [
          for (final (index, (glyph, tone, title, body)) in features.indexed)
            li([
              WiredCard(
                seed: 120 + index,
                classes: 'feature-card skribble-wobble',
                child: Component.fragment([
                  WiredCircle(
                    seed: 140 + index,
                    fill: tone.css,
                    fillStyle: RoughFillStyle.hachure,
                    classes: 'feature-glyph',
                    attributes: const {'aria-hidden': 'true'},
                    child: Component.text(glyph),
                  ),
                  h3([Component.text(title)]),
                  p([Component.text(body)]),
                ]),
              ),
            ]),
        ]),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Paths into the docs

  Component _paths() {
    final paths = [
      (
        'New to Solana Kit?',
        'Install the SDK, generate a signer, read an account, and send your '
            'first transaction.',
        'Start the quick start',
        '/docs/getting-started/quick-start',
        Tone.sun,
      ),
      (
        'Shipping a Flutter app?',
        'Connect mobile wallets, render wallet UI, and publish to the '
            'Solana dApp Store.',
        'Connect a wallet',
        '/docs/guides/mobile-wallet-adapter',
        Tone.mint,
      ),
      (
        'Coming from TypeScript?',
        'See which @solana/kit release each package tracks and where the '
            'Dart API deliberately differs.',
        'Check compatibility',
        '/docs/reference/upstream-compatibility',
        Tone.lilac,
      ),
    ];

    return section(
      classes: 'band paths reveal',
      attributes: const {'aria-labelledby': 'paths-title'},
      [
        _sectionHeading(
          id: 'paths-title',
          eyebrow: 'Start here',
          title: 'Pick your path',
        ),
        div(classes: 'path-grid', [
          for (final (index, (title, body, action, route, tone))
              in paths.indexed)
            a(classes: 'path-link', href: _link(route), [
              WiredBox(
                seed: 160 + index,
                fill: 'color-mix(in srgb, ${tone.css} 20%, transparent)',
                fillStyle: RoughFillStyle.solid,
                classes: 'path-card skribble-wobble',
                child: Component.fragment([
                  h3([Component.text(title)]),
                  p([Component.text(body)]),
                  span(classes: 'path-action', [Component.text('$action →')]),
                ]),
              ),
            ]),
        ]),
        div(classes: 'docs-map', [
          for (final section in docsSections)
            div(classes: 'docs-map-section', [
              h3([
                a(href: _link(section.pages.first.route), [
                  Component.text(section.title),
                ]),
              ]),
              p([Component.text(section.blurb)]),
            ]),
        ]),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Package map

  Component _packages() {
    const groups = [
      (
        'Foundations',
        [
          'solana_kit',
          'solana_kit_addresses',
          'solana_kit_keys',
          'solana_kit_signers',
          'solana_kit_errors',
        ],
      ),
      (
        'Data',
        [
          'solana_kit_codecs',
          'solana_kit_options',
          'solana_kit_accounts',
          'solana_kit_sysvars',
        ],
      ),
      (
        'Network',
        [
          'solana_kit_rpc',
          'solana_kit_rpc_subscriptions',
          'solana_kit_transaction_confirmation',
          'solana_kit_subscribable',
        ],
      ),
      (
        'Transactions',
        [
          'solana_kit_instructions',
          'solana_kit_transaction_messages',
          'solana_kit_transactions',
          'solana_kit_instruction_plans',
        ],
      ),
      (
        'Programs',
        [
          'solana_kit_system',
          'solana_kit_token',
          'solana_kit_token_2022',
          'solana_kit_stake',
          'solana_kit_anchor',
          'solana_kit_mpl_core',
        ],
      ),
      (
        'Apps & integrations',
        [
          'solana_kit_mobile_wallet_adapter',
          'solana_kit_wallet_ui',
          'solana_kit_wallet_standard',
          'solana_kit_helius',
          'solana_kit_privacy_rings',
          'solana_kit_jupiter',
          'solana_kit_pyth',
        ],
      ),
    ];

    return section(
      classes: 'band packages reveal',
      attributes: const {'aria-labelledby': 'packages-title'},
      [
        _sectionHeading(
          id: 'packages-title',
          eyebrow: 'Package map',
          title: 'Small packages, one toolkit',
          lede:
              'Each layer is its own package with its own changelog. Here are '
              'the ones you will reach for first.',
        ),
        div(classes: 'package-groups', [
          for (final (title, packages) in groups)
            div(classes: 'package-group', [
              h3([Component.text(title)]),
              ul([
                for (final package in packages)
                  li([
                    a(
                      classes: 'package-chip',
                      href: 'https://pub.dev/packages/$package',
                      [Component.text(package)],
                    ),
                  ]),
              ]),
            ]),
        ]),
        p(classes: 'packages-more', [
          a(href: _link('/docs/reference/package-catalog'), [
            Component.text(
              'Browse all ${workspace.packageCount} packages in the catalog →',
            ),
          ]),
        ]),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Closing call to action

  Component _closing() {
    return section(
      classes: 'closing reveal',
      attributes: const {'aria-labelledby': 'closing-title'},
      [
        WiredBox(
          seed: 200,
          fill: 'color-mix(in srgb, var(--coral) 14%, transparent)',
          fillStyle: RoughFillStyle.solid,
          classes: 'closing-card',
          child: Component.fragment([
            h2(id: 'closing-title', [
              const Component.text('Ready to '),
              WiredHighlight(
                kind: WiredHighlightKind.circle,
                seed: 9,
                color: Tone.coral.css,
                child: const Component.text('ship'),
              ),
              const Component.text('?'),
            ]),
            p([
              Component.text(
                'solana_kit ${workspace.umbrellaVersion} is on pub.dev. Add it, '
                'then follow the quick start.',
              ),
            ]),
            div(classes: 'hero-actions', [
              WiredButton(
                seed: 22,
                href: _link('/docs/getting-started/quick-start'),
                child: const Component.text('Read the quick start'),
              ),
              const WiredButton(
                seed: 24,
                variant: WiredButtonVariant.secondary,
                href: SiteLinks.repository,
                child: Component.text('Star on GitHub'),
              ),
            ]),
          ]),
        ),
      ],
    );
  }

  Component _sectionHeading({
    required String id,
    required String eyebrow,
    required String title,
    String? lede,
  }) {
    return header(classes: 'section-heading', [
      p(classes: 'eyebrow', [Component.text(eyebrow)]),
      h2(id: id, [Component.text(title)]),
      if (lede != null) p(classes: 'section-lede', [Component.text(lede)]),
    ]);
  }
}

/// A copyable shell command in a hand-drawn box.
class _InstallCommand extends StatelessComponent {
  const _InstallCommand({required this.command});

  final String command;

  @override
  Component build(BuildContext context) {
    return WiredBox(
      seed: 33,
      classes: 'install-command',
      child: Component.fragment([
        const span(
          classes: 'install-prompt',
          attributes: {'aria-hidden': 'true'},
          [Component.text(r'$')],
        ),
        code([Component.text(command)]),
        button(
          classes: 'copy-button',
          attributes: {
            'type': 'button',
            'data-copy-text': command,
            'aria-label': 'Copy the install command',
          },
          const [Component.text('Copy')],
        ),
      ]),
    );
  }
}

/// The hero illustration: a transaction's life as four sketched cards.
///
/// Each card names the real API from `examples/` that produces that step.
class _TransactionSketch extends StatelessComponent {
  const _TransactionSketch();

  @override
  Component build(BuildContext context) {
    const steps = [
      ('Instruction', 'getAddMemoInstruction(…)', Tone.sun),
      ('Message', 'createTransactionMessage(…)', Tone.mint),
      ('Signed', 'signTransactionWithSigners(…)', Tone.lilac),
      ('Confirmed', 'sendAndConfirmTransaction(…)', Tone.coral),
    ];

    return figure(classes: 'pipeline', [
      ol([
        for (final (index, (title, call, tone)) in steps.indexed) ...[
          li(classes: 'pipeline-step pipeline-step-$index', [
            WiredBox(
              seed: 300 + index * 3,
              classes: 'pipeline-card',
              child: Component.fragment([
                WiredCircle(
                  seed: 320 + index,
                  fill: tone.css,
                  fillStyle: RoughFillStyle.solid,
                  classes: 'pipeline-number',
                  attributes: const {'aria-hidden': 'true'},
                  child: Component.text('${index + 1}'),
                ),
                div([
                  strong([Component.text(title)]),
                  code([Component.text(call)]),
                ]),
              ]),
            ),
            if (index < steps.length - 1)
              Doodle(
                width: 60,
                height: 46,
                classes: 'pipeline-arrow',
                marks: [
                  InkMark(
                    _arrow(400 + index, mirrored: index.isOdd),
                    width: 2.2,
                  ),
                ],
              ),
          ]),
        ],
      ]),
      figcaption(classes: 'handnote', [
        const Component.text('typed at every step'),
        Doodle(
          width: 70,
          height: 44,
          classes: 'handnote-arrow',
          marks: [
            InkMark(
              roughPen(450).curvePath([
                PointD(4, 6),
                PointD(30, 4),
                PointD(52, 18),
                PointD(62, 38),
              ]),
              stroke: Tone.coral,
              width: 2.2,
            ),
            InkMark(
              roughPen(451).linearPath([
                PointD(52, 33),
                PointD(62, 39),
                PointD(66, 28),
              ]),
              stroke: Tone.coral,
              width: 2.2,
            ),
          ],
        ),
      ]),
    ]);
  }

  static Drawable _arrow(int seed, {required bool mirrored}) {
    double x(double value) => mirrored ? 60 - value : value;
    final pen = roughPen(seed);
    final shaft = pen.curvePath([
      PointD(x(14), 2),
      PointD(x(8), 18),
      PointD(x(18), 34),
      PointD(x(34), 42),
    ]);
    final head = pen.linearPath([
      PointD(x(24), 34),
      PointD(x(34), 42),
      PointD(x(23), 45),
    ]);

    return Drawable(
      options: shaft.options,
      sets: [...shaft.sets, ...head.sets],
    );
  }
}
