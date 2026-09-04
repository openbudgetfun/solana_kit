import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_jupiter/src/internal/rest_client.dart';
import 'package:solana_kit_jupiter/src/jupiter_config.dart';
import 'package:solana_kit_jupiter/src/models/build.dart';
import 'package:solana_kit_jupiter/src/models/order.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Client for the Jupiter Swap API v2.
///
/// The managed path is [getOrder] followed by [executeOrder]: the API assembles a
/// v0 transaction, the caller signs it, and the API lands it with managed
/// slippage. The self-landing path is [buildSwap], which returns raw
/// instructions for callers that assemble and submit transactions
/// themselves.
class JupiterSwapClient {
  /// Creates a swap client.
  JupiterSwapClient({required JupiterConfig config})
    : _restClient = JupiterRestClient(
        baseUrl: config.baseUrl,
        apiKey: config.apiKey,
        client: config.client,
      );

  final JupiterRestClient _restClient;

  /// Requests a quote and an assembled swap transaction.
  ///
  /// Returns the parsed [JupiterOrderResponse], whose [JupiterOrderResponse
  /// .encodedTransaction] field holds the base64 transaction to sign.
  Future<JupiterOrderResponse> getOrder(JupiterOrderRequest order) async {
    final response = await _restClient.get(
      '/swap/v2/order',
      queryParameters: order.toQueryParameters(),
    );
    return switch (response) {
      final Map<String, Object?> json => JupiterOrderResponse.fromJson(json),
      _ => throw JupiterException(
        statusCode: 200,
        message: 'Expected a JSON object from /swap/v2/order',
        body: response,
      ),
    };
  }

  /// Submits a signed transaction from an accepted [order].
  ///
  /// The order must have a nonempty request ID returned by `/order`.
  /// [userPublicKey] is retained for source compatibility; the wallet identity
  /// is already carried by the signed transaction.
  ///
  /// The [signedTransaction] is the base64 wire representation of the
  /// transaction after the user signed
  /// [JupiterOrderResponse.encodedTransaction].
  Future<JupiterExecutionResponse> executeOrder({
    required JupiterOrderResponse order,
    required String signedTransaction,
    Address? userPublicKey,
  }) async {
    final requestId = order.requestId;
    if (requestId == null || requestId.trim().isEmpty) {
      throw ArgumentError('The order must include a nonempty requestId.');
    }
    final response = await _restClient.post(
      '/swap/v2/execute',
      body: {
        'requestId': requestId,
        'signedTransaction': signedTransaction,
        if (order.lastValidBlockHeight != null)
          'lastValidBlockHeight': order.lastValidBlockHeight.toString(),
      },
    );
    return switch (response) {
      final Map<String, Object?> json => JupiterExecutionResponse.fromJson(
        json,
      ),
      _ => throw JupiterException(
        statusCode: 200,
        message: 'Expected a JSON object from /swap/v2/execute',
        body: response,
      ),
    };
  }

  /// Requests the raw instruction set for a self-landed swap.
  Future<JupiterBuildResponse> buildSwap(JupiterOrderRequest order) async {
    final response = await _restClient.get(
      '/swap/v2/build',
      queryParameters: order.toQueryParameters(),
    );
    return switch (response) {
      final Map<String, Object?> json => JupiterBuildResponse.fromJson(json),
      _ => throw JupiterException(
        statusCode: 200,
        message: 'Expected a JSON object from /swap/v2/build',
        body: response,
      ),
    };
  }
}

/// Decodes a base64-encoded wire transaction, such as the transaction
/// returned by Jupiter's Swap API.
///
/// Use this after [JupiterSwapClient.getOrder] to inspect the assembled
/// transaction before signing it, and to obtain the object that can be
/// re-encoded with `getBase64EncodedWireTransaction` once signs are attached.
Transaction decodeBase64SwapTransaction(String encodedTransaction) {
  final bytes = getBase64Encoder().encode(encodedTransaction);
  return getTransactionDecoder().decode(bytes);
}
