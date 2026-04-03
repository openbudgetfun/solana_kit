// ignore_for_file: public_member_api_docs
import 'package:solana_kit_helius/src/internal/json_reader.dart';
import 'package:solana_kit_helius/src/types/enums.dart';

/// A Helius webhook configuration.
class Webhook {
  const Webhook({
    required this.webhookId,
    required this.wallet,
    required this.webhookUrl,
    required this.transactionTypes,
    required this.accountAddresses,
    required this.webhookType,
    this.authHeader,
  });

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

  final String webhookId;
  final String wallet;
  final String webhookUrl;
  final List<String> transactionTypes;
  final List<String> accountAddresses;
  final WebhookType webhookType;
  final String? authHeader;

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
  const CreateWebhookRequest({
    required this.webhookUrl,
    required this.transactionTypes,
    required this.accountAddresses,
    required this.webhookType,
    this.authHeader,
    this.txnStatus,
  });

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

  final String webhookUrl;
  final List<String> transactionTypes;
  final List<String> accountAddresses;
  final WebhookType webhookType;
  final String? authHeader;
  final String? txnStatus;

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
  const UpdateWebhookRequest({
    required this.webhookId,
    this.webhookUrl,
    this.transactionTypes,
    this.accountAddresses,
    this.webhookType,
    this.authHeader,
    this.txnStatus,
  });

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

  final String webhookId;
  final String? webhookUrl;
  final List<String>? transactionTypes;
  final List<String>? accountAddresses;
  final WebhookType? webhookType;
  final String? authHeader;
  final String? txnStatus;

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
