import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:solana_kit_docs_site/components/site_footer.dart';
import 'package:solana_kit_docs_site/components/site_header.dart';
import 'package:solana_kit_docs_site/landing/landing_page.dart';
import 'package:solana_kit_docs_site/layouts/site_layout.dart';
import 'package:solana_kit_docs_site/site/workspace_data.dart';

/// The layout for `content/index.md`: the landing page, rendered from Dart.
///
/// The Markdown file only supplies the page title and description; its body
/// is not rendered.
class LandingLayout extends SiteLayout {
  /// Creates the landing layout for a site deployed at [basePath].
  const LandingLayout({required super.basePath, required this.workspace});

  /// Versions and example code read from the workspace.
  final WorkspaceData workspace;

  @override
  String get name => 'landing';

  @override
  String get bodyClasses => 'landing';

  @override
  Component buildBody(Page page, Component child) {
    return Component.fragment([
      a(
        classes: 'skip-link',
        href: '${asset('/')}#content',
        const [Component.text('Skip to content')],
      ),
      SiteHeader(basePath: basePath, currentRoute: '/'),
      main_(id: 'content', [
        LandingPage(basePath: basePath, workspace: workspace),
      ]),
      SiteFooter(basePath: basePath),
    ]);
  }
}
