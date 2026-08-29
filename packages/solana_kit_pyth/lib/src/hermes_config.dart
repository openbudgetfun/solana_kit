/// Configuration for connecting to a Pyth Hermes price service.
///
/// The default [baseUrl] points at the official Hermes endpoint
/// (`https://hermes.pyth.network`). Self-hosted price services can be used by
/// passing an alternative [baseUrl].
class HermesConfig {
  /// Creates a new Hermes configuration.
  ///
  /// [baseUrl] defaults to the official `https://hermes.pyth.network` price
  /// service. [timeout] defaults to 5 seconds, [httpRetries] defaults to 3,
  /// and [backoffMs] controls the initial delay of the exponential retry
  /// back-off (default 100 ms).
  const HermesConfig({
    this.baseUrl = defaultHermesBaseUrl,
    this.timeout = const Duration(seconds: 5),
    this.httpRetries = defaultHermesHttpRetries,
    this.backoffMs = 100,
    this.headers = const {},
    this.accessToken,
  });

  /// The default Hermes price service endpoint.
  static const String defaultHermesBaseUrl = 'https://hermes.pyth.network';

  /// The default number of times a request is retried before failing.
  static const int defaultHermesHttpRetries = 3;

  /// Base URL of the price service, without a trailing slash.
  ///
  /// All paths are appended under the `/v2` prefix, mirroring the behavior of
  /// the upstream `@pythnetwork/hermes-client` TypeScript package.
  final String baseUrl;

  /// Maximum time a single HTTP request may take before it is aborted.
  final Duration timeout;

  /// Number of times an HTTP request is retried before failing.
  ///
  /// Retries use an exponential back-off starting at [backoffMs] and apply to
  /// transport failures, timeouts, HTTP 408/429 responses, and HTTP 5xx
  /// responses. Responses with other 4xx status codes fail immediately.
  final int httpRetries;

  /// Initial delay in milliseconds before the first retry.
  final int backoffMs;

  /// Optional headers included in every request, for example custom
  /// authorization or proxy headers.
  final Map<String, String> headers;

  /// Optional access token used for authenticated providers.
  ///
  /// When set, requests carry the token as a `Bearer` token in the
  /// `Authorization` header.
  final String? accessToken;

  /// Base URL of the price service with any trailing slash removed.
  ///
  /// All request paths are appended under the `/v2` prefix, mirroring the
  /// behavior of the upstream `@pythnetwork/hermes-client` TypeScript
  /// package.
  String get normalizedBaseUrl => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  @override
  String toString() => 'HermesConfig(baseUrl: $baseUrl, timeout: $timeout)';
}
