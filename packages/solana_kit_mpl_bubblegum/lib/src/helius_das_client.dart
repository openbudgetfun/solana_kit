/// Helius DAS API client implementation for compressed NFT operations.
///
/// This provides a concrete implementation of [DasApiClient] using the
/// Helius Digital Asset Standard (DAS) API.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/src/das_api.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/types.dart';
import 'package:solana_kit_mpl_bubblegum/src/leaf/leaf_metadata.dart';

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
  const HeliusDasClient({required this.rpcUrl, this._client});

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
    final creatorsRawList = data['creators_raw'] as List<dynamic>?;
    final groupingList = (data['grouping'] as List<dynamic>?) ?? [];

    final royalty = data['royalty'] as Map<String, dynamic>?;
    final supply = data['supply'] as Map<String, dynamic>?;

    final contentMetadata = content?['metadata'] as Map<String, dynamic>?;

    final grouping = groupingList.map((g) {
      final group = g as Map<String, dynamic>;
      return DasAssetGrouping(
        groupKey: (group['group_key'] as String?) ?? '',
        groupValue: (group['group_value'] as String?) ?? '',
        verified: (group['verified'] as bool?) ?? false,
      );
    }).toList();

    // The `collection` grouping entry is the asset's collection; DAS reports
    // its verification under the same object.
    DasAssetGrouping? collectionGroup;

    for (final group in grouping) {
      if (group.groupKey == 'collection' && group.groupValue.isNotEmpty) {
        collectionGroup = group;
        break;
      }
    }

    DasAssetRoyalty? parsedRoyalty;

    if (royalty != null) {
      final basisPoints = royalty['basis_points'] as int?;
      parsedRoyalty = DasAssetRoyalty(
        basisPoints: basisPoints,
        basisPointsRaw: royalty['basis_points_raw'] as int?,
        primarySaleHappened: royalty['primary_sale_happened'] as bool?,
        inherited:
            (royalty['sfbp_inherited'] as bool?) ??
            (royalty['inherited'] as bool?) ??
            basisPoints == sellerFeeBasisPointsInherit,
      );
    }

    return DasAsset(
      id: _requireString(data, 'id'),
      ownership: DasAssetOwnership(
        owner: _requireString(ownership, 'owner'),
        delegate: ownership['delegate'] as String?,
        frozen: _requireBool(ownership, 'frozen'),
        nonTransferable: (ownership['non_transferable'] as bool?) ?? false,
      ),
      compression: DasAssetCompression(
        compressed: _requireBool(compression, 'compressed'),
        dataHash: _requireString(compression, 'data_hash'),
        creatorHash: _requireString(compression, 'creator_hash'),
        assetHash: _requireString(compression, 'asset_hash'),
        tree: _requireString(compression, 'tree'),
        seq: _requireInt(compression, 'seq'),
        leafId: _requireInt(compression, 'leaf_id'),
        collectionHash: compression['collection_hash'] as String?,
        assetDataHash: compression['asset_data_hash'] as String?,
        flags: compression['flags'] as int?,
      ),
      content: content != null
          ? DasAssetContent(
              jsonUri: content['json_uri'] as String?,
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
      creators: creatorsList.map(_parseCreator).toList(),
      creatorsRaw: creatorsRawList?.map(_parseCreator).toList(),
      grouping: grouping,
      royalty: parsedRoyalty,
      collection: collectionGroup == null
          ? null
          : Collection(
              key: Address(collectionGroup.groupValue),
              verified: collectionGroup.verified,
            ),
      mutable: (data['mutable'] as bool?) ?? true,
      editionNonce: supply?['edition_nonce'] as int?,
    );
  }

  static DasAssetCreator _parseCreator(dynamic c) {
    final creator = c as Map<String, dynamic>;
    return DasAssetCreator(
      address: _requireString(creator, 'address'),
      share: _requireInt(creator, 'share'),
      verified: _requireBool(creator, 'verified'),
    );
  }

  /// Parses a DAS asset proof response into a [DasAssetProof].
  static DasAssetProof _parseAssetProof(Map<String, dynamic> data) {
    final proof = data['proof'] as List<dynamic>?;
    if (proof == null) {
      throw const FormatException(
        'DAS getAssetProof response is missing the proof path',
      );
    }

    return DasAssetProof(
      root: _requireString(data, 'root'),
      proof: proof.map((p) => p.toString()).toList(),
      nodeIndex: _requireInt(data, 'node_index'),
      leaf: _requireString(data, 'leaf'),
      treeId: _requireString(data, 'tree_id'),
    );
  }
}

String _requireString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException(
      'Expected DAS response field "$key" to be a non-empty string',
    );
  }
  return value;
}

int _requireInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException(
      'Expected DAS response field "$key" to be an integer',
    );
  }
  return value;
}

bool _requireBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! bool) {
    throw FormatException('Expected DAS response field "$key" to be a boolean');
  }
  return value;
}

/// Exception thrown by the Helius DAS API client.
class HeliusDasException implements Exception {
  /// Creates a [HeliusDasException].
  const HeliusDasException(this.message, {this.code, this.statusCode});

  /// The error message.
  final String message;

  /// The JSON-RPC error code (if applicable).
  final int? code;

  /// The HTTP status code (if applicable).
  final int? statusCode;

  @override
  String toString() => 'HeliusDasException: $message';
}
