import 'package:http/http.dart' as http;
import 'package:solana_kit_helius/src/internal/redact_url.dart';

/// Sends an HTTP request without exposing endpoint credentials on failure.
Future<http.Response> sendHeliusRequest(
  Uri uri,
  Future<http.Response> Function() send,
) async {
  try {
    return await send();
  } on http.ClientException {
    // Client exceptions may embed the complete URL in both message and URI.
    throw http.ClientException(
      'Helius HTTP request failed',
      Uri.parse(redactUrl(uri.toString())),
    );
  }
}
