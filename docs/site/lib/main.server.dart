/// The entrypoint for the server environment.
library;

import 'package:jaspr/server.dart';

import 'package:jaspr_content/components/callout.dart';
import 'package:jaspr_content/components/github_button.dart';
import 'package:jaspr_content/components/image.dart';
import 'package:jaspr_content/components/theme_toggle.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';

import 'components/site_header.dart';
import 'components/site_docs_layout.dart';
import 'components/site_paths.dart';
import 'components/site_sidebar.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.server.options.dart';

const _rawDocsBasePath = String.fromEnvironment('DOCS_BASE_PATH', defaultValue: '/');

void main() {
  final docsBasePath = normalizeBasePath(_rawDocsBasePath);

  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  runApp(
    ContentApp(
      templateEngine: MustacheTemplateEngine(),
      parsers: [
        MarkdownParser(),
      ],
      extensions: [
        HeadingAnchorsExtension(),
        TableOfContentsExtension(),
      ],
      components: [
        Callout(),
        Image(zoom: true),
      ],
      layouts: [
        SiteDocsLayout(
          basePath: docsBasePath,
          header: SiteHeader(
            basePath: docsRoute(docsBasePath, '/'),
            title: 'Solana Kit Docs',
            logo: docsRoute(docsBasePath, '/images/logo.svg'),
            items: [
              ThemeToggle(),
              GitHubButton(repo: 'openbudgetfun/solana_kit'),
            ],
          ),
          sidebar: SiteSidebar(basePath: docsBasePath),
        ),
      ],
      theme: ContentTheme(
        primary: ThemeColor(ThemeColors.cyan.$600, dark: ThemeColors.cyan.$300),
        background: ThemeColor(ThemeColors.slate.$50, dark: ThemeColors.slate.$950),
        colors: [
          ContentColors.quoteBorders.apply(ThemeColors.cyan.$500),
        ],
      ),
    ),
  );
}
