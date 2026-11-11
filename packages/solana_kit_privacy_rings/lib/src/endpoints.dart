/// Resolved Privacy Rings service URLs.
///
/// Resolution matches `resolveClientEndpoints` in
/// `sdk-libs/ts/src/endpoint.ts`. A Helius RPC root
/// (`https://mainnet.helius-rpc.com/?api-key=`) lends the indexer and the
/// prover its `/v1/spr` path. A named indexer or prover URL is used as given.
class PrivacyRingsEndpoints {
  /// Creates resolved endpoints.
  const PrivacyRingsEndpoints({
    required this.solanaRpc,
    required this.indexer,
    required this.prover,
  });

  /// Local validator, indexer, and prover ports.
  factory PrivacyRingsEndpoints.localnet() => resolvePrivacyRingsEndpoints();

  /// Solana JSON-RPC used to read public balances and submit transactions.
  final Uri solanaRpc;

  /// Indexer base. Method calls append `/{method}`.
  final Uri indexer;

  /// Prover base. Proof calls append `/prove/{circuit}`.
  final Uri prover;
}

const _localRpc = 'http://127.0.0.1:8899';
const _localIndexer = 'http://127.0.0.1:8784';
const _localProver = 'http://127.0.0.1:3001';

/// Resolves [solanaRpcUrl], [indexerUrl], and [proverUrl].
///
/// A service with no URL of its own inherits [solanaRpcUrl]. When that URL
/// is a Helius RPC host with an empty path, the inherited URL's path becomes
/// `/v1/spr` and its query, including `api-key`, is kept. With no URLs at
/// all, the local stack ports are used.
PrivacyRingsEndpoints resolvePrivacyRingsEndpoints({
  Uri? solanaRpcUrl,
  Uri? indexerUrl,
  Uri? proverUrl,
}) {
  final solana = solanaRpcUrl ?? Uri.parse(_localRpc);
  return PrivacyRingsEndpoints(
    solanaRpc: solana,
    indexer: indexerUrl ?? _inherit(solanaRpcUrl, _localIndexer),
    prover: proverUrl ?? _inherit(solanaRpcUrl, _localProver),
  );
}

Uri _inherit(Uri? solanaRpcUrl, String local) {
  if (solanaRpcUrl == null) return Uri.parse(local);
  return _sprGateway(solanaRpcUrl) ?? solanaRpcUrl;
}

/// Rewrites a Helius RPC root to `/v1/spr`. Any other URL is returned unchanged
/// as null so the caller keeps the original.
Uri? _sprGateway(Uri rpc) {
  final host = rpc.host;
  final helius = host == 'helius-rpc.com' || host.endsWith('.helius-rpc.com');
  if (!helius) return null;
  if (rpc.path.replaceAll(RegExp(r'/+$'), '').isNotEmpty) return null;
  return rpc.replace(path: '/v1/spr');
}
