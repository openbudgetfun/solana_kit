import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// The mode of a Jupiter swap order response.
///
/// `ultra` orders are executed through Jupiter's managed landing stack;
/// `manual` orders are landed by the caller.
enum JupiterOrderMode {
  /// Routed through Jupiter's managed landing stack.
  ultra,

  /// Landed by the caller's own RPC.
  manual,
}

/// The swap mode of an order request.
enum JupiterSwapMode {
  /// Pay an exact input amount and receive as much output as possible.
  exactIn,

  /// Pay at most the quoted input amount to receive an exact output amount.
  exactOut,
}

/// A request for a Jupiter swap quote and assembled transaction.
///
/// See the [Swap API v2 docs](https://developers.jup.ag/docs/swap) for the
/// full parameter reference.
class JupiterOrderRequest {
  /// Creates an order request.
  ///
  /// [inputMint], [outputMint], and [amount] are required. The [amount] must
  /// be an integer string in the input mint's smallest unit. [slippageBps]
  /// defaults to the API default when omitted.
  JupiterOrderRequest({
    required this.inputMint,
    required this.outputMint,
    required this.amount,
    this.slippageBps,
    this.swapMode,
    this.referralAccount,
    this.referralFee,
    this.restrictIntermediateTokens,
    this.platformFeeBps,
    this.excludeDirectRouterRoutes,
    this.payer,
    this.extraQueryParameters = const {},
  });

  /// The mint of the token being sold.
  final Address inputMint;

  /// The mint of the token being bought.
  final Address outputMint;

  /// The amount to swap, in the input mint's smallest unit, as a string.
  final BigInt amount;

  /// Maximum slippage in basis points. Applies to the router path.
  final int? slippageBps;

  /// Whether [amount] refers to the input or the output amount.
  final JupiterSwapMode? swapMode;

  /// The account that receives referral fees.
  final Address? referralAccount;

  /// The referral fee in basis points (0–255).
  final int? referralFee;

  /// Whether to restrict routes through intermediate tokens.
  final bool? restrictIntermediateTokens;

  /// Platform fee in basis points for the `/swap/v2/build` path.
  final int? platformFeeBps;

  /// Whether to exclude direct router routes.
  final bool? excludeDirectRouterRoutes;

  /// An alternative transaction payer for gasless flows.
  final Address? payer;

  /// Additional query parameters forwarded verbatim to the API.
  final Map<String, String> extraQueryParameters;

  /// Converts this request to Swap API v2 query parameters.
  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'inputMint': inputMint.toString(),
      'outputMint': outputMint.toString(),
      'amount': amount.toString(),
    };
    void put(String key, Object? value) {
      if (value != null) params[key] = '$value';
    }

    put('slippageBps', slippageBps);
    if (swapMode != null) {
      put(
        'swapMode',
        swapMode == JupiterSwapMode.exactOut ? 'ExactOut' : 'ExactIn',
      );
    }
    put('referralAccount', referralAccount);
    put('referralFee', referralFee);
    put('restrictIntermediateTokens', restrictIntermediateTokens);
    put('platformFeeBps', platformFeeBps);
    put('excludeDirectRouterRoutes', excludeDirectRouterRoutes);
    put('payer', payer);
    params.addAll(extraQueryParameters);
    return params;
  }
}

/// The transaction payload returned by `GET /swap/v2/order`.
class JupiterOrderResponse {
  /// Creates an order response.
  const JupiterOrderResponse({
    required this.inAmount,
    required this.outAmount,
    required this.encodedTransaction,
    this.rawResponse = const {},
    this.requestId,
    this.router,
    this.mode,
    this.lastValidBlockHeight,
    this.expireAt,
    this.swapType,
    this.slippageBps,
  });

  /// Builds an order response from the Swap API JSON body.
  factory JupiterOrderResponse.fromJson(Map<String, Object?> json) {
    BigInt? parseBigInt(Object? value) {
      if (value == null) return null;
      if (value is String) return BigInt.tryParse(value);
      if (value is int || value is num) return BigInt.parse('$value');
      return null;
    }

    int? parseInt(Object? value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return JupiterOrderResponse(
      inAmount: parseBigInt(json['inAmount']),
      outAmount: parseBigInt(json['outAmount']),
      encodedTransaction: json['transaction'] as String?,
      requestId: json['requestId'] as String?,
      router: json['router'] as String?,
      mode: json['mode'] == 'manual'
          ? JupiterOrderMode.manual
          : json['mode'] == 'ultra'
          ? JupiterOrderMode.ultra
          : null,
      lastValidBlockHeight: parseBigInt(json['lastValidBlockHeight']),
      expireAt: parseInt(json['expireAt']),
      swapType: json['swapType'] as String?,
      slippageBps: parseInt(json['slippageBps']),
      rawResponse: json,
    );
  }

  /// The quoted input amount, in the input mint's smallest unit.
  final BigInt? inAmount;

  /// The expected output amount, in the output mint's smallest unit.
  final BigInt? outAmount;

  /// The base64-encoded v0 transaction to sign and execute.
  final String? encodedTransaction;

  /// The request ID used when posting the signed transaction to /execute.
  final String? requestId;

  /// The meta-router that quoted the swap (for example `metis`).
  final String? router;

  /// The managed mode of the order, when present.
  final JupiterOrderMode? mode;

  /// The last block height at which the assembled transaction is valid.
  final BigInt? lastValidBlockHeight;

  /// Unix timestamp (seconds) at which the order expires.
  final int? expireAt;

  /// The swap type of the assembled transaction.
  final String? swapType;

  /// The slippage applied to the order, in basis points.
  final int? slippageBps;

  /// The raw JSON body the response was built from.
  ///
  /// Defaults to an empty map when [JupiterOrderResponse] is constructed
  /// directly rather than from the API body.
  final Map<String, Object?> rawResponse;
}

/// The response from posting a signed transaction to `POST /swap/v2/execute`.
class JupiterExecutionResponse {
  /// Creates an execution response.
  const JupiterExecutionResponse({
    required this.encodedSwapTransaction,
    this.signature,
    this.error,
  });

  /// Builds an execution response from the Swap API JSON body.
  factory JupiterExecutionResponse.fromJson(Map<String, Object?> json) =>
      JupiterExecutionResponse(
        encodedSwapTransaction: json['swapTransaction'] as String?,
        signature: json['signature'] as String?,
        error: json['error'] is String ? json['error']! as String : null,
      );

  /// The fully signed base64 transaction submitted to the network.
  final String? encodedSwapTransaction;

  /// The transaction signature once the API reports one.
  final String? signature;

  /// The error reported by Jupiter, if the execution failed.
  final String? error;
}
