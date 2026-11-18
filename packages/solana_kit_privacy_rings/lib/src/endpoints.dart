import 'package:solana_kit_privacy_rings/src/exception.dart';

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

/// Local prover used by the Helius stack.
///
/// The published prover binary listens here with
/// `--prover-address 127.0.0.1:3001`.
const localProverUrl = 'http://127.0.0.1:3001';

/// Helius cluster that hosts the shared RPC, indexer, and prover origin.
enum PrivacyRingsCluster {
  /// `https://mainnet.helius-rpc.com`.
  mainnet('https://mainnet.helius-rpc.com'),

  /// `https://devnet.helius-rpc.com`.
  devnet('https://devnet.helius-rpc.com');

  /// Creates a cluster from its RPC [rpcOrigin].
  const PrivacyRingsCluster(this.rpcOrigin);

  /// RPC origin without a path, query, or API key.
  final String rpcOrigin;

  /// Indexer URL for one Privacy Rings [method].
  ///
  /// The last path segment is the JSON-RPC method name. The name must be
  /// ASCII letters and digits. This URL never carries an API key.
  String indexerUrl(String method) {
    return '$rpcOrigin/v1/spr/${_rpcMethod(method)}';
  }

  /// Prover base URL. Proof calls append `/prove/{circuit}`.
  String get proverUrl => '$rpcOrigin/v1/spr';
}

/// Local Photon indexer URL for one Privacy Rings [method].
///
/// The name must be ASCII letters and digits.
String localIndexerUrl(String method) {
  return '$_localIndexer/${_rpcMethod(method)}';
}

String _rpcMethod(String method) {
  if (method.isEmpty || !RegExp(r'^[0-9A-Za-z]+$').hasMatch(method)) {
    throw PrivacyRingsException(
      'privacy RPC method name is not alphanumeric',
      code: 'invalid_request',
    );
  }
  return method;
}

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
    prover: proverUrl ?? _inherit(solanaRpcUrl, localProverUrl),
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
