import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_kit_helius/src/transactions/sender.dart';

/// Sends a base64 transaction to a regional Helius Sender `/fast` endpoint.
///
/// Sender mandates `skipPreflight: true` and `maxRetries: 0`.
Future<String> sendViaSender(
  String transaction, {
  SenderRegion region = SenderRegion.defaultRegion,
  bool swqosOnly = false,
  http.Client? client,
}) async {
  final endpoint = swqosOnly
      ? '${senderFastUrl(region)}?swqos_only=true'
      : senderFastUrl(region);
  final effectiveClient = client ?? http.Client(); // coverage:ignore-line
  final shouldClose = client == null; // coverage:ignore-line

  try {
    final response = await effectiveClient.post(
      Uri.parse(endpoint),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'method': 'sendTransaction',
        'params': [
          transaction,
          {'encoding': 'base64', 'skipPreflight': true, 'maxRetries': 0},
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = response.body.length > 200
          ? response.body.substring(0, 200)
          : response.body; // coverage:ignore-line
      throw Exception('Sender HTTP ${response.statusCode}: $message');
    }

    return _readSenderSignature(jsonDecode(response.body));
  } finally {
    if (shouldClose) effectiveClient.close(); // coverage:ignore-line
  }
}

String _readSenderSignature(Object? body) {
  if (body case final String signature) return signature;

  if (body case final Map<String, Object?> response) {
    final error = response['error'];
    if (error != null) throw Exception(jsonEncode(error));

    if (response['result'] case final String signature) return signature;
  }

  throw Exception('Unexpected Sender response: ${jsonEncode(body)}');
}
