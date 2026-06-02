// ignore_for_file: public_member_api_docs, curly_braces_in_flow_control_structures, use_null_aware_elements, avoid_catching_errors

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/auth/dev_portal_configs.dart';
import 'package:solana_kit_helius/src/auth/oauth_token_exchange.dart';
import 'package:solana_kit_helius/src/auth/payment_url.dart';
import 'package:solana_kit_helius/src/auth/plan_catalog.dart';
import 'package:solana_kit_helius/src/auth/retry.dart';

const checkoutPollInterval = Duration(seconds: 1);
const checkoutPollTimeout = Duration(seconds: 60);

typedef CheckoutPeriod = String;

typedef SupportedPlan = String;

class CheckoutCoupon {
  const CheckoutCoupon({
    this.code,
    this.valid,
    this.percentOff,
    this.description,
  });

  factory CheckoutCoupon.fromJson(Map<String, Object?> json) => CheckoutCoupon(
    code: json['code'] as String?,
    valid: json['valid'] as bool?,
    percentOff: json['percentOff'] as int?,
    description: json['description'] as String?,
  );

  final String? code;
  final bool? valid;
  final int? percentOff;
  final String? description;
}

class CheckoutPreviewResponse {
  const CheckoutPreviewResponse({
    required this.planName,
    required this.period,
    required this.baseAmount,
    required this.subtotal,
    required this.appliedCredits,
    required this.proratedCredits,
    required this.discounts,
    required this.dueToday,
    required this.destinationWallet,
    required this.note,
    this.coupon,
  });

  factory CheckoutPreviewResponse.fromJson(Map<String, Object?> json) =>
      CheckoutPreviewResponse(
        planName: json['planName'] as String? ?? '',
        period: json['period'] as String? ?? '',
        baseAmount: json['baseAmount'] as int? ?? 0,
        subtotal: json['subtotal'] as int? ?? 0,
        appliedCredits: json['appliedCredits'] as int? ?? 0,
        proratedCredits: json['proratedCredits'] as int? ?? 0,
        discounts: json['discounts'] as int? ?? 0,
        dueToday: json['dueToday'] as int? ?? 0,
        destinationWallet: json['destinationWallet'] as String? ?? '',
        note: json['note'] as String? ?? '',
        coupon: json['coupon'] is Map<String, Object?>
            ? CheckoutCoupon.fromJson(json['coupon']! as Map<String, Object?>)
            : null,
      );

  final String planName;
  final String period;
  final int baseAmount;
  final int subtotal;
  final int appliedCredits;
  final int proratedCredits;
  final int discounts;
  final int dueToday;
  final String destinationWallet;
  final String note;
  final CheckoutCoupon? coupon;
}

class CheckoutInitializeRequest {
  const CheckoutInitializeRequest({
    required this.priceId,
    required this.refId,
    this.email,
    this.firstName,
    this.lastName,
    this.walletAddress,
    this.couponCode,
    this.qty,
  });

  final String priceId;
  final String refId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? walletAddress;
  final String? couponCode;
  final int? qty;

  Map<String, Object?> toJson() => {
    'priceId': priceId,
    'refId': refId,
    if (email != null) 'email': email,
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    if (walletAddress != null) 'walletAddress': walletAddress,
    if (couponCode != null) 'couponCode': couponCode,
    if (qty != null) 'qty': qty,
  };
}

class CheckoutInitializeResponse {
  const CheckoutInitializeResponse({
    required this.id,
    required this.status,
    required this.destinationWallet,
    required this.amount,
    required this.solanaPayUrl,
    required this.expiresAt,
    this.createdAt,
    this.priceId,
    this.refId,
  });

  factory CheckoutInitializeResponse.fromJson(Map<String, Object?> json) =>
      CheckoutInitializeResponse(
        id: json['id'] as String? ?? '',
        status: json['status'] as String? ?? '',
        destinationWallet: json['destinationWallet'] as String? ?? '',
        amount: json['amount'] as int? ?? 0,
        solanaPayUrl: json['solanaPayUrl'] as String? ?? '',
        expiresAt: json['expiresAt'] as String? ?? '',
        createdAt: json['createdAt'] as String?,
        priceId: json['priceId'] as String?,
        refId: json['refId'] as String?,
      );

  final String id;
  final String status;
  final String destinationWallet;
  final int amount;
  final String solanaPayUrl;
  final String expiresAt;
  final String? createdAt;
  final String? priceId;
  final String? refId;
}

class CheckoutStatusResponse {
  const CheckoutStatusResponse({
    required this.status,
    required this.phase,
    required this.subscriptionActive,
    required this.readyToRedirect,
    required this.message,
  });

  factory CheckoutStatusResponse.fromJson(Map<String, Object?> json) =>
      CheckoutStatusResponse(
        status: json['status'] as String? ?? '',
        phase: json['phase'] as String? ?? '',
        subscriptionActive: json['subscriptionActive'] as bool? ?? false,
        readyToRedirect: json['readyToRedirect'] as bool? ?? false,
        message: json['message'] as String? ?? '',
      );

  final String status;
  final String phase;
  final bool subscriptionActive;
  final bool readyToRedirect;
  final String message;
}

class PollOutcome {
  const PollOutcome(this.kind, {this.status});
  final String kind;
  final CheckoutStatusResponse? status;
}

class PaymentLink {
  const PaymentLink({
    required this.kind,
    required this.paymentIntentId,
    required this.amountCents,
    required this.destinationWallet,
    required this.memo,
    required this.expiresAt,
    required this.paymentUrl,
    required this.solanaPayUrl,
    required this.planName,
  });

  final String kind;
  final String paymentIntentId;
  final int amountCents;
  final String destinationWallet;
  final String memo;
  final String expiresAt;
  final String paymentUrl;
  final String solanaPayUrl;
  final String planName;
}

class CreatePaymentRequest {
  const CreatePaymentRequest({
    required this.jwt,
    required this.refId,
    this.priceId,
    this.plan,
    this.period = 'monthly',
    this.qty,
    this.email,
    this.firstName,
    this.lastName,
    this.couponCode,
    this.walletAddress,
    this.paymentHost,
    this.planNameOverride,
  });

  final String jwt;
  final String refId;
  final String? priceId;
  final SupportedPlan? plan;
  final CheckoutPeriod period;
  final int? qty;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? couponCode;
  final String? walletAddress;
  final String? paymentHost;
  final String? planNameOverride;
}

Future<T> _authRequest<T>(
  String path,
  T Function(Map<String, Object?> json) fromJson, {
  required String jwt,
  required String method,
  Object? body,
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final httpClient = client ?? http.Client(); // coverage:ignore-line
  final closeClient = client == null; // coverage:ignore-line
  try {
    final headers = <String, String>{
      'Authorization': 'Bearer $jwt',
      'accept': 'application/json',
    };
    if (body != null) headers['content-type'] = 'application/json';
    if (userAgent != null) headers['User-Agent'] = userAgent;
    final uri = Uri.parse('$baseUrl$path');
    final response = method == 'POST'
        ? await httpClient.post(uri, headers: headers, body: jsonEncode(body))
        : await httpClient.get(uri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw createSolanaError(
        SolanaErrorCode.heliusRestError,
        context: {
          SolanaErrorContextKeys.operation: 'heliusCheckout',
          SolanaErrorContextKeys.statusCode: response.statusCode,
          'message': response.body,
        },
      );
    }
    return fromJson(jsonDecode(response.body) as Map<String, Object?>);
  } finally {
    if (closeClient) httpClient.close(); // coverage:ignore-line
  }
}

Future<String> resolvePriceId(
  String jwt,
  String plan,
  CheckoutPeriod period, {
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final planKey = plan.toLowerCase();
  final usagePlan = planToUsagePlan[planKey];
  if (usagePlan == null) {
    throw ArgumentError(
      'Unknown plan: $plan. Available: ${planToUsagePlan.keys.join(', ')}',
    );
  }
  if (planKey == 'agent') {
    final priceIds = await fetchStripePriceIds(
      jwt,
      includeAgentPlan: true,
      userAgent: userAgent,
      client: client,
      baseUrl: baseUrl,
    );
    final priceId = priceIds.agentPlan;
    if (priceId == null || priceId.isEmpty)
      throw StateError(
        'No priceId found for plan "agent" at stripe.priceIds.AgentPlan / PRICE_ID_AGENT_PLAN.',
      );
    return priceId;
  }
  final priceIds = await fetchStripePriceIds(
    jwt,
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
  final periodMap = period == 'yearly' ? priceIds.yearly : priceIds.monthly;
  final priceId = periodMap[usagePlan];
  if (priceId == null || priceId.isEmpty) {
    final available = periodMap.keys.toList();
    throw StateError(
      'No priceId found for plan "$plan" ($period). ${available.isEmpty ? 'The pricing configuration is empty — the backend may not be fully deployed yet.' : 'Expected key "$usagePlan" but available keys are: [${available.join(', ')}]'}',
    );
  }
  return priceId;
}

Future<CheckoutInitializeResponse> initializeCheckout(
  String jwt,
  CheckoutInitializeRequest request, {
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) => _authRequest(
  '/checkout/initialize',
  CheckoutInitializeResponse.fromJson,
  jwt: jwt,
  method: 'POST',
  body: request.toJson(),
  userAgent: userAgent,
  client: client,
  baseUrl: baseUrl,
);

Future<CheckoutPreviewResponse> getCheckoutPreviewByPriceId(
  String jwt,
  String priceId,
  String refId, {
  String? couponCode,
  int? qty,
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) {
  final params = {
    'priceId': priceId,
    'refId': refId,
    if (couponCode != null) 'couponCode': couponCode,
    if (qty != null) 'qty': '$qty',
  };
  return _authRequest(
    '/checkout/preview?${Uri(queryParameters: params).query}',
    CheckoutPreviewResponse.fromJson,
    jwt: jwt,
    method: 'GET',
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
}

Future<CheckoutPreviewResponse> getCheckoutPreview(
  String jwt,
  String plan,
  CheckoutPeriod period,
  String refId, {
  String? couponCode,
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  final priceId = await resolvePriceId(
    jwt,
    plan,
    period,
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
  return getCheckoutPreviewByPriceId(
    jwt,
    priceId,
    refId,
    couponCode: couponCode,
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
  );
}

Future<CheckoutInitializeResponse> getPaymentIntent(
  String jwt,
  String paymentIntentId, {
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) => _authRequest(
  '/checkout/$paymentIntentId',
  CheckoutInitializeResponse.fromJson,
  jwt: jwt,
  method: 'GET',
  userAgent: userAgent,
  client: client,
  baseUrl: baseUrl,
);

Future<CheckoutStatusResponse> getPaymentStatus(
  String jwt,
  String paymentIntentId, {
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) => _authRequest(
  '/checkout/$paymentIntentId/status',
  CheckoutStatusResponse.fromJson,
  jwt: jwt,
  method: 'GET',
  userAgent: userAgent,
  client: client,
  baseUrl: baseUrl,
);

Future<PollOutcome> pollUntilTerminal(
  String jwt,
  String paymentIntentId, {
  Duration timeout = checkoutPollTimeout,
  Duration interval = checkoutPollInterval,
  String? userAgent,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
  Future<CheckoutStatusResponse> Function()? statusFetcher,
  Future<void> Function(Duration duration)? sleep,
}) async {
  final deadline = DateTime.now().add(timeout);
  final wait = sleep ?? Future<void>.delayed;
  while (DateTime.now().isBefore(deadline)) {
    late final CheckoutStatusResponse status;
    try {
      status =
          await (statusFetcher?.call() ??
              getPaymentStatus(
                jwt,
                paymentIntentId,
                userAgent: userAgent,
                client: client,
                baseUrl: baseUrl,
              ));
    } on Object catch (error) {
      if (getHttpStatus(error) == 410) return const PollOutcome('expired');
      rethrow;
    }
    if (status.readyToRedirect) return PollOutcome('completed', status: status);
    if (status.phase == 'expired')
      return PollOutcome('expired', status: status);
    if (status.phase == 'failed') return PollOutcome('failed', status: status);
    await wait(interval);
  }
  return const PollOutcome('timeout');
}

Future<CheckoutStatusResponse> pollCheckoutCompletion(
  String jwt,
  String paymentIntentId, {
  String? userAgent,
  Duration timeout = checkoutPollTimeout,
  Duration interval = checkoutPollInterval,
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
  Future<void> Function(Duration duration)? sleep,
}) async {
  final outcome = await pollUntilTerminal(
    jwt,
    paymentIntentId,
    timeout: timeout,
    interval: interval,
    userAgent: userAgent,
    client: client,
    baseUrl: baseUrl,
    sleep: sleep,
  );
  if (outcome.status != null) return outcome.status!;
  if (outcome.kind == 'expired')
    return const CheckoutStatusResponse(
      status: 'expired',
      phase: 'expired',
      subscriptionActive: false,
      readyToRedirect: false,
      message: 'Payment intent expired',
    );
  return const CheckoutStatusResponse(
    status: 'pending',
    phase: 'confirming',
    subscriptionActive: false,
    readyToRedirect: false,
    message: 'Polling timed out',
  );
}

String _planNameFor(String? plan, String period, String? fallback) {
  if (plan == null) return fallback ?? 'Helius';
  if (plan == 'agent') return 'Agent Plan';
  final cap =
      '${plan[0].toUpperCase()}${plan.substring(1)}'; // coverage:ignore-line
  return '$cap (${period == 'yearly' ? 'Yearly' : 'Monthly'})'; // coverage:ignore-line
}

Future<PaymentLink> createPayment(
  CreatePaymentRequest req, {
  http.Client? client,
  String baseUrl = heliusDeveloperApiUrl,
}) async {
  if (req.priceId == null && req.plan == null)
    throw ArgumentError(
      'createPayment: must provide either `priceId` or `plan`.',
    );
  final priceId =
      req.priceId ??
      await resolvePriceId(
        req.jwt,
        req.plan!,
        req.period,
        client: client,
        baseUrl: baseUrl,
      );
  try {
    final preview = req.plan != null
        ? await getCheckoutPreview(
            req.jwt,
            req.plan!,
            req.period,
            req.refId,
            couponCode: req.couponCode,
            client: client,
            baseUrl: baseUrl,
          )
        : await getCheckoutPreviewByPriceId(
            req.jwt,
            priceId,
            req.refId,
            couponCode: req.couponCode,
            qty: req.qty,
            client: client,
            baseUrl: baseUrl,
          );
    if (preview.dueToday == 0)
      throw StateError(
        'Zero-amount signups are not supported in this version. Remove the coupon or use a different plan.',
      );
  } on StateError {
    rethrow;
  } on Object {
    // Preview can be unavailable for fresh one-time checkout customers; initialize surfaces final errors.
  }
  final intent = await initializeCheckout(
    req.jwt,
    CheckoutInitializeRequest(
      priceId: priceId,
      refId: req.refId,
      email: req.email,
      firstName: req.firstName,
      lastName: req.lastName,
      walletAddress: req.walletAddress,
      couponCode: req.couponCode,
      qty: req.qty,
    ),
    client: client,
    baseUrl: baseUrl,
  );
  return PaymentLink(
    kind: 'payment_required',
    paymentIntentId: intent.id,
    amountCents: intent.amount,
    destinationWallet: intent.destinationWallet,
    memo: intent.id,
    expiresAt: intent.expiresAt,
    paymentUrl: buildPaymentUrl(intent.id, hostOverride: req.paymentHost),
    solanaPayUrl: intent.solanaPayUrl,
    planName: _planNameFor(req.plan, req.period, req.planNameOverride),
  );
}
