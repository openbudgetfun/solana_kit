import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_helius/src/auth/checkout.dart';
import 'package:solana_kit_helius/src/auth/developer_api.dart';
import 'package:solana_kit_helius/src/auth/oauth_token_exchange.dart';
import 'package:solana_kit_helius/src/auth/plan_catalog.dart';
import 'package:solana_kit_helius/src/auth/sign_auth_message.dart';
import 'package:solana_kit_helius/src/auth/signup_helpers.dart';
import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Supported plans for signup (v3.0.0).
const List<String> supportedPlans = [
  'agent',
  'developer',
  'business',
  'professional',
];

/// Validates and normalizes a plan name.
String _validatePlan(String plan) {
  final normalized = plan.toLowerCase();
  if (!supportedPlans.contains(normalized)) {
    throw ArgumentError.value(
      plan,
      'plan',
      'Unknown plan: $plan. Available: ${supportedPlans.join(', ')}',
    );
  }
  return normalized;
}

String _validatePeriod(String period) {
  final normalized = period.toLowerCase();
  if (normalized != 'monthly' && normalized != 'yearly') {
    throw ArgumentError.value(
      period,
      'period',
      'must be either monthly or yearly',
    );
  }
  return normalized;
}

bool _isBlank(String? value) => value == null || value.trim().isEmpty;

/// Authenticates the wallet and returns JWT, refId, and wallet address.
///
/// If the request is pre-authenticated (jwt provided), returns those directly.
/// Otherwise, performs wallet signup using the secret key.
///
/// The secret-key path uses the upstream developer API's `/wallet-signup`
/// response directly. A project API key is never reused as a bearer JWT.
Future<Map<String, String>> _authenticate(
  SignupRequest options,
  String? userAgent, {
  required String baseUrl,
  http.Client? client,
}) async {
  // Pre-authenticated path
  if (options.jwt != null) {
    if (options.jwt!.isEmpty || options.refId!.isEmpty) {
      throw ArgumentError('jwt and refId must not be empty');
    }
    final walletAddress = Address(options.walletAddress!);
    return {
      'jwt': options.jwt!,
      'refId': options.refId!,
      'walletAddress': walletAddress.value,
    };
  }

  // Secret key path: sign and do wallet signup
  final secretKeyBytes = base64Decode(options.secretKey!);
  try {
    if (secretKeyBytes.length != 64) {
      throw ArgumentError.value(
        secretKeyBytes.length,
        'secretKey',
        'must decode to 64 bytes',
      );
    }
    final publicKey = Uint8List.sublistView(secretKeyBytes, 32, 64);
    final walletAddress = getBase58Decoder().decode(publicKey);
    final signResponse = await signAuthMessage(
      SignAuthMessageRequest(secretKey: options.secretKey!),
    );
    final authResponse = await developerWalletSignup(
      message: signResponse.message ?? '',
      signature: signResponse.signature,
      walletAddress: walletAddress,
      userAgent: userAgent,
      client: client,
      baseUrl: baseUrl,
    );
    return {
      'jwt': authResponse.token,
      'refId': authResponse.refId,
      'walletAddress': walletAddress,
    };
  } finally {
    secretKeyBytes.fillRange(0, secretKeyBytes.length, 0);
  }
}

bool _matchesExistingPlan(
  DeveloperProjectSummary project,
  String plan,
  String period,
) {
  if (project.subscription.plan != planToUsagePlan[plan]) return false;
  if (plan == 'agent') return true;
  final start = DateTime.tryParse(project.subscription.billingPeriodStart);
  final end = DateTime.tryParse(project.subscription.billingPeriodEnd);
  if (start == null || end == null || !end.isAfter(start)) return false;
  final days = end.difference(start).inHours / 24;
  return period == 'yearly'
      ? days >= 350 && days <= 380
      : days >= 25 && days <= 35;
}

/// Phase 1 unified signup (v3.0.0).
///
/// Authenticates the wallet, detects existing projects, and either:
/// - short-circuits with [AlreadySubscribedResult] if already on this plan
/// - short-circuits with [UpgradeRequiredResult] if on a different plan
/// - returns [PaymentRequiredResult] with a hosted-checkout link for new users
///
/// Zero-amount checkouts (e.g. 100% coupons) are rejected up front.
Future<SignupResult> authSignup(
  RestClient restClient,
  String apiKey,
  SignupRequest options, {
  String? userAgent,
  http.Client? httpClient,
  String? baseUrl,
}) async {
  final plan = _validatePlan(options.plan);
  final period = _validatePeriod(options.period);
  final effectiveBaseUrl = baseUrl ?? heliusDeveloperApiUrl;

  final auth = await _authenticate(
    options,
    userAgent,
    client: httpClient,
    baseUrl: effectiveBaseUrl,
  );
  final jwt = auth['jwt']!;
  final refId = auth['refId']!;
  final walletAddress = auth['walletAddress']!;

  // Check for existing projects
  final projects = await developerListProjects(
    jwt,
    userAgent: userAgent,
    client: httpClient,
    baseUrl: effectiveBaseUrl,
  );
  if (projects.isNotEmpty) {
    // User has an existing project: check if already on requested plan
    final project = projects.first;

    if (_matchesExistingPlan(project, plan, period)) {
      final details = await developerGetProject(
        jwt,
        project.id,
        userAgent: userAgent,
        client: httpClient,
        baseUrl: effectiveBaseUrl,
      );
      var projectApiKey = details.apiKeys.firstOrNull?.keyId;
      projectApiKey ??= (await developerCreateApiKey(
        jwt,
        project.id,
        walletAddress,
        userAgent: userAgent,
        client: httpClient,
        baseUrl: effectiveBaseUrl,
      )).keyId;
      return AlreadySubscribedResult(
        jwt: jwt,
        refId: refId,
        walletAddress: walletAddress,
        projectId: project.id,
        apiKey: projectApiKey,
        endpoints: buildEndpoints(projectApiKey),
      );
    }

    // Different plan: upgrade required
    return UpgradeRequiredResult(
      jwt: jwt,
      refId: refId,
      walletAddress: walletAddress,
      currentPlan: project.subscription.plan,
      requestedPlan: plan,
    );
  }

  // No existing project: must create a fresh payment intent.
  // Contact info is required by the backend at /checkout/initialize for
  // any new subscription, so we validate up front.
  if (_isBlank(options.email) ||
      _isBlank(options.firstName) ||
      _isBlank(options.lastName)) {
    final missing = <String>[];
    if (_isBlank(options.email)) missing.add('email');
    if (_isBlank(options.firstName)) missing.add('firstName');
    if (_isBlank(options.lastName)) missing.add('lastName');
    throw StateError(
      'Signup requires contact info. Missing: ${missing.join(', ')}.',
    );
  }

  final paymentLink = await createPayment(
    CreatePaymentRequest(
      jwt: jwt,
      refId: refId,
      plan: plan,
      period: period,
      email: options.email,
      firstName: options.firstName,
      lastName: options.lastName,
      couponCode: options.couponCode,
      walletAddress: walletAddress,
      paymentHost: options.paymentHost,
    ),
    userAgent: userAgent,
    client: httpClient,
    baseUrl: effectiveBaseUrl,
  );

  return PaymentRequiredResult(
    jwt: jwt,
    refId: refId,
    walletAddress: walletAddress,
    paymentLink: paymentLink,
  );
}
