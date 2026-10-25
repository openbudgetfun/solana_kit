/// Regional Helius sender endpoints for SWQOS transaction submission.
enum SenderRegion {
  /// Global HTTPS endpoint suitable for browser and frontend applications.
  defaultRegion('Default'),

  /// Salt Lake City, USA.
  usSlc('US_SLC'),

  /// Newark, USA.
  usEast('US_EAST'),

  /// London, UK.
  euWest('EU_WEST'),

  /// Frankfurt, Germany.
  euCentral('EU_CENTRAL'),

  /// Amsterdam, Netherlands.
  euNorth('EU_NORTH'),

  /// Singapore.
  apSingapore('AP_SINGAPORE'),

  /// Tokyo, Japan.
  apTokyo('AP_TOKYO');

  const SenderRegion(this.value);

  /// Upstream Helius sender region key.
  final String value;
}

/// Helius sender endpoint URLs keyed by region.
///
/// Only the default region serves HTTPS. The regional endpoints are plain
/// `http://` (upstream Helius infrastructure), so transactions sent through
/// them — fully signed and therefore valid on submission — travel in
/// cleartext. The URL helpers reject these endpoints by default and always
/// reject them in release builds, even with `allowInsecureHttpForTesting`.
/// Use [SenderRegion.defaultRegion] for HTTPS with automatic region routing.
const senderEndpoints = <SenderRegion, String>{
  SenderRegion.defaultRegion: 'https://sender.helius-rpc.com',
  SenderRegion.usSlc: 'http://slc-sender.helius-rpc.com',
  SenderRegion.usEast: 'http://ewr-sender.helius-rpc.com',
  SenderRegion.euWest: 'http://lon-sender.helius-rpc.com',
  SenderRegion.euCentral: 'http://fra-sender.helius-rpc.com',
  SenderRegion.euNorth: 'http://ams-sender.helius-rpc.com',
  SenderRegion.apSingapore: 'http://sg-sender.helius-rpc.com',
  SenderRegion.apTokyo: 'http://tyo-sender.helius-rpc.com',
};

/// Tip account addresses used by the Helius sender infrastructure.
const senderTipAccounts = <String>[
  '4ACfpUFoaSD9bfPdeu6DBt89gB6ENTeHBXCAi87NhDEE',
  'D2L6yPZ2FmmmTKPgzaMKdhu6EWZcTpLy1Vhx8uvZe7NZ',
  '9bnz4RShgq1hAnLnZbP8kbgBg1kEmcJBYQq3gQbmnSta',
  '5VY91ws6B2hMmBFRsXkoAAdsPHBJwRfBht4DXox3xkwn',
  '2nyhqdwKcJZR2vcqCyrYsaPVdAnFoJjiksCXJ7hfEYgD',
  '2q5pghRs6arqVjRvT5gfgWfWcHWmw1ZuCzphgd5KfWGJ',
  'wyvPkWjVZz1M8fHQnMMCDTQDbkManefNNhweYk5WkcF',
  '3KCKozbAaF75qEU33jtzozcJ29yJuaLJTy2jFdzUY8bT',
  '4vieeGHPYPG2MmyPRcYjdiDmmhN3ww7hsFNap8pVN3Ey',
  '4TQLFNWK8AovT1gFvda5jfw2oJeRMKEmw7aH6MGBJ3or',
];

/// Minimum tip for Sender Max (dual SWQOS + Jito) submission: 0.001 SOL.
const int minTipLamportsMax = 1000000;

/// Minimum tip for SWQOS-only submission: 0.000005 SOL.
///
/// Upstream Sender Max lowered this floor from 0.0005 SOL (500,000 lamports)
/// to 0.000005 SOL (5,000 lamports) in v3.1.0.
const minTipLamportsSwqos = 5000;

/// Builds the `/fast` endpoint URL for a sender [region].
///
/// {@template helius-sender-transport}
/// Throws [ArgumentError] for HTTP endpoints unless
/// [allowInsecureHttpForTesting] is explicitly enabled in a non-release build.
/// This override exposes signed transactions to network observers and is only
/// for controlled tests. Release builds always require HTTPS.
/// {@endtemplate}
String senderFastUrl(
  SenderRegion region, {
  bool allowInsecureHttpForTesting = false,
}) => _senderUrl(
  region,
  'fast',
  allowInsecureHttpForTesting: allowInsecureHttpForTesting,
);

/// Builds the `/ping` endpoint URL for a sender [region].
///
/// {@macro helius-sender-transport}
String senderPingUrl(
  SenderRegion region, {
  bool allowInsecureHttpForTesting = false,
}) => _senderUrl(
  region,
  'ping',
  allowInsecureHttpForTesting: allowInsecureHttpForTesting,
);

/// Validates transport before a caller can send signed transactions.
String _senderUrl(
  SenderRegion region,
  String path, {
  required bool allowInsecureHttpForTesting,
}) {
  final endpoint = senderEndpoints[region]!;
  const isProduction = bool.fromEnvironment('dart.vm.product');

  // Security: the provider's regional hosts only serve HTTP. Never expose a
  // signed transaction by selecting a region, including in release builds.
  if (Uri.parse(endpoint).scheme != 'https' &&
      (isProduction || !allowInsecureHttpForTesting)) {
    throw ArgumentError.value(
      region,
      'region',
      'Regional Helius Sender endpoints use insecure HTTP. '
          'Use SenderRegion.defaultRegion for HTTPS. '
          'allowInsecureHttpForTesting is only supported in non-release builds.',
    );
  }

  return '$endpoint/$path';
}
