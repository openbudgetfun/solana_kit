// ignore_for_file: public_member_api_docs
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/src/types/admin_types.dart';

class AdminClient {
  const AdminClient({
    required this._baseUrl,
    required this._apiKey,
    required this._client,
  });

  final String _baseUrl;
  final String _apiKey;
  final http.Client _client;

  Future<ProjectUsage> getProjectUsage(String projectId) async {
    final uri = Uri.parse(_baseUrl).replace(
      pathSegments: [
        ...Uri.parse(
          _baseUrl,
        ).pathSegments.where((segment) => segment.isNotEmpty),
        'admin',
        'projects',
        projectId,
        'usage',
      ],
    );
    final response = await _client.get(
      uri,
      headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'x-api-key': _apiKey,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw createSolanaError(
        SolanaErrorCode.heliusRestError,
        context: {
          SolanaErrorContextKeys.operation: 'heliusAdmin',
          SolanaErrorContextKeys.statusCode: response.statusCode,
          'message': response.body.isNotEmpty
              ? response.body
              : (response.reasonPhrase ?? 'Unknown error'),
        },
      );
    }
    return ProjectUsage.fromJson(
      jsonDecode(response.body) as Map<String, Object?>,
    );
  }
}
