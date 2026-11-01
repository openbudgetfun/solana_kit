import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:solana_kit_docs_site/site/highlighter.dart';
import 'package:solana_kit_docs_site/site/ink.dart';

/// A highlighted code sample in a hand-drawn frame, with a copy button.
class SketchCode extends StatelessComponent {
  /// Creates a frame around [source], highlighted as [language].
  const SketchCode({
    required this.source,
    this.language,
    this.caption,
    this.classes,
    super.key,
  });

  /// The code to show.
  final String source;

  /// The highlighting language, such as `dart` or `bash`.
  final String? language;

  /// A label shown in the frame's top bar instead of the language name.
  final String? caption;

  /// Extra CSS classes for the frame.
  final String? classes;

  @override
  Component build(BuildContext context) {
    final text = source.trimRight();
    final label = caption ?? language;

    return WiredBox(
      seed: seedFor(text),
      roughness: 0.8,
      tag: 'figure',
      classes: ['code-frame', ?classes].join(' '),
      child: Component.fragment([
        div(classes: 'code-frame-bar', [
          if (label != null)
            span(classes: 'code-frame-label', [Component.text(label)]),
          const button(
            classes: 'copy-button',
            attributes: {
              'type': 'button',
              'data-copy-code': '',
              'aria-label': 'Copy code',
            },
            [Component.text('Copy')],
          ),
        ]),
        pre(
          classes: 'code',
          attributes: {'data-language': ?language},
          [
            code([
              for (final span in highlight(text, language))
                if (span.token case final token?)
                  Component.element(
                    tag: 'span',
                    classes: token,
                    children: [Component.text(span.text)],
                  )
                else
                  Component.text(span.text),
            ]),
          ],
        ),
      ]),
    );
  }
}

/// Renders fenced Markdown code blocks as [SketchCode].
class SketchCodeBlocks extends CustomComponent {
  /// Creates the Markdown code block renderer.
  const SketchCodeBlocks() : super.base();

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node case ElementNode(
      tag: 'pre',
      children: [ElementNode(tag: 'code', :final attributes, :final children)],
    )) {
      final className = attributes['class'] ?? '';
      final language = className.startsWith('language-')
          ? className.substring('language-'.length)
          : null;

      return SketchCode(
        source: children?.map((child) => child.innerText).join() ?? '',
        language: language,
      );
    }

    return null;
  }
}
