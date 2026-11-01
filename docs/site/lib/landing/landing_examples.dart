/// The examples the landing page shows, each quoting a `landing` region
/// from a runnable, CI-checked file in `examples/`.
library;

/// One tab of the landing page's example switcher.
final class LandingExample {
  /// Creates an example tab.
  const LandingExample({
    required this.id,
    required this.tab,
    required this.title,
    required this.summary,
    required this.points,
    required this.file,
    required this.guideLabel,
    required this.guideRoute,
  });

  /// The tab's DOM id suffix.
  final String id;

  /// The short tab label.
  final String tab;

  /// The panel heading.
  final String title;

  /// One or two sentences on what the code does.
  final String summary;

  /// What the reader gets from the APIs shown.
  final List<String> points;

  /// The example file in `examples/` the snippet comes from.
  final String file;

  /// The label for the follow-up docs link.
  final String guideLabel;

  /// The docs route that explains the code in depth.
  final String guideRoute;
}

/// The example tabs, in display order.
const landingExamples = [
  LandingExample(
    id: 'accounts',
    tab: 'Read accounts',
    title: 'Fetch on-chain state',
    summary:
        'Create an RPC client, then ask for an account. The response '
        'carries its context slot and a value that is null when the account '
        'does not exist.',
    points: [
      'Every RPC method returns a pending request you send when ready',
      'Typed configs such as GetAccountInfoConfig instead of raw maps',
      'Missing accounts are a null value, not an exception',
    ],
    file: '15_get_account_info.dart',
    guideLabel: 'Fetch an account',
    guideRoute: '/docs/getting-started/fetch-an-account',
  ),
  LandingExample(
    id: 'transactions',
    tab: 'Send a transaction',
    title: 'Build, sign, send, confirm',
    summary:
        'Transaction messages are immutable values you build up step by '
        'step, then compile, sign with any signer, and confirm.',
    points: [
      'A fluent, immutable message builder',
      'Signers are interfaces, so key pairs and wallets are interchangeable',
      'Confirmation strategies are built in',
    ],
    file: '23_transaction_send_and_confirm.dart',
    guideLabel: 'First transaction',
    guideRoute: '/docs/getting-started/first-transaction',
  ),
  LandingExample(
    id: 'subscriptions',
    tab: 'Stream updates',
    title: 'Subscribe over WebSockets',
    summary:
        'Subscriptions are Dart streams. Pass a cancellation token to tear '
        'the socket subscription down cleanly.',
    points: [
      'Channel pooling and autopinging out of the box',
      'Cancellation tokens instead of dangling listeners',
      'Every notification method from the Solana RPC',
    ],
    file: '16_rpc_subscriptions.dart',
    guideLabel: 'Build a realtime observer',
    guideRoute: '/docs/guides/build-realtime-observer',
  ),
  LandingExample(
    id: 'codecs',
    tab: 'Encode data',
    title: 'Describe byte layouts with codecs',
    summary:
        'Compose small codecs into a struct that encodes and decodes an '
        'account layout. Field order is byte order.',
    points: [
      'Numbers, strings, arrays, options, enums, and structs',
      'Fixed and variable sizes that you can see in the types',
      'The same codec model as @solana/kit, in idiomatic Dart',
    ],
    file: '07_struct_codec.dart',
    guideLabel: 'Codecs',
    guideRoute: '/docs/core/codecs',
  ),
  LandingExample(
    id: 'programs',
    tab: 'Program clients',
    title: 'Call programs through typed clients',
    summary:
        'Generated program clients build instructions and multi-step '
        'instruction plans, with every account named.',
    points: [
      'System, Token, Token-2022, Stake, Memo, Metaplex, and more',
      'Instruction plans for flows that span several transactions',
      'Generate your own client from an IDL with the Codama renderer',
    ],
    file: '28_program_clients.dart',
    guideLabel: 'Build a program client',
    guideRoute: '/docs/guides/build-program-client',
  ),
  LandingExample(
    id: 'addresses',
    tab: 'Derive PDAs',
    title: 'Derive program addresses',
    summary:
        'Program-derived addresses come back as a record of address and '
        'bump, ready to destructure.',
    points: [
      'Address is an extension type: free at runtime, checked at compile time',
      'String and byte seeds',
      'Curve checks for keys and PDAs',
    ],
    file: '04_program_derived_address.dart',
    guideLabel: 'solana_kit_addresses',
    guideRoute: '/docs/reference/package-catalog#solana_kit_addresses',
  ),
];
