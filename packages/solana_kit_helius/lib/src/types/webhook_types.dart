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
    return Webhook(
      webhookId: json['webhookId']! as String,
      wallet: json['wallet']! as String,
      webhookUrl: json['webhookUrl']! as String,
      transactionTypes: (json['transactionTypes']! as List<Object?>)
          .cast<String>(),
      accountAddresses: (json['accountAddresses']! as List<Object?>)
          .cast<String>(),
      webhookType: WebhookType.fromJson(json['webhookType']! as String),
      authHeader: json['authHeader'] as String?,
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
    return CreateWebhookRequest(
      webhookUrl: json['webhookUrl']! as String,
      transactionTypes: (json['transactionTypes']! as List<Object?>)
          .cast<String>(),
      accountAddresses: (json['accountAddresses']! as List<Object?>)
          .cast<String>(),
      webhookType: WebhookType.fromJson(json['webhookType']! as String),
      authHeader: json['authHeader'] as String?,
      txnStatus: json['txnStatus'] as String?,
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
    return UpdateWebhookRequest(
      webhookId: json['webhookId']! as String,
      webhookUrl: json['webhookUrl'] as String?,
      transactionTypes: (json['transactionTypes'] as List<Object?>?)
          ?.cast<String>(),
      accountAddresses: (json['accountAddresses'] as List<Object?>?)
          ?.cast<String>(),
      webhookType: json['webhookType'] != null
          ? WebhookType.fromJson(json['webhookType']! as String)
          : null,
      authHeader: json['authHeader'] as String?,
      txnStatus: json['txnStatus'] as String?,
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
