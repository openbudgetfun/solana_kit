/// The documentation's information architecture.
///
/// Every page under `content/docs/` appears here exactly once, in reading
/// order. The sidebar, the previous/next pager, and the redirects from the
/// pre-`/docs/` URLs are all derived from this list, so a page cannot be
/// reachable from one of them and missing from the others.
library;

/// A page in the documentation sidebar.
final class DocsPage {
  /// Creates a page served at [route] with a sidebar [title].
  const DocsPage(this.title, this.route, {this.legacyRoute});

  /// The label shown in the sidebar and pager.
  final String title;

  /// The page's route, without the deployment base path, such as
  /// `/docs/core/codecs`.
  final String route;

  /// Where the page lived before the docs moved under `/docs/`, such as
  /// `/core/codecs`. Published package READMEs link to these URLs, so each
  /// one keeps redirecting to [route].
  final String? legacyRoute;
}

/// A titled group of pages in the sidebar.
final class DocsSection {
  /// Creates a section with a [title], short [blurb], and [pages].
  const DocsSection(this.title, this.blurb, this.pages);

  /// The group heading.
  final String title;

  /// One line describing what the section covers.
  final String blurb;

  /// The pages in reading order.
  final List<DocsPage> pages;
}

/// The documentation sections in reading order.
const docsSections = [
  DocsSection('Get started', 'Install the SDK and send a first transaction.', [
    DocsPage('Overview', '/docs'),
    DocsPage(
      'Installation',
      '/docs/getting-started/installation',
      legacyRoute: '/getting-started/installation',
    ),
    DocsPage(
      'Quick start',
      '/docs/getting-started/quick-start',
      legacyRoute: '/getting-started/quick-start',
    ),
    DocsPage(
      'Generate a signer',
      '/docs/getting-started/generate-a-signer',
      legacyRoute: '/getting-started/generate-a-signer',
    ),
    DocsPage(
      'Fetch an account',
      '/docs/getting-started/fetch-an-account',
      legacyRoute: '/getting-started/fetch-an-account',
    ),
    DocsPage(
      'Create instructions',
      '/docs/getting-started/create-instructions',
      legacyRoute: '/getting-started/create-instructions',
    ),
    DocsPage(
      'Build a transaction',
      '/docs/getting-started/build-a-transaction',
      legacyRoute: '/getting-started/build-a-transaction',
    ),
    DocsPage(
      'First transaction',
      '/docs/getting-started/first-transaction',
      legacyRoute: '/getting-started/first-transaction',
    ),
  ]),
  DocsSection('Core concepts', 'How the pieces of the SDK fit together.', [
    DocsPage(
      'Architecture',
      '/docs/core/architecture',
      legacyRoute: '/core/architecture',
    ),
    DocsPage('Accounts', '/docs/core/accounts', legacyRoute: '/core/accounts'),
    DocsPage('Codecs', '/docs/core/codecs', legacyRoute: '/core/codecs'),
    DocsPage('Signers', '/docs/core/signers', legacyRoute: '/core/signers'),
    DocsPage(
      'Transactions',
      '/docs/core/transactions',
      legacyRoute: '/core/transactions',
    ),
    DocsPage(
      'RPC & subscriptions',
      '/docs/core/rpc-and-subscriptions',
      legacyRoute: '/core/rpc-and-subscriptions',
    ),
    DocsPage(
      'Errors & diagnostics',
      '/docs/core/errors-and-diagnostics',
      legacyRoute: '/core/errors-and-diagnostics',
    ),
  ]),
  DocsSection('Guides', 'End-to-end walkthroughs for real integrations.', [
    DocsPage(
      'Build an RPC service',
      '/docs/guides/build-rpc-service',
      legacyRoute: '/guides/build-rpc-service',
    ),
    DocsPage(
      'Build a token transfer flow',
      '/docs/guides/build-token-transfer-flow',
      legacyRoute: '/guides/build-token-transfer-flow',
    ),
    DocsPage(
      'Build a program client',
      '/docs/guides/build-program-client',
      legacyRoute: '/guides/build-program-client',
    ),
    DocsPage(
      'Build a realtime observer',
      '/docs/guides/build-realtime-observer',
      legacyRoute: '/guides/build-realtime-observer',
    ),
  ]),
  DocsSection('Flutter & mobile', 'Wallets, UI kits, and app distribution.', [
    DocsPage(
      'Mobile Wallet Adapter',
      '/docs/guides/mobile-wallet-adapter',
      legacyRoute: '/guides/mobile-wallet-adapter',
    ),
    DocsPage(
      'Wallet UI',
      '/docs/guides/wallet-ui',
      legacyRoute: '/guides/wallet-ui',
    ),
    DocsPage(
      'Publish to the dApp Store',
      '/docs/guides/publish-dapp-store',
      legacyRoute: '/guides/publish-dapp-store',
    ),
  ]),
  DocsSection('Programs', 'Typed clients for on-chain programs.', [
    DocsPage(
      'Attestation service',
      '/docs/programs/attestation-service-overview',
      legacyRoute: '/guides/attestation-service-overview',
    ),
    DocsPage(
      'Subscriptions overview',
      '/docs/programs/subscriptions-overview',
      legacyRoute: '/guides/subscriptions-overview',
    ),
    DocsPage(
      'Subscription authority',
      '/docs/programs/subscriptions-authority',
      legacyRoute: '/guides/subscriptions-authority',
    ),
    DocsPage(
      'Fixed delegation',
      '/docs/programs/subscriptions-fixed-delegation',
      legacyRoute: '/guides/subscriptions-fixed-delegation',
    ),
    DocsPage(
      'Recurring delegation',
      '/docs/programs/subscriptions-recurring-delegation',
      legacyRoute: '/guides/subscriptions-recurring-delegation',
    ),
    DocsPage(
      'Subscription plans',
      '/docs/programs/subscriptions-plan',
      legacyRoute: '/guides/subscriptions-plan',
    ),
    DocsPage(
      'Close an authority',
      '/docs/programs/subscriptions-close-authority',
      legacyRoute: '/guides/subscriptions-close-authority',
    ),
  ]),
  DocsSection('Reference', 'Packages, versions, and upstream parity.', [
    DocsPage(
      'Package index',
      '/docs/reference/package-index',
      legacyRoute: '/reference/package-index',
    ),
    DocsPage(
      'Package catalog',
      '/docs/reference/package-catalog',
      legacyRoute: '/reference/package-catalog',
    ),
    DocsPage(
      'Upstream compatibility',
      '/docs/reference/upstream-compatibility',
      legacyRoute: '/reference/upstream-compatibility',
    ),
  ]),
  DocsSection('Contributing', 'Work on the SDK itself.', [
    DocsPage(
      'Contributing',
      '/docs/contributing',
      legacyRoute: '/contributing',
    ),
    DocsPage(
      'Benchmarking',
      '/docs/contributing/benchmarking',
      legacyRoute: '/guides/benchmarking',
    ),
    DocsPage(
      'Release process',
      '/docs/contributing/release-process',
      legacyRoute: '/guides/release-process',
    ),
  ]),
];

/// Every documentation page in reading order.
final List<DocsPage> allDocsPages = [
  for (final section in docsSections) ...section.pages,
];

/// Strips a trailing slash so `/docs/` and `/docs` compare equal.
String normalizeRoute(String route) => route.length > 1 && route.endsWith('/')
    ? route.substring(0, route.length - 1)
    : route;

/// Finds the page served at [route], or null when it is not in the docs.
DocsPage? docsPageFor(String route) {
  final normalized = normalizeRoute(route);

  for (final page in allDocsPages) {
    if (page.route == normalized) return page;
  }

  return null;
}

/// Finds the section containing the page at [route].
DocsSection? docsSectionFor(String route) {
  final normalized = normalizeRoute(route);

  for (final section in docsSections) {
    if (section.pages.any((page) => page.route == normalized)) return section;
  }

  return null;
}

/// The pages before and after [route] in reading order.
({DocsPage? previous, DocsPage? next}) neighboursOf(String route) {
  final index = allDocsPages.indexWhere(
    (page) => page.route == normalizeRoute(route),
  );

  if (index == -1) return (previous: null, next: null);

  return (
    previous: index > 0 ? allDocsPages[index - 1] : null,
    next: index < allDocsPages.length - 1 ? allDocsPages[index + 1] : null,
  );
}

/// The content file that serves [page], relative to `content/`.
String contentPathFor(DocsPage page) {
  final relative = page.route.substring(1);
  final hasChildren = allDocsPages.any(
    (other) => other.route.startsWith('${page.route}/'),
  );

  return hasChildren ? '$relative/index.md' : '$relative.md';
}
