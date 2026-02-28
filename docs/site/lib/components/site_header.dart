import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'package:jaspr_content/components/sidebar_toggle_button.dart';

/// A header component that supports custom docs base paths.
class SiteHeader extends StatelessComponent {
  const SiteHeader({
    required this.basePath,
    required this.logo,
    required this.title,
    this.leading = const [SidebarToggleButton()],
    this.items = const [],
    super.key,
  });

  final String basePath;
  final String logo;
  final String title;
  final List<Component> leading;
  final List<Component> items;

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      Document.head(children: [Style(styles: _styles)]),
      header(classes: 'header', [
        ...leading,
        a(classes: 'header-title', href: basePath, [
          img(src: logo, alt: 'Solana Kit'),
          span([Component.text(title)]),
        ]),
        div(classes: 'header-content', [
          div(classes: 'header-items', items),
        ]),
      ]),
    ]);
  }

  static List<StyleRule> get _styles => [
    css('.header', [
      css('&').styles(
        height: 4.rem,
        display: Display.flex,
        alignItems: AlignItems.center,
        gap: Gap.column(1.rem),
        padding: Padding.symmetric(horizontal: 1.rem, vertical: .25.rem),
        margin: Margin.symmetric(horizontal: Unit.auto),
        border: Border.only(
          bottom: BorderSide(color: Color('#0000000d'), width: 1.px),
        ),
      ),
      css.media(MediaQuery.all(minWidth: 768.px), [css('&').styles(padding: Padding.symmetric(horizontal: 2.5.rem))]),
      css('.header-title', [
        css('&').styles(
          display: Display.inlineFlex,
          flex: Flex(basis: 17.rem),
          alignItems: AlignItems.center,
          gap: Gap.column(.75.rem),
        ),
        css('img').styles(height: 1.5.rem, width: Unit.auto),
        css('span').styles(fontWeight: FontWeight.w700),
      ]),
      css('.header-content', [
        css('&').styles(
          display: Display.flex,
          flex: Flex(grow: 1),
          justifyContent: JustifyContent.end,
        ),
      ]),
      css('.header-items', [
        css('&').styles(
          display: Display.flex,
          gap: Gap.column(0.25.rem),
        ),
      ]),
    ]),
  ];
}
