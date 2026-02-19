import 'package:solana_kit_helius/src/types/enums.dart';

/// Configuration for connecting to Helius APIs.
class HeliusConfig {
  /// Creates a new Helius configuration.
  ///
  /// An [apiKey] is required for all Helius operations.
  /// The [cluster] defaults to [HeliusCluster.mainnet].
  const HeliusConfig({
    required this.apiKey,
    this.cluster = HeliusCluster.mainnet,
  });

  /// The Helius API key.
  final String apiKey;

  /// The Solana cluster to connect to.
  final HeliusCluster cluster;

  /// The Helius RPC URL for JSON-RPC requests (DAS, ZK, priority fees, etc.).
  String get rpcUrl =>
      'https://${cluster.value}.helius-rpc.com/?api-key=$apiKey';

  /// The Helius REST API base URL for REST endpoints (webhooks, enhanced, etc.).
  String get restBaseUrl => switch (cluster) {
    HeliusCluster.mainnet => 'https://api.helius.xyz',
    HeliusCluster.devnet => 'https://api-devnet.helius.xyz',
  };

  /// The Helius REST API base URL with API key as query parameter.
  String get restUrl => '$restBaseUrl/v0?api-key=$apiKey';

  /// The Helius WebSocket URL.
  String get wsUrl => 'wss://${cluster.value}.helius-rpc.com/?api-key=$apiKey';

  /// The Helius staking API base URL.
  String get stakingBaseUrl => 'https://staking-api.helius.xyz';

  /// The Helius auth API base URL.
  String get authBaseUrl => 'https://auth-api.helius.xyz';

  /// The Helius sender API base URL.
  String get senderBaseUrl => switch (cluster) {
    HeliusCluster.mainnet => 'https://mainnet.helius-rpc.com/?api-key=$apiKey',
    HeliusCluster.devnet => 'https://devnet.helius-rpc.com/?api-key=$apiKey',
  };
}
