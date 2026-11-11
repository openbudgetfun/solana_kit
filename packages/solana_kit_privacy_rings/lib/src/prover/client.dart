import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:solana_kit_privacy_rings/src/codec/transact.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/prover/proof.dart';
import 'package:solana_kit_privacy_rings/src/prover/tee_session.dart';
import 'package:solana_kit_privacy_rings/src/redact.dart';

/// HTTP client for the Helius remote prover.
///
/// A proof is `POST {prover}/prove/{circuit}` with header `X-Sync: true`.
/// A `429` is retried once with `X-Async: true`. A body that contains
/// `jobId` and no `proof` is polled at
/// `{prover}/prove/{circuit}/status?jobId=`. This is `ProverClient.send`
/// in `sdk-libs/ts/src/client/prover/client.ts`.
///
/// The request body is the witness JSON the caller already built, or the
/// map returned by `confidentialTransferWitness`. Poseidon commitments
/// and nullifiers in that map are computed in this package.
///
/// A prover that is not on a loopback host refuses a cleartext call unless
/// [allowUnauthenticatedRemoteProver] is set or [tee] is set. [tee] is the
/// attested session: it fetches `/attestation`, verifies the AWS Nitro
/// COSE document against the policy measurements, checks the `report_data`
/// binding, and encrypts the witness. Loopback provers accept cleartext
/// JSON.
class PrivacyProverClient {
  /// Creates a client for [endpoint], for example `http://127.0.0.1:3001`
  /// or `https://mainnet.helius-rpc.com/v1/spr`.
  PrivacyProverClient({
    required Uri endpoint,
    http.Client? httpClient,
    String? apiKey,
    this.allowUnauthenticatedRemoteProver = false,
    this.tee,
    this.runtimeProvingKeys = false,
    this.pollInterval = const Duration(milliseconds: 25),
    this.maxPollInterval = const Duration(seconds: 1),
    this.maxWait = const Duration(minutes: 20),
  }) : _http = httpClient ?? http.Client(),
       _ownsClient = httpClient == null,
       _apiKey = _takeApiKey(endpoint, apiKey),
       _endpoint = _withoutApiKey(endpoint);

  final http.Client _http;
  final bool _ownsClient;
  final String? _apiKey;
  final Uri _endpoint;

  /// Sends the witness in the clear to a non-loopback prover.
  final bool allowUnauthenticatedRemoteProver;

  /// Attested session. When set, prove calls are encrypted to it.
  final TeeSession? tee;

  /// Refuses the indexed route, which proves against the prover's own keys.
  ///
  /// A runtime proving-key set and the indexed route cannot be combined.
  /// `ProverClient.#indexedAllowed` throws the same refusal.
  final bool runtimeProvingKeys;

  /// First gap between status polls. Later gaps double up to
  /// [maxPollInterval].
  final Duration pollInterval;

  /// Ceiling for the gap between status polls.
  final Duration maxPollInterval;

  /// Wall-clock bound for a queued proof.
  final Duration maxWait;

  /// Releases the HTTP client when this object created it.
  void close() {
    if (_ownsClient) _http.close();
  }

  /// Asks the prover to prove [circuit] for [witness] and returns the
  /// compressed proof.
  ///
  /// [witness] is encoded with [jsonEncode] and posted unchanged apart
  /// from that encoding. [circuit] is the proving-key name without
  /// `.key`, for example `transfer_confidential_1_2`.
  Future<TransactProof> prove({
    required String circuit,
    required Map<String, Object?> witness,
  }) {
    return _prove(circuit, witness, indexed: false);
  }

  /// Posts [witness] to `POST /prove/{circuit}/indexed`.
  ///
  /// The indexed route asks the prover to fill Merkle paths from the
  /// trees named in the body. A client that pins its own proving keys
  /// cannot use it: the prover would prove against a different key.
  Future<TransactProof> proveIndexed({
    required String circuit,
    required Map<String, Object?> witness,
  }) {
    if (runtimeProvingKeys) {
      throw PrivacyRingsException(
        'the indexed prover route is refused when runtime proving keys are set',
        code: 'indexed_proving_unsupported',
      );
    }
    return _prove(circuit, witness, indexed: true);
  }

  Future<TransactProof> _prove(
    String circuit,
    Map<String, Object?> witness, {
    required bool indexed,
  }) async {
    _requireTransport();
    final name = circuit.endsWith('.key')
        ? circuit.substring(0, circuit.length - 4)
        : circuit;
    if (name.isEmpty || name.contains('/') || name.contains('..')) {
      throw PrivacyRingsException(
        'circuit name is not a single path segment',
        code: 'invalid_request',
      );
    }
    final suffix = indexed
        ? '/prove/${Uri.encodeComponent(name)}/indexed'
        : '/prove/${Uri.encodeComponent(name)}';
    final url = _url(suffix);
    final body = jsonEncode(witness);
    var queued = false;
    for (var attempt = 0; attempt < 2; attempt++) {
      final delivery = queued ? 'X-Async' : 'X-Sync';
      final response = await _send(
        () => _post(url, suffix, body, {delivery: 'true'}),
      );
      if (response.statusCode == 429 && !queued) {
        queued = true;
        continue;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw PrivacyRingsException(
          'prover HTTP ${response.statusCode} for $name at ${redactUri(url)}',
          code: 'prover_http',
        );
      }
      final value = _json(response.body);
      if (value is Map &&
          value['jobId'] is String &&
          !value.containsKey('proof')) {
        return parseProverProof(
          await _poll(name, value['jobId'] as String),
          circuit: name,
        );
      }
      return parseProverProof(value, circuit: name);
    }
    // Each attempt returns or throws. A 429 is retried once, then a
    // second non-success status throws above.
    // coverage:ignore-start
    throw PrivacyRingsException(
      'prover did not accept a synchronous or queued proof for $name',
      code: 'prover_http',
    );
    // coverage:ignore-end
  }

  void _requireTransport() {
    final loopback =
        _endpoint.host == '127.0.0.1' ||
        _endpoint.host == 'localhost' ||
        _endpoint.host == '::1';
    if (!loopback && tee == null && !allowUnauthenticatedRemoteProver) {
      throw PrivacyRingsException(
        'a remote prover requires an attested TeeSession, or '
        'allowUnauthenticatedRemoteProver for a prover that accepts cleartext',
        code: 'prover_tee_required',
      );
    }
    if (!loopback && _endpoint.scheme != 'https') {
      throw PrivacyRingsException(
        'a remote prover URL must be https',
        code: 'invalid_config',
      );
    }
  }

  Future<http.Response> _post(
    Uri url,
    String route,
    String body,
    Map<String, String> extraHeaders,
  ) {
    final session = tee;
    if (session == null) {
      return _http.post(
        url,
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json; charset=utf-8',
          ...extraHeaders,
        },
        body: body,
      );
    }
    return session.send(
      client: _http,
      attestationUrl: _url('/attestation'),
      url: url,
      route: route,
      method: 'POST',
      headers: {
        'accept': 'application/json',
        'content-type': 'application/json; charset=utf-8',
        ...extraHeaders,
      },
      body: body,
    );
  }

  Future<Object?> _poll(String circuit, String jobId) async {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,256}$').hasMatch(jobId)) {
      throw PrivacyRingsException(
        'prover job id is not a safe token',
        code: 'prover_job',
      );
    }
    final url = _url('/prove/${Uri.encodeComponent(circuit)}/status', {
      'jobId': jobId,
    });
    final deadline = DateTime.now().add(maxWait);
    var interval = pollInterval;
    while (true) {
      if (!DateTime.now().isBefore(deadline)) {
        throw PrivacyRingsException(
          'prover job $jobId did not finish within ${maxWait.inMilliseconds} ms',
          code: 'prover_timeout',
        );
      }
      final statusRoute = '/prove/${Uri.encodeComponent(circuit)}/status';
      final response = await _send(() {
        final session = tee;
        if (session == null) {
          return _http.get(url, headers: const {'accept': 'application/json'});
        }
        return session.send(
          client: _http,
          attestationUrl: _url('/attestation'),
          url: url,
          route: statusRoute,
          method: 'GET',
          headers: const {'accept': 'application/json'},
        );
      });
      if (response.statusCode >= 400 && response.statusCode < 500) {
        throw PrivacyRingsException(
          'prover status HTTP ${response.statusCode} at ${redactUri(url)}',
          code: 'prover_http',
        );
      }
      if (response.statusCode >= 500) {
        interval = await _wait(interval, deadline);
        continue;
      }
      final value = _json(response.body);
      if (value is! Map) {
        throw PrivacyRingsException(
          'prover status was not an object',
          code: 'invalid_response',
        );
      }
      final status = value['status'];
      if (status == 'failed') {
        throw PrivacyRingsException(
          'prover job $jobId failed',
          code: 'prover_server',
        );
      }
      if (status == 'completed') {
        return value.containsKey('result') ? value['result'] : value;
      }
      interval = await _wait(interval, deadline);
    }
  }

  Future<Duration> _wait(Duration interval, DateTime deadline) async {
    final remaining = deadline.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      throw PrivacyRingsException(
        'prover job did not finish within ${maxWait.inMilliseconds} ms',
        code: 'prover_timeout',
      );
    }
    final pause = interval < remaining ? interval : remaining;
    await Future<void>.delayed(pause);
    final doubled = interval * 2;
    return doubled < maxPollInterval ? doubled : maxPollInterval;
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on Object catch (error) {
      throw PrivacyRingsException(
        'prover request failed: ${redactSecrets(error.toString())}',
        code: 'prover_transport',
      );
    }
  }

  Object? _json(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw PrivacyRingsException(
        'prover response was not JSON',
        code: 'invalid_response',
      );
    }
  }

  Uri _url(String suffix, [Map<String, String> extraQuery = const {}]) {
    final basePath = _endpoint.path.replaceAll(RegExp(r'/+$'), '');
    final query = Map<String, String>.from(_endpoint.queryParameters)
      ..addAll(extraQuery);
    final key = _apiKey;
    if (key != null) query['api-key'] = key;
    return _endpoint.replace(
      path: '$basePath$suffix',
      queryParameters: query.isEmpty ? null : query,
    );
  }
}

String? _takeApiKey(Uri endpoint, String? apiKey) {
  final queryKey = endpoint.queryParameters['api-key'];
  if (apiKey != null && queryKey != null) {
    throw PrivacyRingsException(
      'pass the API key either in the URL or as apiKey, not both',
      code: 'invalid_config',
    );
  }
  final key = apiKey ?? queryKey;
  if (key != null && key.isEmpty) {
    throw PrivacyRingsException('API key is empty', code: 'invalid_config');
  }
  return key;
}

Uri _withoutApiKey(Uri endpoint) {
  if (!endpoint.queryParameters.containsKey('api-key')) return endpoint;
  final query = Map<String, String>.from(endpoint.queryParameters)
    ..remove('api-key');
  return endpoint.replace(queryParameters: query.isEmpty ? null : query);
}
