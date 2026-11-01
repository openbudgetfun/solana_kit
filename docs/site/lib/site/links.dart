/// External links the site points at.
abstract final class SiteLinks {
  /// The workspace repository.
  static const repository = 'https://github.com/openbudgetfun/solana_kit';

  /// Where to report problems.
  static const issues = '$repository/issues';

  /// The umbrella package on pub.dev.
  static const pubDev = 'https://pub.dev/packages/solana_kit';

  /// The generated API reference for the umbrella package.
  static const apiReference =
      'https://pub.dev/documentation/solana_kit/latest/';

  /// The upstream TypeScript SDK this workspace ports.
  static const upstreamKit = 'https://github.com/anza-xyz/kit';

  /// The design system the site is drawn with.
  static const skribble = 'https://skribble.dev/';

  /// Where a docs page's Markdown lives, for "Edit this page" links.
  static String editPage(String contentPath) =>
      '$repository/edit/main/docs/site/content/$contentPath';

  /// Where a runnable example lives.
  static String example(String file) => '$repository/blob/main/examples/$file';
}
