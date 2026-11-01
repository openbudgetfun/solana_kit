import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:solana_kit_docs_site/site/ink.dart';

/// The Markdown elements the docs draw by hand: callouts, blockquotes, and
/// tables.
const List<CustomComponent> sketchContentComponents = [
  _SketchCallout(),
  _SketchBlockquote(),
  _SketchTable(),
];

/// Renders `<Info>`, `<Note>`, `<Tip>`, `<Success>`, `<Warning>`, and
/// `<Error>` as a sticky note on the page.
class _SketchCallout extends CustomComponentBase {
  const _SketchCallout();

  @override
  Pattern get pattern => RegExp(r'(?:Info|Note|Tip|Success|Warning|Error)$');

  @override
  Component apply(
    String name,
    Map<String, String> attributes,
    Component? child,
  ) {
    final (tone, title, glyph) = switch (name) {
      'Warning' => (Tone.sun, 'Heads up', '!'),
      'Error' => (Tone.coral, 'Careful', '×'),
      'Tip' || 'Success' => (Tone.mint, 'Tip', '✓'),
      'Note' => (Tone.lilac, 'Note', '✎'),
      _ => (Tone.sky, 'Good to know', 'i'),
    };

    return WiredBox(
      seed: seedFor('$name${attributes['title']}'),
      tag: 'aside',
      fill: 'color-mix(in srgb, ${tone.css} 18%, transparent)',
      fillStyle: RoughFillStyle.solid,
      classes: 'callout callout-${name.toLowerCase()}',
      child: Component.fragment([
        WiredCircle(
          seed: seedFor(name),
          fill: tone.css,
          fillStyle: RoughFillStyle.solid,
          classes: 'callout-glyph',
          attributes: const {'aria-hidden': 'true'},
          child: Component.text(glyph),
        ),
        div(classes: 'callout-body', [
          p(classes: 'callout-title', [
            Component.text(attributes['title'] ?? title),
          ]),
          ?child,
        ]),
      ]),
    );
  }
}

/// Draws Markdown blockquotes as a highlighted note.
class _SketchBlockquote extends CustomComponentBase {
  const _SketchBlockquote();

  @override
  Pattern get pattern => RegExp(r'blockquote$');

  @override
  Component apply(
    String name,
    Map<String, String> attributes,
    Component? child,
  ) {
    return WiredBox(
      seed: 77,
      tag: 'blockquote',
      fill: 'color-mix(in srgb, var(--sun) 16%, transparent)',
      fillStyle: RoughFillStyle.solid,
      classes: 'sketch-quote',
      child: child ?? const Component.fragment([]),
    );
  }
}

/// Frames Markdown tables and lets wide ones scroll sideways.
class _SketchTable extends CustomComponentBase {
  const _SketchTable();

  @override
  Pattern get pattern => RegExp(r'table$');

  @override
  Component apply(
    String name,
    Map<String, String> attributes,
    Component? child,
  ) {
    return WiredBox(
      seed: 53,
      roughness: 0.7,
      classes: 'table-frame',
      child: div(
        classes: 'table-scroll',
        attributes: const {'tabindex': '0'},
        [
          Component.element(
            tag: 'table',
            attributes: attributes,
            children: [?child],
          ),
        ],
      ),
    );
  }
}
