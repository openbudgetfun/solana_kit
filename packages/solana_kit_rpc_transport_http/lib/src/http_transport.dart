import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

import 'package:solana_kit_rpc_transport_http/src/http_transport_config.dart';
import 'package:solana_kit_rpc_transport_http/src/http_transport_headers.dart';

/// Creates a function you can use to make `POST` requests with headers suitable
/// for sending JSON data to a server.
///
/// The returned [RpcTransport] sends the payload as a JSON-encoded body and
/// expects a JSON response.
///
/// ```dart
/// final transport = createHttpTransport(
///   HttpTransportConfig(url: 'https://api.mainnet-beta.solana.com'),
/// );
/// final response = await transport(
///   RpcTransportConfig(
///     payload: {'id': 1, 'jsonrpc': '2.0', 'method': 'getSlot'},
///   ),
/// );
/// ```
///
/// Optionally pass an [http.Client] via [client] to control the HTTP client
/// used for requests (useful for testing with a mock client). Completing
/// [RpcTransportConfig.signal] aborts the request and response stream when the
/// client supports [http.AbortableRequest], including the default client.
/// Redirect responses are rejected to keep credentials at the configured URL.
RpcTransport createHttpTransport(
  HttpTransportConfig config, {
  http.Client? client,
}) {
  final HttpTransportConfig(
    :allowInsecureHttp,
    :fromJson,
    :headers,
    :inboundLimits,
    :toJson,
    :url,
  ) = config;
  inboundLimits.validate();
  final endpointUrl = _validateAndNormalizeHttpEndpoint(
    url,
    allowInsecureHttp: allowInsecureHttp,
  );

  // Validate headers unconditionally to prevent forbidden headers in all
  // build modes (debug and release).
  if (headers != null) {
    assertIsAllowedHttpRequestHeaders(headers);
  }

  final customHeaders = headers != null ? normalizeHeaders(headers) : null;
  final effectiveClient = client ?? http.Client();

  return (RpcTransportConfig transportConfig) async {
    final payload = transportConfig.payload;
    final body = toJson != null ? toJson(payload) : jsonEncode(payload);
    final bodyBytes = utf8.encode(body);

    final mergedHeaders = <String, String>{
      ...?customHeaders,
      // Protocol headers are applied last so they cannot be overridden.
      'accept': 'application/json',
      'content-length': bodyBytes.length.toString(),
      'content-type': 'application/json; charset=utf-8',
    };

    final budgetAbort = Completer<void>();
    final request =
        http.AbortableRequest(
            'POST',
            endpointUrl,
            abortTrigger: transportConfig.signal == null
                ? budgetAbort.future
                : Future.any([transportConfig.signal!, budgetAbort.future]),
          )
          ..followRedirects = false
          ..headers.addAll(mergedHeaders)
          ..bodyBytes = bodyBytes;
    final http.Response response;
    try {
      response = await _readBoundedResponse(
        await effectiveClient.send(request),
        inboundLimits,
      );
    } on InboundPayloadLimitException {
      budgetAbort.complete();
      rethrow;
    } on http.RequestAbortedException {
      throw http.RequestAbortedException();
    } on http.ClientException {
      // Client messages and URIs can both contain endpoint credentials.
      throw http.ClientException('HTTP transport request failed.');
    }

    if (response.statusCode != 200) {
      throw SolanaError(SolanaErrorCode.rpcTransportHttpError, {
        'statusCode': response.statusCode,
        'message': response.reasonPhrase ?? 'Unknown error',
      });
    }

    final responseBody = response.body;
    inboundLimits.checkText(responseBody);

    if (fromJson != null) {
      return fromJson(responseBody, payload);
    }

    return jsonDecode(responseBody);
  };
}

/// Cancels at the first chunk beyond the budget, including chunked or
/// misleadingly short Content-Length responses, without retaining that chunk.
Future<http.Response> _readBoundedResponse(
  http.StreamedResponse response,
  InboundPayloadLimits limits,
) async {
  if ((response.contentLength ?? 0) > limits.maxBytes) {
    await response.stream.listen(null).cancel();
    throw InboundPayloadLimitException('bytes', limits.maxBytes);
  }

  final bytes = BytesBuilder(copy: false);

  await for (final chunk in response.stream) {
    limits.checkByteLength(bytes.length + chunk.length);
    bytes.add(chunk);
  }

  return http.Response.bytes(
    bytes.takeBytes(),
    response.statusCode,
    headers: response.headers,
    isRedirect: response.isRedirect,
    persistentConnection: response.persistentConnection,
    reasonPhrase: response.reasonPhrase,
    request: response.request,
  );
}

Uri _validateAndNormalizeHttpEndpoint(
  String url, {
  required bool allowInsecureHttp,
}) {
  final parsedUrl = Uri.parse(url);
  final scheme = parsedUrl.scheme.toLowerCase();

  if (!parsedUrl.isAbsolute || parsedUrl.host.isEmpty) {
    throw ArgumentError.value(
      url,
      'url',
      'HTTP transport URL must be an absolute URL.',
    );
  }

  if (scheme == 'https') {
    return parsedUrl;
  }

  if (scheme == 'http' && allowInsecureHttp) {
    // In release (product) mode, http:// is never allowed regardless of
    // the allowInsecureHttp flag. This prevents accidental use of insecure
    // HTTP connections in production, mirroring the WebSocket transport's
    // release-mode lockdown. The branch is a compile-time constant under
    // `dart test`, where it can never execute.
    const isProduction = bool.fromEnvironment('dart.vm.product');

    // coverage:ignore-start
    if (isProduction) {
      throw ArgumentError.value(
        url,
        'url',
        'Insecure HTTP endpoints are not allowed in release mode. '
            'Use an https:// URL instead.',
      );
    }

    // coverage:ignore-end
    return parsedUrl;
  }

  if (scheme == 'http') {
    throw ArgumentError.value(
      url,
      'url',
      'Insecure HTTP endpoints are disabled by default. '
          'Use an https:// URL or set allowInsecureHttp: true for '
          'development.',
    );
  }

  throw ArgumentError.value(
    url,
    'url',
    "HTTP transport URL must use either 'https' or 'http'.",
  );
}
