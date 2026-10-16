// The catch-and-rethrow below deliberately catches Error subclasses so
// programming errors are not swallowed by the conservative null fallback;
// that is exactly what avoid_catching_errors exists to flag.
// ignore_for_file: avoid_catching_errors
import 'dart:convert';

import 'package:http/http.dart' as http;

/// URL for the Helius priority fee estimate endpoint.
const heliusTipFloorUrl = 'https://mainnet.helius-rpc.com/';

/// Fetches the 75th percentile landed tip floor from the Helius RPC
/// endpoint, or null if it cannot be determined.
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
  } on ArgumentError {
    // A bad endpoint is a programming error; the conservative null fallback
    // exists for transient network and response-shape failures, not for
    // hiding mistakes in the caller's arguments.
    rethrow;
  } on TypeError {
    rethrow;
  } on Object {
    return null;
  } finally {
    if (closeClient) httpClient.close(); // coverage:ignore-line
  }
}
