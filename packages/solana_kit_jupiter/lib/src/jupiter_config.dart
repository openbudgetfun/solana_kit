import 'package:http/http.dart';

/// The default Jupiter API base URL.
///
/// Jupiter serves keyless traffic at a reduced rate limit on this host.
/// Passing an API key from the Jupiter developer portal unlocks higher
/// tiers; the base URL itself stays the same.
const String defaultJupiterBaseUrl = 'https://api.jup.ag';

/// Configuration for connecting to Jupiter Exchange APIs.
///
/// All Jupiter endpoints live under a single base URL (`https://api.jup.ag`)
/// and authenticate through an optional `x-api-key` header. Without an API
/// key, keyless access is served at a reduced rate limit.
///
/// Use [client] to inject a custom HTTP client for testing.
class JupiterConfig {
  /// Creates a new Jupiter configuration.
  ///
  /// The [apiKey] is optional: Jupiter serves keyless traffic at a reduced
  /// rate limit on the same base URL. The [baseUrl] defaults to
  /// `https://api.jup.ag`. Set [client] to inject a custom HTTP client
  /// for testing.
  JupiterConfig({
    this.apiKey,
    this.baseUrl = defaultJupiterBaseUrl,
    Client? client,
  }) : client = client ?? Client();

  /// The Jupiter API key, or `null` for keyless access.
  ///
  /// The key is sent as the `x-api-key` request header on every call.
  final String? apiKey;

  /// The Jupiter API base URL.
  final String baseUrl;

  /// The HTTP client used for all API calls.
  final Client client;

  @override
  String toString() =>
      'JupiterConfig(baseUrl: $baseUrl, apiKey: ${apiKey == null ? 'null' : '***'})';
}
