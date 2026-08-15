import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_helius/src/auth/checkout.dart';
import 'package:solana_kit_helius/src/auth/constants.dart';
import 'package:solana_kit_helius/src/auth/create_api_key.dart';
import 'package:solana_kit_helius/src/auth/get_project.dart';
import 'package:solana_kit_helius/src/auth/list_projects.dart';
import 'package:solana_kit_helius/src/auth/payment_url.dart';
import 'package:solana_kit_helius/src/auth/payments.dart';
import 'package:solana_kit_helius/src/auth/signup.dart';
import 'package:solana_kit_helius/src/auth/signup_helpers.dart';
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
    client: client,
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
  http.Client? client,
}) async {
  final intent = await getPaymentIntent(
    jwt,
    paymentIntentId,
    client: client,
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
  RestClient restClient,
  String apiKey,
  String walletAddress,
) async {
  final deadline = DateTime.now().add(
    const Duration(milliseconds: projectPollTimeoutMs),
  );
  String? projectId;
  while (DateTime.now().isBefore(deadline)) {
    final projects = await authListProjects(restClient, apiKey);
    if (projects.isNotEmpty) {
      projectId = projects.first.id;
      break;
    }
    await Future<void>.delayed(
      const Duration(milliseconds: projectPollIntervalMs),
    );
  }
  if (projectId == null) {
    throw StateError(
      'Payment confirmed but no project was provisioned within timeout.',
    );
  }
  final details = await authGetProject(restClient, apiKey, projectId);
  var provisionedApiKey = details.apiKey;
  if (provisionedApiKey.isEmpty) {
    provisionedApiKey = (await authCreateApiKey(
      restClient,
      apiKey,
      CreateApiKeyRequest(projectId: projectId, name: walletAddress),
    ))
        .key;
  }
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
}) async {
  final result = await authSignup(
    restClient,
    apiKey,
    options,
    userAgent: userAgent,
    baseUrl: baseUrl,
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
  );
  final paymentIntentId = paymentRequired.paymentLink.paymentIntentId;
  final outcome = await pollUntilTerminal(
    paymentRequired.jwt,
    paymentIntentId,
    userAgent: userAgent,
  );
  if (outcome.kind == 'completed') {
    final provisioned = await _provisionApiKey(
      restClient,
      apiKey,
      paymentRequired.walletAddress,
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
