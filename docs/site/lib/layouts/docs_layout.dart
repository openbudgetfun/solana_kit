import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:solana_kit_docs_site/components/site_footer.dart';
import 'package:solana_kit_docs_site/components/site_header.dart';
import 'package:solana_kit_docs_site/layouts/site_layout.dart';
import 'package:solana_kit_docs_site/site/ink.dart';
import 'package:solana_kit_docs_site/site/links.dart';
import 'package:solana_kit_docs_site/site/navigation.dart';

/// The documentation layout: sidebar, article, table of contents, and a
/// previous/next pager, all drawn by hand.
class SiteDocsLayout extends SiteLayout {
  /// Creates the docs layout for a site deployed at [basePath].
  const SiteDocsLayout({required super.basePath});

  @override
  String get name => 'docs';

  @override
  String get bodyClasses => 'docs-page';

  @override
  Component buildBody(Page page, Component child) {
    final route = normalizeRoute(page.url);
    final pageHref = asset(route);
    final docsPage = docsPageFor(route);
    final section = docsSectionFor(route);
    final title = page.data.page['title'] as String? ?? docsPage?.title;
    final description = page.data.page['description'] as String?;
    final (:previous, :next) = neighboursOf(route);

    return Component.fragment([
      a(
        classes: 'skip-link',
        href: '$pageHref#content',
        const [Component.text('Skip to content')],
      ),
      SiteHeader(basePath: basePath, currentRoute: route, showMenuButton: true),
      div(classes: 'docs-shell', [
        aside(
          id: 'docs-sidebar',
          classes: 'docs-sidebar',
          attributes: const {'aria-label': 'Documentation'},
          [_sidebar(route)],
        ),
        const div(
          classes: 'sidebar-scrim',
          attributes: {'data-sidebar-close': '', 'hidden': ''},
          [],
        ),
        main_(id: 'content', classes: 'docs-main', [
          article(classes: 'docs-article', [
            header(classes: 'docs-article-header', [
              if (section != null)
                p(classes: 'eyebrow', [Component.text(section.title)]),
              if (title != null)
                h1([
                  WiredHighlight(
                    seed: seedFor(title),
                    color: Tone.coral.css,
                    child: Component.text(title),
                  ),
                ]),
              if (description != null)
                p(classes: 'lede', [Component.text(description)]),
            ]),
            child,
            footer(classes: 'docs-article-footer', [
              if (docsPage != null)
                p(classes: 'edit-link', [
                  a(href: SiteLinks.editPage(contentPathFor(docsPage)), const [
                    Component.text('Edit this page on GitHub'),
                  ]),
                ]),
              nav(
                classes: 'pager',
                attributes: const {'aria-label': 'Previous and next pages'},
                [
                  if (previous != null) _pagerCard(previous, isNext: false),
                  if (next != null) _pagerCard(next, isNext: true),
                ],
              ),
            ]),
          ]),
          aside(
            classes: 'docs-toc',
            attributes: const {'aria-label': 'On this page'},
            [
              if (page.data['toc']
                  case TableOfContents(
                    :final entries,
                  )
                  when entries.isNotEmpty)
                div(classes: 'docs-toc-inner', [
                  const p(classes: 'eyebrow', [Component.text('On this page')]),
                  _tocList(entries, pageHref),
                ]),
            ],
          ),
        ]),
      ]),
      SiteFooter(basePath: basePath),
    ]);
  }

  Component _sidebar(String route) {
    return nav(classes: 'sidebar-nav', [
      for (final section in docsSections)
        div(classes: 'sidebar-group', [
          h2([Component.text(section.title)]),
          ul([
            for (final page in section.pages)
              li([
                a(
                  href: asset(page.route),
                  attributes: {if (page.route == route) 'aria-current': 'page'},
                  [Component.text(page.title)],
                ),
              ]),
          ]),
        ]),
    ]);
  }

  Component _tocList(List<TocEntry> entries, String pageHref) {
    return ul([
      for (final entry in entries)
        li([
          a(href: '$pageHref#${entry.id}', [Component.text(entry.text)]),
          if (entry.children.isNotEmpty) _tocList(entry.children, pageHref),
        ]),
    ]);
  }

  Component _pagerCard(DocsPage page, {required bool isNext}) {
    return a(
      classes: 'pager-link ${isNext ? 'pager-next' : 'pager-previous'}',
      href: asset(page.route),
      attributes: {'rel': isNext ? 'next' : 'prev'},
      [
        WiredBox(
          seed: seedFor(page.route),
          classes: 'pager-card skribble-wobble',
          child: Component.fragment([
            span(classes: 'pager-direction', [
              Component.text(isNext ? 'Next →' : '← Previous'),
            ]),
            span(classes: 'pager-title', [Component.text(page.title)]),
          ]),
        ),
      ],
    );
  }
}
