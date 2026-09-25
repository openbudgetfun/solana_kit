import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/auth/oauth_token_exchange.dart';

/// Response payload for the Helius developer portal configs endpoint.
class DevPortalConfigsResponse {
  /// Creates a [DevPortalConfigsResponse] with the given Stripe configuration.
  const DevPortalConfigsResponse({required this.stripe, this.openPay});

  /// Creates a [DevPortalConfigsResponse] from a JSON map.
  factory DevPortalConfigsResponse.fromJson(Map<String, Object?> json) {
    return DevPortalConfigsResponse(
      stripe: StripeConfig.fromJson(json['stripe']! as Map<String, Object?>),
      openPay: json['openPay'] is Map<String, Object?>
          ? StripeConfig.fromJson(json['openPay']! as Map<String, Object?>)
          : null,
    );
  }

  /// Stripe billing configuration for the portal.
  final StripeConfig stripe;

  /// Optional OpenPay billing configuration, when enabled.
  final StripeConfig? openPay;
}

/// Stripe billing configuration returned by the developer portal.
class StripeConfig {
  /// Creates a [StripeConfig] with the given [priceIds] and optional prepaid
  /// credits plans.
  const StripeConfig({required this.priceIds, this.prepaidCreditsPlans});

  /// Creates a [StripeConfig] from a JSON map.
  factory StripeConfig.fromJson(Map<String, Object?> json) {
    return StripeConfig(
      priceIds: PriceIds.fromJson(json['priceIds']! as Map<String, Object?>),
      prepaidCreditsPlans: (json['prepaidCreditsPlans'] as Map?)
          ?.cast<String, String>(),
    );
  }

  /// Available Stripe price identifiers for the configured plans.
  final PriceIds priceIds;

  /// Optional prepaid credits plan price identifiers keyed by currency.
  final Map<String, String>? prepaidCreditsPlans;
}

/// Stripe price identifiers for the available billing plans.
class PriceIds {
  /// Creates a [PriceIds] with the given monthly, yearly, and agent plan prices.
  const PriceIds({required this.monthly, required this.yearly, this.agentPlan});

  /// Creates a [PriceIds] from a JSON map.
  factory PriceIds.fromJson(Map<String, Object?> json) {
    return PriceIds(
      monthly: (json['Monthly']! as Map).cast<String, String>(),
      yearly: (json['Yearly']! as Map).cast<String, String>(),
      agentPlan: json['AgentPlan'] as String?,
    );
  }

  /// Monthly billing price identifiers keyed by currency.
  final Map<String, String> monthly;

  /// Yearly billing price identifiers keyed by currency.
  final Map<String, String> yearly;

  /// Optional price identifier for the agent plan.
  final String? agentPlan;
}

/// Fetches the developer portal configs for the given [jwt].
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

/// Fetches the Stripe price identifiers for the given [jwt].
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

/// Fetches the prepaid credits price identifiers for the given [jwt].
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
