import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_helius/src/auth/checkout.dart';
import 'package:solana_kit_helius/src/auth/constants.dart';
import 'package:solana_kit_helius/src/auth/developer_api.dart';
import 'package:solana_kit_helius/src/auth/oauth_token_exchange.dart';
import 'package:solana_kit_helius/src/auth/payment_url.dart';
import 'package:solana_kit_helius/src/auth/payments.dart';
import 'package:solana_kit_helius/src/auth/signup.dart';
import 'package:solana_kit_helius/src/auth/signup_helpers.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/internal/rest_client.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Upgrades an existing project to a new plan, returning a payment link.
Future<UpgradePlanResult> upgradePlan(
  RestClient restClient,
  String apiKey, {
  required String jwt,
  required String projectId,
  required String plan,
  String period = 'monthly',
  String? email,
  String? firstName,
  String? lastName,
  String? couponCode,
  String? paymentHost,
  String? userAgent,
  String baseUrl = heliusDeveloperApiUrl,
  http.Client? client,
}) async {
  final paymentLink = await createPayment(
    CreatePaymentRequest(
      jwt: jwt,
      refId: projectId,
      plan: plan,
      period: period,
      email: email,
      firstName: firstName,
      lastName: lastName,
      couponCode: couponCode,
      paymentHost: paymentHost,
    ),
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
  return UpgradePlanResult(paymentLink: paymentLink);
}

/// Pays a renewal for an existing payment intent, returning a payment link.
Future<PayRenewalResult> payRenewal(
  RestClient restClient,
  String apiKey,
  String jwt,
  String paymentIntentId, {
  String? paymentHost,
  String? userAgent,
  String baseUrl = heliusDeveloperApiUrl,
  http.Client? client,
}) async {
  final intent = await getPaymentIntent(
    jwt,
    paymentIntentId,
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
  if (intent.status != 'pending') {
    throw StateError(
      'Payment intent $paymentIntentId is ${intent.status}; '
      'only pending intents can be paid.',
    );
  }
  return PayRenewalResult(
    paymentLink: PaymentLink(
      kind: 'payment_required',
      paymentIntentId: intent.id,
      amountCents: intent.amount,
      destinationWallet: intent.destinationWallet,
      memo: intent.id,
      expiresAt: intent.expiresAt,
      paymentUrl: buildPaymentUrl(intent.id, hostOverride: paymentHost),
      solanaPayUrl: intent.solanaPayUrl,
      planName: 'Subscription renewal',
    ),
  );
}

/// Provisions a project after a confirmed payment, returning the project id,
/// api key, and endpoints.
Future<({String projectId, String apiKey, SignupEndpoints endpoints})>
_provisionApiKey(
  String jwt,
  String walletAddress, {
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
  Duration timeout = const Duration(milliseconds: projectPollTimeoutMs),
  Duration interval = const Duration(milliseconds: projectPollIntervalMs),
}) async {
  final deadline = DateTime.now().add(timeout);
  String? projectId;
  while (DateTime.now().isBefore(deadline)) {
    final projects = await developerListProjects(
      jwt,
      userAgent: userAgent,
      client: client,
      baseUrl: baseUrl,
    );
    if (projects.isNotEmpty) {
      projectId = projects.first.id;
      break;
    }
    final pollDelay = interval;
    await Future<void>.delayed(pollDelay);
  }
  if (projectId == null) {
    throw StateError(
      'Payment confirmed but no project was provisioned within timeout.',
    );
  }
  final details = await developerGetProject(
    jwt,
    projectId,
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
  var provisionedApiKey = details.apiKeys.firstOrNull?.keyId;
  provisionedApiKey ??= (await developerCreateApiKey(
    jwt,
    projectId,
    walletAddress,
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  )).keyId;
  return (
    projectId: projectId,
    apiKey: provisionedApiKey,
    endpoints: buildEndpoints(provisionedApiKey),
  );
}

/// Signs up and pays for a plan in one flow, returning the final result.
Future<SignupAndPayResult> signupAndPay(
  RestClient restClient,
  String apiKey,
  SignupRequest options, {
  required Uint8List secretKey,
  String? userAgent,
  String? baseUrl,
  JsonRpcClient? rpcClient,
  http.Client? client,
  Duration pollTimeout = checkoutPollTimeout,
  Duration pollInterval = checkoutPollInterval,
  Duration provisionTimeout = const Duration(
    milliseconds: projectPollTimeoutMs,
  ),
  Duration provisionInterval = const Duration(
    milliseconds: projectPollIntervalMs,
  ),
}) async {
  final effectiveBaseUrl = baseUrl ?? heliusDeveloperApiUrl;
  final result = await authSignup(
    restClient,
    apiKey,
    options,
    userAgent: userAgent,
    httpClient: client,
    baseUrl: effectiveBaseUrl,
  );
  if (result is AlreadySubscribedResult) {
    return SignupAndPayAlreadySubscribedResult(
      jwt: result.jwt,
      refId: result.refId,
      walletAddress: result.walletAddress,
      projectId: result.projectId,
      apiKey: result.apiKey,
      endpoints: result.endpoints,
    );
  }
  if (result is UpgradeRequiredResult) {
    return SignupAndPayUpgradeRequiredResult(
      jwt: result.jwt,
      refId: result.refId,
      walletAddress: result.walletAddress,
      currentPlan: result.currentPlan,
      requestedPlan: result.requestedPlan,
    );
  }
  final paymentRequired = result as PaymentRequiredResult;
  final txSignature = await payPaymentLink(
    secretKey,
    paymentRequired.paymentLink,
    rpcClient: rpcClient,
    client: client,
  );
  final paymentIntentId = paymentRequired.paymentLink.paymentIntentId;
  final outcome = await pollUntilTerminal(
    paymentRequired.jwt,
    paymentIntentId,
    userAgent: userAgent,
    client: client,
    baseUrl: effectiveBaseUrl,
    timeout: pollTimeout,
    interval: pollInterval,
  );
  if (outcome.kind == 'completed') {
    final provisioned = await _provisionApiKey(
      paymentRequired.jwt,
      paymentRequired.walletAddress,
      userAgent: userAgent,
      client: client,
      baseUrl: effectiveBaseUrl,
      timeout: provisionTimeout,
      interval: provisionInterval,
    );
    return SignupAndPayCompletedResult(
      jwt: paymentRequired.jwt,
      refId: paymentRequired.refId,
      walletAddress: paymentRequired.walletAddress,
      projectId: provisioned.projectId,
      apiKey: provisioned.apiKey,
      endpoints: provisioned.endpoints,
      txSignature: txSignature,
      paymentIntentId: paymentIntentId,
    );
  }
  if (outcome.kind == 'expired') {
    return SignupAndPayExpiredResult(
      jwt: paymentRequired.jwt,
      refId: paymentRequired.refId,
      walletAddress: paymentRequired.walletAddress,
      paymentIntentId: paymentIntentId,
    );
  }
  if (outcome.kind == 'failed') {
    return SignupAndPayFailedResult(
      jwt: paymentRequired.jwt,
      refId: paymentRequired.refId,
      walletAddress: paymentRequired.walletAddress,
      paymentIntentId: paymentIntentId,
      reason: outcome.status?.message ?? 'Payment failed',
    );
  }
  return SignupAndPayPendingResult(
    jwt: paymentRequired.jwt,
    refId: paymentRequired.refId,
    walletAddress: paymentRequired.walletAddress,
    paymentLink: paymentRequired.paymentLink,
    txSignature: txSignature,
  );
}
