// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:http/http.dart' as http;

const heliusTipFloorUrl = 'https://mainnet.helius-rpc.com/';

Future<double?> fetchTipFloor75th({
  http.Client? client,
  String endpoint = heliusTipFloorUrl,
}) async {
  final httpClient = client ?? http.Client(); // coverage:ignore-line
  final closeClient = client == null; // coverage:ignore-line

  try {
    final response = await httpClient.post(
      Uri.parse(endpoint),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(<String, Object?>{
        'jsonrpc': '2.0',
        'id': '1',
        'method': 'getPriorityFeeEstimate',
        'params': <Object?>[
          {
            'options': {'recommended': true},
          },
        ],
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map<String, Object?>) {
        final value = first['landed_tips_75th_percentile'];
        if (value is num) return value.toDouble();
      }
    }
    if (decoded is Map<String, Object?>) {
      final result = decoded['result'];
      if (result is Map<String, Object?>) {
        final value = result['landed_tips_75th_percentile'];
        if (value is num) return value.toDouble();
      }
    }
    return null;
  } on Object catch (_) {
    return null;
  } finally {
    if (closeClient) httpClient.close(); // coverage:ignore-line
  }
}
