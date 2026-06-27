import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/auth/oauth_token_exchange.dart';

class DevPortalConfigsResponse {
  const DevPortalConfigsResponse({required this.stripe, this.openPay});

  factory DevPortalConfigsResponse.fromJson(Map<String, Object?> json) {
    return DevPortalConfigsResponse(
      stripe: StripeConfig.fromJson(json['stripe']! as Map<String, Object?>),
      openPay: json['openPay'] is Map<String, Object?>
          ? StripeConfig.fromJson(json['openPay']! as Map<String, Object?>)
          : null,
    );
  }

  final StripeConfig stripe;
  final StripeConfig? openPay;
}

class StripeConfig {
  const StripeConfig({required this.priceIds, this.prepaidCreditsPlans});

  factory StripeConfig.fromJson(Map<String, Object?> json) {
    return StripeConfig(
      priceIds: PriceIds.fromJson(json['priceIds']! as Map<String, Object?>),
      prepaidCreditsPlans: (json['prepaidCreditsPlans'] as Map?)
          ?.cast<String, String>(),
    );
  }

  final PriceIds priceIds;
  final Map<String, String>? prepaidCreditsPlans;
}

class PriceIds {
  const PriceIds({required this.monthly, required this.yearly, this.agentPlan});

  factory PriceIds.fromJson(Map<String, Object?> json) {
    return PriceIds(
      monthly: (json['Monthly']! as Map).cast<String, String>(),
      yearly: (json['Yearly']! as Map).cast<String, String>(),
      agentPlan: json['AgentPlan'] as String?,
    );
  }

  final Map<String, String> monthly;
  final Map<String, String> yearly;
  final String? agentPlan;
}

Future<DevPortalConfigsResponse> fetchDevPortalConfigs(
  String jwt, {
  bool includeAgentPlan = false,
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final httpClient = client ?? http.Client(); // coverage:ignore-line
  final closeClient = client == null; // coverage:ignore-line
  try {
    final path = includeAgentPlan
        ? '/dev-portal/configs?agent=cli'
        : '/dev-portal/configs';
    final headers = <String, String>{
      'Authorization': 'Bearer $jwt',
      'accept': 'application/json',
    };
    final agent = userAgent;
    if (agent != null) headers['User-Agent'] = agent;
    final response = await httpClient.get(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw createSolanaError(
        SolanaErrorCode.heliusRestError,
        context: {
          SolanaErrorContextKeys.operation: 'heliusDevPortalConfigs',
          SolanaErrorContextKeys.statusCode: response.statusCode,
          'message': response.body,
        },
      );
    }
    return DevPortalConfigsResponse.fromJson(
      jsonDecode(response.body) as Map<String, Object?>,
    );
  } finally {
    if (closeClient) httpClient.close(); // coverage:ignore-line
  }
}

Future<PriceIds> fetchStripePriceIds(
  String jwt, {
  bool includeAgentPlan = false,
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final configs = await fetchDevPortalConfigs(
    jwt,
    includeAgentPlan: includeAgentPlan,
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
  return configs.stripe.priceIds;
}

Future<Map<String, String>> fetchPrepaidCreditsPriceIds(
  String jwt, {
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final configs = await fetchDevPortalConfigs(
    jwt,
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
  return configs.stripe.prepaidCreditsPlans ?? const <String, String>{};
}
