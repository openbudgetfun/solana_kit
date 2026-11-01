import 'dart:math' as math;

import 'package:jaspr/jaspr.dart';
import 'package:skribble_rough/skribble_rough.dart';
import 'package:solana_kit_docs_site/site/ink.dart';

/// The Solana Kit mark: Solana's three slanted bars, sketched inside a pair
/// of hand-drawn brackets.
class BrandMark extends StatelessComponent {
  /// Creates the mark, [height] pixels tall.
  const BrandMark({this.height = 40, this.seed = 11, super.key});

  /// The rendered height; the width follows the drawing's proportions.
  final double height;

  /// Chooses the wobble.
  final int seed;

  @override
  Component build(BuildContext context) {
    const bars = [
      ([(13.0, 9.0), (35.0, 9.0), (29.0, 16.0), (7.0, 16.0)], Tone.mint),
      ([(7.0, 19.0), (29.0, 19.0), (35.0, 26.0), (13.0, 26.0)], Tone.sky),
      ([(13.0, 29.0), (35.0, 29.0), (29.0, 36.0), (7.0, 36.0)], Tone.lilac),
    ];

    return Doodle(
      width: 42,
      height: 45,
      scale: height / 45,
      classes: 'brand-mark',
      marks: [
        for (final (index, (points, tone)) in bars.indexed)
          InkMark(
            roughPen(
              seed + index,
              roughness: 0.6,
              fill: RoughFillStyle.solid,
            ).polygon([for (final (x, y) in points) PointD(x, y)]),
            fill: tone,
            width: 1.6,
          ),
        for (final (index, side) in const [-1.0, 1.0].indexed)
          InkMark(
            roughPen(seed + 5 + index, roughness: 0.5).linearPath([
              for (final (x, y) in const [(5.0, 2.0), (1.5, 2.5)])
                PointD(_mirror(x, side), y),
              PointD(_mirror(1.5, side), 42.5),
              PointD(_mirror(5, side), 43),
            ]),
            width: 2.4,
          ),
      ],
    );
  }

  static double _mirror(double x, double side) => side < 0 ? x : 42 - x;
}

/// A doodled sun and moon that switch the paper between light and dark.
///
/// `site.js` wires the click and persists the choice; the stylesheet shows
/// the moon on light paper and the sun on dark paper.
class ThemeToggle extends StatelessComponent {
  /// Creates the toggle.
  const ThemeToggle({super.key});

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'button',
      classes: 'theme-toggle',
      attributes: const {
        'type': 'button',
        'data-theme-toggle': '',
        'aria-label': 'Switch between light and dark paper',
        'title': 'Switch between light and dark paper',
      },
      children: [
        Doodle(
          width: 28,
          height: 28,
          classes: 'theme-sun',
          marks: [
            InkMark(
              roughPen(700, fill: RoughFillStyle.solid).ellipse(14, 14, 12, 12),
              fill: Tone.sun,
            ),
            for (var i = 0; i < 8; i++)
              InkMark(
                roughPen(701 + i).line(
                  14 + 8.5 * math.cos(i * math.pi / 4),
                  14 + 8.5 * math.sin(i * math.pi / 4),
                  14 + 12.5 * math.cos(i * math.pi / 4),
                  14 + 12.5 * math.sin(i * math.pi / 4),
                ),
                width: 1.8,
              ),
          ],
        ),
        Doodle(
          width: 28,
          height: 28,
          classes: 'theme-moon',
          marks: [
            InkMark(
              roughPen(710, fill: RoughFillStyle.solid).curvePath([
                for (final (x, y) in const [
                  (18.0, 4.0),
                  (8.0, 7.0),
                  (6.0, 17.0),
                  (13.0, 24.0),
                  (23.0, 21.0),
                  (15.0, 16.0),
                  (18.0, 4.0),
                ])
                  PointD(x, y),
              ]),
              fill: Tone.lilac,
            ),
          ],
        ),
      ],
    );
  }
}
