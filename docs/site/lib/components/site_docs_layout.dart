import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

/// A DocsLayout variant that enforces a deployment base path.
class SiteDocsLayout extends DocsLayout {
  /// Creates a docs layout that emits links relative to [basePath].
  const SiteDocsLayout({
    required this.basePath,
    super.header,
    super.sidebar,
    super.footer,
  });

  /// Base path where the documentation site is deployed.
  final String basePath;

  @override
  Component buildLayout(Page page, Component child) {
    final lang = switch (page.data) {
      {'page': {'lang': final String lang}} => lang,
      {'site': {'lang': final String lang}} => lang,
      _ => null,
    };

    return Document(
      lang: lang,
      base: basePath,
      head: buildHead(page).toList(),
      body: buildBody(page, child),
    );
  }
}
