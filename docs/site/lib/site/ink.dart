/// Hand-drawn doodles built on skribble's rough engine.
///
/// `skribble_jaspr` covers boxes, buttons, and highlights. The site also
/// draws multi-coloured doodles (the brand mark, arrows, icons), so this file
/// composes several rough drawables into one decorative `<svg>`, colouring
/// each with the site's palette custom properties so the art follows the
/// light and dark themes.
library;

import 'package:jaspr/jaspr.dart';
import 'package:skribble_rough/skribble_rough.dart';

/// A colour from the site palette, used as `var(--name)`.
enum Tone {
  /// The text colour: plum ink on light paper, cream on dark.
  ink,

  /// The primary accent.
  coral,

  /// The marker yellow.
  sun,

  /// Purple, used for Solana's gradient end.
  lilac,

  /// Teal, used for Solana's gradient start.
  mint,

  /// Blue.
  sky,

  /// Pink.
  pink,

  /// The page colour, for knocking shapes out of ink.
  paper;

  /// The CSS value that resolves to this tone.
  String get css => 'var(--$name)';
}

/// One drawable in a [Doodle], with the tones it is painted in.
final class InkMark {
  /// Creates a mark that strokes [drawable] in [stroke] and fills it in
  /// [fill].
  const InkMark(this.drawable, {this.stroke = Tone.ink, this.fill, this.width});

  /// The rough shape.
  final Drawable drawable;

  /// The outline tone.
  final Tone stroke;

  /// The fill tone for solid and hatched fills; defaults to [stroke].
  final Tone? fill;

  /// The outline width in pixels, before scaling.
  final double? width;
}

/// Creates a rough pen for [seed].
///
/// The same seed always draws the same wobble, so static builds stay
/// byte-stable.
Generator roughPen(
  int seed, {
  double roughness = 1,
  RoughFillStyle fill = RoughFillStyle.none,
  double hachureGap = 5,
}) {
  final config = DrawConfig.build(seed: seed, roughness: roughness);

  return Generator(
    config,
    fill.filler(FillerConfig.build(drawConfig: config, hachureGap: hachureGap)),
  );
}

/// A stable seed derived from [text] (FNV-1a), for ink that should differ
/// between elements but never between builds.
int seedFor(String text) {
  var hash = 0x811c9dc5;

  for (final unit in text.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
  }

  return hash % 100000 + 1;
}

/// A decorative, multi-coloured rough drawing.
class Doodle extends StatelessComponent {
  /// Creates a [width] by [height] drawing of [marks].
  const Doodle({
    required this.width,
    required this.height,
    required this.marks,
    this.scale = 1,
    this.classes,
    this.label,
    super.key,
  });

  /// The drawing's intrinsic width.
  final double width;

  /// The drawing's intrinsic height.
  final double height;

  /// What to draw, back to front.
  final List<InkMark> marks;

  /// How much larger than [width] by [height] to render the drawing.
  final double scale;

  /// Extra CSS classes for the `<svg>`.
  final String? classes;

  /// An accessible name. When null the drawing is hidden from assistive
  /// technology.
  final String? label;

  @override
  Component build(BuildContext context) {
    final label = this.label;

    return Component.element(
      tag: 'svg',
      classes: ['doodle', ?classes].join(' '),
      attributes: {
        'viewBox': '0 0 ${_number(width)} ${_number(height)}',
        'width': _number(width * scale),
        'height': _number(height * scale),
        'focusable': 'false',
        if (label == null) 'aria-hidden': 'true',
        if (label != null) ...{'role': 'img', 'aria-label': label},
      },
      children: [for (final mark in marks) ..._paths(mark)],
    );
  }

  Iterable<Component> _paths(InkMark mark) sync* {
    final ink = RoughSvg.fromDrawable(mark.drawable);
    final fill = (mark.fill ?? mark.stroke).css;
    final width = _number(mark.width ?? 2);

    if (ink.solid.isNotEmpty) {
      yield _path(ink.solid, {'fill': fill, 'stroke': 'none'});
    }

    if (ink.sketch.isNotEmpty) {
      yield _path(ink.sketch, {
        'fill': 'none',
        'stroke': fill,
        'stroke-width': '1.4',
        'stroke-linecap': 'round',
      });
    }

    if (ink.outline.isNotEmpty) {
      yield _path(ink.outline, {
        'fill': 'none',
        'stroke': mark.stroke.css,
        'stroke-width': width,
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
      });
    }
  }

  static Component _path(String data, Map<String, String> paint) {
    final style = paint.entries.map((e) => '${e.key}:${e.value}').join(';');

    return Component.element(
      tag: 'path',
      attributes: {'d': data, 'style': style},
    );
  }
}

String _number(double value) =>
    value == value.roundToDouble() ? '${value.toInt()}' : '$value';
