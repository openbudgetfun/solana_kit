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

/// Minimum tip for dual (SWQOS + Jito) submission: 0.001 SOL.
const minTipLamportsDual = 1000000;

/// Minimum tip for SWQOS-only submission: 0.0005 SOL.
const minTipLamportsSwqos = 500000;

/// Builds the `/fast` endpoint URL for a sender [region].
String senderFastUrl(SenderRegion region) => '${senderEndpoints[region]!}/fast';

/// Builds the `/ping` endpoint URL for a sender [region].
String senderPingUrl(SenderRegion region) => '${senderEndpoints[region]!}/ping';
