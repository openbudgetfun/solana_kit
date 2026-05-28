/// Helius DAS API client implementation for compressed NFT operations.
///
/// This provides a concrete implementation of [DasApiClient] using the
/// Helius Digital Asset Standard (DAS) API.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_mpl_bubblegum/src/das_api.dart';

/// A DAS API client that uses the Helius API.
///
/// ```dart
/// final client = HeliusDasClient(
///   rpcUrl: 'https://mainnet.helius-rpc.com/?api-key=YOUR_API_KEY',
/// );
///
/// final asset = await client.getAsset('assetId');
/// final proof = await client.getAssetProof('assetId');
/// ```
class HeliusDasClient implements DasApiClient {
  /// Creates a [HeliusDasClient].
  ///
  /// [rpcUrl] is the full Helius RPC URL including the API key.
  /// For example: `https://mainnet.helius-rpc.com/?api-key=YOUR_API_KEY`
  const HeliusDasClient({
    required this.rpcUrl,
    http.Client? client,
  }) : _client = client;

  /// The Helius RPC URL (including API key).
  final String rpcUrl;

  /// Optional HTTP client. If null, creates a new one per request.
  final http.Client? _client;

  @override
  Future<DasAsset> getAsset(String assetId) async {
    final response = await _sendRequest('getAsset', [assetId]);
    return _parseAsset(response);
  }

  @override
  Future<DasAssetProof> getAssetProof(String assetId) async {
    final response = await _sendRequest('getAssetProof', [assetId]);
    return _parseAssetProof(response);
  }

  /// Sends a JSON-RPC request to the Helius DAS API.
  Future<Map<String, dynamic>> _sendRequest(
    String method,
    List<dynamic> params,
  ) async {
    final client = _client ?? http.Client();
    try {
      final body = jsonEncode({
        'jsonrpc': '2.0',
        'id': 'solana-kit-das',
        'method': method,
        'params': params,
      });

      final response = await client.post(
        Uri.parse(rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        throw HeliusDasException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json.containsKey('error')) {
        final error = json['error'] as Map<String, dynamic>;
        throw HeliusDasException(
          'RPC Error ${error['code']}: ${error['message']}',
          code: error['code'] as int?,
        );
      }

      return json['result'] as Map<String, dynamic>;
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  /// Parses a DAS asset response into a [DasAsset].
  static DasAsset _parseAsset(Map<String, dynamic> data) {
    final ownership =
        (data['ownership'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final compression =
        (data['compression'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final content = data['content'] as Map<String, dynamic>?;
    final creatorsList = (data['creators'] as List<dynamic>?) ?? [];
    final groupingList = (data['grouping'] as List<dynamic>?) ?? [];

    final contentMetadata =
        content?['metadata'] as Map<String, dynamic>?;

    return DasAsset(
      id: (data['id'] as String?) ?? '',
      ownership: DasAssetOwnership(
        frozen: (ownership['frozen'] as bool?) ?? false,
        nonTransferable: (ownership['non_transferable'] as bool?) ?? false,
      ),
      compression: DasAssetCompression(
        compressed: (compression['compressed'] as bool?) ?? false,
        dataHash: (compression['data_hash'] as String?) ?? '',
        creatorHash: (compression['creator_hash'] as String?) ?? '',
        assetHash: (compression['asset_hash'] as String?) ?? '',
        tree: (compression['tree'] as String?) ?? '',
        seq: (compression['seq'] as int?) ?? 0,
        leafId: (compression['leaf_id'] as int?) ?? 0,
      ),
      content: content != null
          ? DasAssetContent(
              metadata: contentMetadata != null
                  ? DasAssetMetadata(
                      name: contentMetadata['name'] as String?,
                      symbol: contentMetadata['symbol'] as String?,
                      description: contentMetadata['description'] as String?,
                      image: contentMetadata['image'] as String?,
                    )
                  : null,
            )
          : null,
      creators: creatorsList.map((c) {
        final creator = c as Map<String, dynamic>;
        return DasAssetCreator(
          address: (creator['address'] as String?) ?? '',
          share: (creator['share'] as int?) ?? 0,
          verified: (creator['verified'] as bool?) ?? false,
        );
      }).toList(),
      grouping: groupingList.map((g) {
        final group = g as Map<String, dynamic>;
        return DasAssetGrouping(
          groupKey: (group['group_key'] as String?) ?? '',
          groupValue: (group['group_value'] as String?) ?? '',
        );
      }).toList(),
    );
  }

  /// Parses a DAS asset proof response into a [DasAssetProof].
  static DasAssetProof _parseAssetProof(Map<String, dynamic> data) {
    final proof = data['proof'] as List<dynamic>? ?? [];

    return DasAssetProof(
      root: data['root'] as String? ?? '',
      proof: proof.map((p) => p.toString()).toList(),
      nodeIndex: data['node_index'] as int? ?? 0,
      leaf: data['leaf'] as String? ?? '',
      treeId: data['tree_id'] as String? ?? '',
    );
  }
}

/// Exception thrown by the Helius DAS API client.
class HeliusDasException implements Exception {
  /// Creates a [HeliusDasException].
  const HeliusDasException(
    this.message, {
    this.code,
    this.statusCode,
  });

  /// The error message.
  final String message;

  /// The JSON-RPC error code (if applicable).
  final int? code;

  /// The HTTP status code (if applicable).
  final int? statusCode;

  @override
  String toString() => 'HeliusDasException: $message';
}
