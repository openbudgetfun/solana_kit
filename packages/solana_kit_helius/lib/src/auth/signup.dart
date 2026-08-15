import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/auth/checkout.dart';
import 'package:solana_kit_helius/src/auth/create_api_key.dart';
import 'package:solana_kit_helius/src/auth/dev_portal_configs.dart';
import 'package:solana_kit_helius/src/auth/get_project.dart';
import 'package:solana_kit_helius/src/auth/keypair_helpers.dart';
import 'package:solana_kit_helius/src/auth/list_projects.dart';
import 'package:solana_kit_helius/src/auth/plan_catalog.dart';
import 'package:solana_kit_helius/src/auth/sign_auth_message.dart';
import 'package:solana_kit_helius/src/auth/signup_helpers.dart';
import 'package:solana_kit_helius/src/auth/wallet_signup.dart';
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

/// Authenticates the wallet and returns JWT, refId, and wallet address.
///
/// If the request is pre-authenticated (jwt provided), returns those directly.
/// Otherwise, performs wallet signup using the secret key.
///
/// Dart adaptation: the upstream `/wallet-signup` returns `{token, refId}`
/// while our `/v0/auth/wallet-signup` returns `{apiKey, projectId}`. We map
/// `apiKey → jwt` and `projectId → refId` for checkout compatibility.
Future<Map<String, String>> _authenticate(
  RestClient restClient,
  String apiKey,
  SignupRequest options,
  String? userAgent,
) async {
  // Pre-authenticated path
  if (options.jwt != null) {
    return {
      'jwt': options.jwt!,
      'refId': options.refId!,
      'walletAddress': options.walletAddress!,
    };
  }

  // Secret key path — sign and do wallet signup
  final secretKeyBytes = base64Decode(options.secretKey!);
  final keypairResult = loadKeypair(secretKeyBytes);
  final walletAddress = await getAddress(keypairResult);
  final signResponse = await signAuthMessage(
    SignAuthMessageRequest(secretKey: options.secretKey!),
  );

  final authResponse = await authWalletSignup(
    restClient,
    apiKey,
    WalletSignupRequest(
      walletAddress: walletAddress,
      signature: signResponse.signature,
      message: signResponse.message ?? '',
    ),
  );

  // Map apiKey → jwt, projectId → refId for checkout compatibility
  return {
    'jwt': authResponse.apiKey,
    'refId': authResponse.projectId,
    'walletAddress': walletAddress,
  };
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
  final effectiveBaseUrl = baseUrl ?? heliusDeveloperApiUrl;

  final auth = await _authenticate(restClient, apiKey, options, userAgent);
  final jwt = auth['jwt']!;
  final refId = auth['refId']!;
  final walletAddress = auth['walletAddress']!;

  // Check for existing projects
  final projects = await authListProjects(restClient, apiKey);
  if (projects.isNotEmpty) {
    // User has an existing project — check if already on requested plan
    final project = projects.first;

    // For agent plan, any existing project with an API key counts as subscribed
    if (plan == 'agent' && project.apiKey.isNotEmpty) {
      return AlreadySubscribedResult(
        jwt: jwt,
        refId: refId,
        walletAddress: walletAddress,
        projectId: project.id,
        apiKey: project.apiKey,
        endpoints: buildEndpoints(project.apiKey),
      );
    }

    // Different plan — upgrade required
    return UpgradeRequiredResult(
      jwt: jwt,
      refId: refId,
      walletAddress: walletAddress,
      currentPlan: 'unknown',
      requestedPlan: plan,
    );
  }

  // No existing project — must create a fresh payment intent.
  // Contact info is required by the backend at /checkout/initialize for
  // any new subscription, so we validate up front.
  if (options.email == null ||
      options.firstName == null ||
      options.lastName == null) {
    final missing = <String>[];
    if (options.email == null) missing.add('email');
    if (options.firstName == null) missing.add('firstName');
    if (options.lastName == null) missing.add('lastName');
    throw StateError(
      'Signup requires contact info. Missing: ${missing.join(', ')}.',
    );
  }

  final paymentLink = await createPayment(
    CreatePaymentRequest(
      jwt: jwt,
      refId: refId,
      plan: plan,
      period: options.period,
      email: options.email,
      firstName: options.firstName,
      lastName: options.lastName,
      couponCode: options.couponCode,
      walletAddress: walletAddress,
      paymentHost: options.paymentHost,
    ),
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
