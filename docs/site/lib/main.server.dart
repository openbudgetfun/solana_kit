/// The entrypoint for the server environment.
library;

import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';
import 'package:solana_kit_docs_site/components/site_paths.dart';
import 'package:solana_kit_docs_site/components/sketch_code.dart';
import 'package:solana_kit_docs_site/components/sketch_content.dart';
import 'package:solana_kit_docs_site/components/wallet_demo_frame.dart';
import 'package:solana_kit_docs_site/layouts/docs_layout.dart';
import 'package:solana_kit_docs_site/layouts/landing_layout.dart';
import 'package:solana_kit_docs_site/layouts/redirect_page.dart';
// This file is generated automatically by Jaspr, do not remove or edit.
import 'package:solana_kit_docs_site/main.server.options.dart';
import 'package:solana_kit_docs_site/site/workspace_data.dart';

const _rawDocsBasePath = String.fromEnvironment(
  'DOCS_BASE_PATH',
  defaultValue: '/',
);

void main() {
  final docsBasePath = normalizeBasePath(_rawDocsBasePath);
  final workspace = WorkspaceData.load();

  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    ContentApp.custom(
      loaders: [
        FilesystemLoader('content'),
        MemoryLoader(pages: legacyRedirectPages(docsBasePath)),
      ],
      configResolver: PageConfig.all(
        dataLoaders: [FilesystemDataLoader('content/_data')],
        templateEngine: const MustacheTemplateEngine(),
        parsers: const [MarkdownParser()],
        extensions: [
          HeadingAnchorsExtension(),
          const TableOfContentsExtension(),
        ],
        components: [
          const SketchCodeBlocks(),
          ...sketchContentComponents,
          WalletDemoFrame(),
        ],
        layouts: [
          // The first layout is the default for pages without `layout:`.
          SiteDocsLayout(basePath: docsBasePath),
          LandingLayout(basePath: docsBasePath, workspace: workspace),
        ],
        // The site ships its own stylesheet (web/site.css), so the default
        // content theme's reset and typography are left out.
        theme: const ContentTheme.none(),
      ),
    ),
  );
}
