import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enums.dart';

/// A Helius webhook configuration.
class Webhook {
  /// Creates a webhook configuration.
  const Webhook({
    required this.webhookId,
    required this.wallet,
    required this.webhookUrl,
    required this.transactionTypes,
    required this.accountAddresses,
    required this.webhookType,
    this.authHeader,
  });

  /// Creates a [Webhook] from a JSON map.
  factory Webhook.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return Webhook(
      webhookId: r.requireString('webhookId'),
      wallet: r.requireString('wallet'),
      webhookUrl: r.requireString('webhookUrl'),
      transactionTypes: r.requireList<String>('transactionTypes'),
      accountAddresses: r.requireList<String>('accountAddresses'),
      webhookType: r.optEnum('webhookType', WebhookType.fromJson)!,
      authHeader: r.optString('authHeader'),
    );
  }

  /// Unique identifier of the webhook.
  final String webhookId;

  /// Wallet address that owns the webhook.
  final String wallet;

  /// URL where webhook payloads are delivered.
  final String webhookUrl;

  /// Transaction types that trigger the webhook.
  final List<String> transactionTypes;

  /// Account addresses monitored by the webhook.
  final List<String> accountAddresses;

  /// Delivery format for webhook payloads.
  final WebhookType webhookType;

  /// Optional authorization header sent with webhook deliveries.
  final String? authHeader;

  /// Serializes this webhook to a JSON map.
  Map<String, Object?> toJson() => {
    'webhookId': webhookId,
    'wallet': wallet,
    'webhookUrl': webhookUrl,
    'transactionTypes': transactionTypes,
    'accountAddresses': accountAddresses,
    'webhookType': webhookType.toJson(),
    if (authHeader != null) 'authHeader': authHeader,
  };
}

/// Request to create a new webhook.
class CreateWebhookRequest {
  /// Creates a create-webhook request.
  const CreateWebhookRequest({
    required this.webhookUrl,
    required this.transactionTypes,
    required this.accountAddresses,
    required this.webhookType,
    this.authHeader,
    this.txnStatus,
  });

  /// Creates a [CreateWebhookRequest] from a JSON map.
  factory CreateWebhookRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return CreateWebhookRequest(
      webhookUrl: r.requireString('webhookUrl'),
      transactionTypes: r.requireList<String>('transactionTypes'),
      accountAddresses: r.requireList<String>('accountAddresses'),
      webhookType: r.optEnum('webhookType', WebhookType.fromJson)!,
      authHeader: r.optString('authHeader'),
      txnStatus: r.optString('txnStatus'),
    );
  }

  /// URL where webhook payloads are delivered.
  final String webhookUrl;

  /// Transaction types that trigger the webhook.
  final List<String> transactionTypes;

  /// Account addresses monitored by the webhook.
  final List<String> accountAddresses;

  /// Delivery format for webhook payloads.
  final WebhookType webhookType;

  /// Optional authorization header sent with webhook deliveries.
  final String? authHeader;

  /// Optional filter for the transaction status to deliver.
  final String? txnStatus;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'webhookUrl': webhookUrl,
    'transactionTypes': transactionTypes,
    'accountAddresses': accountAddresses,
    'webhookType': webhookType.toJson(),
    if (authHeader != null) 'authHeader': authHeader,
    if (txnStatus != null) 'txnStatus': txnStatus,
  };
}

/// Request to update an existing webhook.
class UpdateWebhookRequest {
  /// Creates an update-webhook request.
  const UpdateWebhookRequest({
    required this.webhookId,
    this.webhookUrl,
    this.transactionTypes,
    this.accountAddresses,
    this.webhookType,
    this.authHeader,
    this.txnStatus,
  });

  /// Creates an [UpdateWebhookRequest] from a JSON map.
  factory UpdateWebhookRequest.fromJson(Map<String, Object?> json) {
    final r = JsonReader(json);
    return UpdateWebhookRequest(
      webhookId: r.requireString('webhookId'),
      webhookUrl: r.optString('webhookUrl'),
      transactionTypes: r.optList<String>('transactionTypes'),
      accountAddresses: r.optList<String>('accountAddresses'),
      webhookType: r.optEnum('webhookType', WebhookType.fromJson),
      authHeader: r.optString('authHeader'),
      txnStatus: r.optString('txnStatus'),
    );
  }

  /// Unique identifier of the webhook to update.
  final String webhookId;

  /// Updated URL where webhook payloads are delivered.
  final String? webhookUrl;

  /// Updated transaction types that trigger the webhook.
  final List<String>? transactionTypes;

  /// Updated account addresses monitored by the webhook.
  final List<String>? accountAddresses;

  /// Updated delivery format for webhook payloads.
  final WebhookType? webhookType;

  /// Updated authorization header sent with webhook deliveries.
  final String? authHeader;

  /// Updated filter for the transaction status to deliver.
  final String? txnStatus;

  /// Serializes this request to a JSON map.
  Map<String, Object?> toJson() => {
    'webhookId': webhookId,
    if (webhookUrl != null) 'webhookUrl': webhookUrl,
    if (transactionTypes != null) 'transactionTypes': transactionTypes,
    if (accountAddresses != null) 'accountAddresses': accountAddresses,
    if (webhookType != null) 'webhookType': webhookType!.name,
    if (authHeader != null) 'authHeader': authHeader,
    if (txnStatus != null) 'txnStatus': txnStatus,
  };
}
