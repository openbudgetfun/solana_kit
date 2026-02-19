import 'package:http/http.dart' as http;
import 'package:solana_kit_helius/src/auth/auth_client.dart';
import 'package:solana_kit_helius/src/das/das_client.dart';
import 'package:solana_kit_helius/src/enhanced/enhanced_client.dart';
import 'package:solana_kit_helius/src/helius_config.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/priority_fee/priority_fee_client.dart';
import 'package:solana_kit_helius/src/rpc_v2/rpc_v2_client.dart';
import 'package:solana_kit_helius/src/staking/staking_client.dart';
import 'package:solana_kit_helius/src/transactions/transactions_client.dart';
import 'package:solana_kit_helius/src/wallet/wallet_client.dart';
import 'package:solana_kit_helius/src/webhooks/webhooks_client.dart';
import 'package:solana_kit_helius/src/websockets/helius_websocket.dart';
import 'package:solana_kit_helius/src/zk/zk_client.dart';

/// Creates a [HeliusClient] from a [HeliusConfig].
///
/// Optionally pass an [http.Client] via [client] for testability.
HeliusClient createHelius(HeliusConfig config, {http.Client? client}) {
  final effectiveClient = client ?? http.Client();
  final rpcClient = JsonRpcClient(url: config.rpcUrl, client: effectiveClient);
  final restClient = RestClient(
    baseUrl: config.restBaseUrl,
    client: effectiveClient,
  );
  final senderClient = RestClient(
    baseUrl: config.senderBaseUrl,
    client: effectiveClient,
  );

  return HeliusClient._(
    config: config,
    das: DasClient(rpcClient: rpcClient),
    priorityFee: PriorityFeeClient(rpcClient: rpcClient),
    rpcV2: RpcV2Client(rpcClient: rpcClient),
    enhanced: EnhancedClient(restClient: restClient, apiKey: config.apiKey),
    webhooks: WebhooksClient(restClient: restClient, apiKey: config.apiKey),
    zk: ZkClient(rpcClient: rpcClient),
    transactions: TransactionsClient(
      rpcClient: rpcClient,
      restClient: senderClient,
      senderUrl: config.senderBaseUrl,
    ),
    staking: StakingClient(
      restClient: RestClient(
        baseUrl: config.stakingBaseUrl,
        client: effectiveClient,
      ),
      apiKey: config.apiKey,
    ),
    wallet: WalletClient(restClient: restClient, apiKey: config.apiKey),
    websocket: HeliusWebSocket(url: config.wsUrl),
    auth: AuthClient(
      restClient: RestClient(
        baseUrl: config.authBaseUrl,
        client: effectiveClient,
      ),
      apiKey: config.apiKey,
    ),
  );
}

/// The main Helius SDK client.
///
/// Provides typed access to all Helius API modules via sub-client objects.
/// Use [createHelius] to construct an instance.
class HeliusClient {
  HeliusClient._({
    required this.config,
    required this.das,
    required this.priorityFee,
    required this.rpcV2,
    required this.enhanced,
    required this.webhooks,
    required this.zk,
    required this.transactions,
    required this.staking,
    required this.wallet,
    required this.websocket,
    required this.auth,
  });

  /// The configuration used to create this client.
  final HeliusConfig config;

  /// Digital Asset Standard (DAS) API methods.
  final DasClient das;

  /// Priority fee estimation methods.
  final PriorityFeeClient priorityFee;

  /// Enhanced RPC V2 methods with pagination.
  final RpcV2Client rpcV2;

  /// Enhanced transaction history methods.
  final EnhancedClient enhanced;

  /// Webhook management methods.
  final WebhooksClient webhooks;

  /// ZK Compression methods.
  final ZkClient zk;

  /// Smart transaction methods.
  final TransactionsClient transactions;

  /// Staking methods.
  final StakingClient staking;

  /// Wallet API methods.
  final WalletClient wallet;

  /// WebSocket subscription support.
  final HeliusWebSocket websocket;

  /// Auth and project management methods.
  final AuthClient auth;
}
