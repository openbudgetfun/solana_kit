/// Configuration for creating an HTTP transport.
///
/// Pass an instance of this class to `createHttpTransport` to create a
/// transport that makes JSON-RPC requests over HTTP.
class HttpTransportConfig {
  /// Creates a new [HttpTransportConfig].
  ///
  /// The [url] parameter is required and must be a valid HTTP or HTTPS URL.
  const HttpTransportConfig({
    required this.url,
    this.fromJson,
    this.headers,
    this.toJson,
  });

  /// A string representing the target endpoint.
  ///
  /// Must be an absolute URL using the `http` or `https` protocol.
  final String url;

  /// An optional function that takes the response as a JSON string and
  /// converts it to a JSON value.
  ///
  /// The request payload is also provided as a second argument.
  ///
  /// When not provided, the response body will be decoded using
  /// `jsonDecode` from `dart:convert`.
  final Object? Function(String rawResponse, Object? payload)? fromJson;

  /// An optional map of headers to set on the request.
  ///
  /// Avoid [forbidden headers](https://developer.mozilla.org/en-US/docs/Glossary/Forbidden_header_name).
  /// Additionally, the headers `Accept`, `Content-Length`, and `Content-Type`
  /// are disallowed.
  final Map<String, String>? headers;

  /// An optional function that takes the request payload and converts it to
  /// a JSON string.
  ///
  /// When not provided, `jsonEncode` from `dart:convert` will be used.
  final String Function(Object? payload)? toJson;
}
