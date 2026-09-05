import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';

/// The default production portal origin.
const defaultProductionPortalUrl = 'https://publish.solanamobile.com';

/// The default portal origin for local development.
const defaultLocalPortalUrl = 'http://localhost:3333';

/// The default environment variable that holds the portal API key.
const defaultApiKeyEnv = 'DAPP_STORE_API_KEY';

/// How long to wait between `createIngestionSession` retries.
const defaultCreateIngestionSessionRetryDelay = Duration(milliseconds: 1500);

/// Portal client configuration.
final class PortalClientConfig {
  /// Creates a portal client configuration.
  const PortalClientConfig({
    required this.apiBaseUrl,
    required this.apiKey,
    this.client,
    this.createIngestionSessionRetryDelay =
        defaultCreateIngestionSessionRetryDelay,
  });

  /// The tRPC API base URL (for example `https://publish.solanamobile.com/api`).
  final String apiBaseUrl;

  /// The portal API key.
  final SensitiveString apiKey;

  /// The HTTP client used for portal calls.
  final http.Client? client;

  /// Delay between `createIngestionSession` retries.
  final Duration createIngestionSessionRetryDelay;
}

/// A string wrapper that redacts its value in [toString] output.
///
/// Used for the portal API key so that secrets never leak into logs or
/// exception messages.
final class SensitiveString {
  /// Creates a sensitive string.
  const SensitiveString(this.value);

  /// The underlying value.
  final String value;

  @override
  String toString() => 'SensitiveString(****)';

  /// Compares two sensitive strings in constant time.
  @override
  bool operator ==(Object other) {
    if (other is! SensitiveString) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    if (value.length != other.value.length) {
      return false;
    }
    var diff = 0;
    for (var i = 0; i < value.length; i++) {
      diff |= value.codeUnitAt(i) ^ other.value.codeUnitAt(i);
    }
    return diff == 0;
  }

  @override
  int get hashCode => value.length;
}

/// Calls a tRPC procedure on the portal and unwraps the result.
Future<T> callPortalProcedure<T>(
  PortalClientConfig config,
  String procedure,
  Object? input,
  String method, {
  http.Client? client,
  Future<void> Function(Duration)? sleep,
}) async {
  final httpClient = client ?? config.client ?? http.Client();
  final owned = client == null && config.client == null;
  final base = config.apiBaseUrl.replaceFirst(RegExp(r'/+$'), '');
  final url = Uri.parse('$base/trpc/$procedure');
  final headers = <String, String>{
    'accept': 'application/json',
    'x-api-key': config.apiKey.value,
  };

  http.Response response;
  try {
    if (method == 'query') {
      final requestUrl = input != null
          ? url.replace(queryParameters: {'input': jsonEncode(input)})
          : url;
      response = await httpClient.get(requestUrl, headers: headers);
    } else {
      response = await httpClient.post(
        url,
        headers: {
          ...headers,
          'content-type': 'application/json',
        },
        body: input == null ? null : jsonEncode(input),
      );
    }
  } finally {
    if (owned) {
      httpClient.close();
    }
  }

  final text = response.body;
  Object? payload;
  try {
    payload = text.isEmpty ? null : jsonDecode(text);
  } on FormatException {
    final preview = text.replaceAll('\n', ' ').trim();
    throw PublisherCliException(
      'Failed to parse portal response from $procedure: '
      '${preview.length > 180 ? preview.substring(0, 180) : (preview.isEmpty ? '[empty]' : preview)}',
    );
  }

  final normalizedPayload =
      payload is Map<String, Object?> && payload.containsKey('0')
      ? payload['0']
      : payload;
  final record = normalizedPayload is Map<String, Object?>
      ? normalizedPayload
      : <String, Object?>{};

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final error = readDeep(record, 'error.message');
    if (error is String && error.isNotEmpty) {
      throw PublisherCliException('$procedure: $error');
    }
    final nested = readDeep(record, 'result.data');
    if (nested is Map<String, Object?> && nested['_tag'] == 'Left') {
      final left = asRecord(nested['left']);
      final message = optionalString(left['message']);
      if (message != null && message.isNotEmpty) {
        throw PublisherCliException('$procedure: $message');
      }
    }
    throw PublisherCliException(
      '$procedure: Portal request failed with status ${response.statusCode}',
    );
  }

  final result =
      readDeep(record, 'result.data') ??
      readDeep(record, 'result') ??
      <String, Object?>{};
  return _unwrapPortalResult<T>(result, procedure);
}

T _unwrapPortalResult<T>(Object? result, String fallbackMessage) {
  if (result is Map<String, Object?> && result.containsKey('_tag')) {
    final tag = result['_tag'];
    if (tag == 'Left') {
      final left = asRecord(result['left']);
      throw PublisherCliException(
        optionalString(left['message']) ?? fallbackMessage,
      );
    }
    return result['right'] as T;
  }
  if (result is Map<String, Object?>) {
    return result as T;
  }
  throw PublisherCliException(fallbackMessage);
}

/// Uploads [body] to a presigned [uploadUrl] with a PUT request.
Future<void> uploadBytes(
  String uploadUrl,
  Uint8List body,
  String contentType, {
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();
  final owned = client == null;
  final response = await httpClient.put(
    Uri.parse(uploadUrl),
    headers: {'content-type': contentType},
    body: body,
  );
  if (owned) {
    httpClient.close();
  }
  if (response.statusCode < 200 || response.statusCode >= 300) {
    final preview = response.body.replaceAll('\n', ' ').trim();
    throw PublisherCliException(
      'Failed to upload file to the portal: '
      '${preview.isEmpty ? response.reasonPhrase ?? '' : preview}',
    );
  }
}

/// Checks whether a portal error is transient enough to retry the ingestion
/// session creation.
bool isRetryableCreateIngestionSessionError(Object error) {
  final message = error.toString().toLowerCase();
  return message.contains(
        'failed to parse portal response from publication.createingestionsession',
      ) ||
      message.contains('gateway timeout') ||
      message.contains('bad gateway') ||
      message.contains('service unavailable') ||
      message.contains('unexpected token <');
}

/// Calls `publication.createIngestionSession` with bounded retries for
/// transient portal failures.
Future<Map<String, Object?>> callCreateIngestionSessionWithRetry(
  PortalClientConfig config,
  Map<String, Object?> input, {
  http.Client? client,
  Future<void> Function(Duration)? sleep,
}) async {
  final sleepFn = sleep ?? _defaultSleep;

  for (var attempt = 0; ; attempt++) {
    try {
      return await callPortalProcedure<Map<String, Object?>>(
        config,
        'publication.createIngestionSession',
        input,
        'mutation',
        client: client,
      );
    } catch (error) {
      if (!isRetryableCreateIngestionSessionError(error) || attempt >= 2) {
        rethrow;
      }
      await sleepFn(config.createIngestionSessionRetryDelay * (attempt + 1));
    }
  }
}

Future<void> _defaultSleep(Duration duration) async {
  await Future<void>.delayed(duration);
}

/// A portal-backed attestation client.
final class PortalAttestationClient {
  /// Creates an attestation client bound to [config].
  const PortalAttestationClient(this.config);

  /// The portal configuration.
  final PortalClientConfig config;

  /// Fetches the block data used to build attestation payloads.
  Future<({num slot, String blockhash})> getBlockData({
    http.Client? client,
  }) async {
    final result = await callPortalProcedure<Map<String, Object?>>(
      config,
      'attestation.getBlockData',
      const <String, Object?>{},
      'query',
      client: client,
    );
    return (
      slot: numberOrDefault(result['slot'], 0),
      blockhash: asString(result['blockhash']),
    );
  }
}
