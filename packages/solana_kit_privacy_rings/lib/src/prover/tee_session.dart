import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/prover/hpke.dart';
import 'package:solana_kit_privacy_rings/src/prover/nitro.dart';

/// Policy an attested prover session binds.
///
/// An `aws-nitro` policy verifies the COSE_Sign1 document in the
/// attestation. [measurements] are the PCR sets the document must match,
/// and [imageIds] are the PCR0 values the session accepts after that
/// check. `report_data` must be the SHA-512 binding [proverReportData]
/// computes. Nitro hosts no GPU, so [gpu] cannot be `required` and a
/// quote that carries a GPU token is refused.
class TeePolicy {
  /// Creates a policy.
  TeePolicy({
    required this.platform,
    required List<Uint8List> imageIds,
    required List<NitroMeasurement> measurements,
    List<Uint8List>? anchors,
    this.nowSecs,
    this.gpu = 'optional',
    this.maxAge = const Duration(minutes: 10),
  }) : imageIds = List<Uint8List>.unmodifiable(
         imageIds.map(
           (bytes) => Uint8List.fromList(bytes).asUnmodifiableView(),
         ),
       ),
       measurements = List<NitroMeasurement>.unmodifiable(measurements),
       anchors = anchors == null
           ? null
           : List<Uint8List>.unmodifiable(
               anchors.map(
                 (bytes) => Uint8List.fromList(bytes).asUnmodifiableView(),
               ),
             ) {
    if (platform.isEmpty) {
      throw PrivacyRingsException(
        'TEE platform is empty',
        code: 'invalid_config',
      );
    }
    if (gpu != 'optional' && gpu != 'required') {
      throw PrivacyRingsException(
        'TEE gpu requirement is $gpu',
        code: 'invalid_config',
      );
    }
    if (this.imageIds.isEmpty) {
      throw PrivacyRingsException(
        'TEE policy has no image id',
        code: 'invalid_config',
      );
    }
    if (platform != 'aws-nitro') {
      throw PrivacyRingsException(
        'TEE platform $platform is not aws-nitro',
        code: 'invalid_config',
      );
    }
    if (gpu == 'required') {
      throw PrivacyRingsException(
        'aws-nitro hosts no GPU',
        code: 'invalid_config',
      );
    }
    if (this.measurements.isEmpty) {
      throw PrivacyRingsException(
        'TEE policy has no Nitro measurement',
        code: 'invalid_config',
      );
    }
    if (this.anchors != null && this.anchors!.isEmpty) {
      throw PrivacyRingsException(
        'TEE policy has no Nitro anchor',
        code: 'invalid_config',
      );
    }
  }

  /// Platform name, for example `aws-nitro`.
  final String platform;

  /// PCR0 values the session accepts.
  final List<Uint8List> imageIds;

  /// PCR sets the Nitro document must match.
  final List<NitroMeasurement> measurements;

  /// Certificate anchors. Null uses [awsNitroRoot].
  final List<Uint8List>? anchors;

  /// Unix time the certificate chain is checked at.
  ///
  /// Null uses the current time.
  final int? nowSecs;

  /// `optional`. Nitro refuses `required`.
  final String gpu;

  /// How long a cached attestation key may be reused.
  final Duration maxAge;
}

/// Key and image the attestation bound to this session's nonce.
class AttestedProver {
  /// Creates an attested prover.
  const AttestedProver({
    required this.platform,
    required this.hpkePublicKey,
    required this.imageId,
    required this.gpuVerified,
  });

  /// Platform the attestation named.
  final String platform;

  /// HPKE public key later requests are encrypted to.
  final Uint8List hpkePublicKey;

  /// Image digest that matched the policy.
  final Uint8List imageId;

  /// Whether the attestation carried a GPU token.
  final bool gpuVerified;
}

/// Attested session for a remote prover.
///
/// A call fetches `GET {attestationUrl}?nonce=`, checks the policy, and
/// encrypts the witness with [encryptProverRequest]. The request carries
/// `Spr-Tee: v1` and `Spr-Tee-Enc`. A POST puts the ciphertext in the
/// body. A GET puts it in `Spr-Tee-Ciphertext`, because fetch refuses a
/// GET body. A response marked `Spr-Tee: v1` is opened with the exported
/// response key. `tee_decryption_failed` drops the cached key and retries
/// the attestation once.
class TeeSession {
  /// Creates a session for [policy].
  ///
  /// [ephemeralSeed] fixes the X25519 seed inside the HPKE encapsulation.
  /// Callers leave it null so each request draws a fresh seed from
  /// `Random.secure`.
  TeeSession(this.policy, {this.ephemeralSeed});

  /// Policy this session attests against.
  final TeePolicy policy;

  /// X25519 seed for a reproducible encapsulation.
  ///
  /// Null draws a fresh seed from `Random.secure` for every request.
  final List<int>? ephemeralSeed;

  AttestedProver? _attested;
  DateTime? _attestedAt;

  /// Fetches and checks an attestation.
  Future<AttestedProver> attest(
    Uri attestationUrl,
    http.Client client, {
    Map<String, String> headers = const {},
  }) async {
    final nonce = _nonce();
    final url = attestationUrl.replace(
      queryParameters: {
        ...attestationUrl.queryParameters,
        'nonce': hexEncode(nonce),
      },
    );
    final response = await client.get(url, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PrivacyRingsException(
        'prover attestation HTTP ${response.statusCode}',
        code: 'tee_unavailable',
      );
    }
    final Object? body;
    try {
      body = jsonDecode(response.body);
    } on FormatException {
      throw PrivacyRingsException(
        'prover attestation was not JSON',
        code: 'malformed_attestation',
      );
    }
    final attested = _accept(body, nonce);
    _attested = attested;
    _attestedAt = DateTime.now();
    return attested;
  }

  /// Sends one request inside the session.
  ///
  /// [route] is the path below the prover URL, which the AAD binds.
  Future<http.Response> send({
    required http.Client client,
    required Uri attestationUrl,
    required Uri url,
    required String route,
    required String method,
    required Map<String, String> headers,
    Map<String, String> attestationHeaders = const {},
    String? body,
  }) async {
    var retried = false;
    while (true) {
      final key = await _key(client, attestationUrl, attestationHeaders);
      final encrypted = await encryptProverRequest(
        hpkePublicKey: key,
        method: method,
        requestUri: '$route${url.hasQuery ? '?${url.query}' : ''}',
        plaintext: utf8.encode(body ?? ''),
        ephemeralSeed: ephemeralSeed,
      );
      final request = http.Request(method, url)
        ..headers.addAll(headers)
        ..headers['Spr-Tee'] = 'v1'
        ..headers['Spr-Tee-Enc'] = hexEncode(encrypted.enc);
      if (method == 'GET') {
        request.headers['Spr-Tee-Ciphertext'] = hexEncode(encrypted.body);
      } else {
        request.bodyBytes = encrypted.body;
      }
      final response = await http.Response.fromStream(
        await client.send(request),
      );
      if (!retried && response.body.contains('tee_decryption_failed')) {
        retried = true;
        _attested = null;
        continue;
      }
      if (response.headers['spr-tee'] != 'v1') {
        if (response.statusCode < 200 || response.statusCode >= 300) {
          return response;
        }
        throw PrivacyRingsException(
          'prover success was not encrypted',
          code: 'tee_encryption',
        );
      }
      final clear = await decryptProverResponse(
        encrypted.responseKey,
        response.bodyBytes,
      );
      if (clear.status < 200 || clear.status > 599) {
        throw PrivacyRingsException(
          'encrypted prover status ${clear.status} is outside 200..599',
          code: 'tee_encryption',
        );
      }
      return http.Response.bytes(
        clear.body,
        clear.status,
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Uint8List> _key(
    http.Client client,
    Uri attestationUrl,
    Map<String, String> headers,
  ) async {
    final cached = _attested;
    final at = _attestedAt;
    if (cached != null &&
        at != null &&
        DateTime.now().difference(at) < policy.maxAge) {
      return cached.hpkePublicKey;
    }
    return (await attest(
      attestationUrl,
      client,
      headers: headers,
    )).hpkePublicKey;
  }

  AttestedProver _accept(Object? body, Uint8List nonce) {
    if (body is! Map) {
      throw PrivacyRingsException(
        'prover attestation is not an object',
        code: 'malformed_attestation',
      );
    }
    final attestation = body['attestation'] ?? body;
    if (attestation is! Map) {
      throw PrivacyRingsException(
        'prover attestation is not an object',
        code: 'malformed_attestation',
      );
    }
    if (attestation['platform'] != policy.platform) {
      throw PrivacyRingsException(
        'prover attestation platform does not match the policy',
        code: 'tee_platform',
      );
    }
    final key = _decodeHex(attestation['hpke_public_key'], 32, 'hpke key');
    if (!attestation.containsKey('gpu')) {
      throw PrivacyRingsException(
        'prover attestation has no gpu field',
        code: 'malformed_attestation',
      );
    }
    final gpu = attestation['gpu'];
    if (gpu != null && gpu is! String) {
      throw PrivacyRingsException(
        'prover gpu token is not a string',
        code: 'malformed_attestation',
      );
    }
    if (gpu != null) {
      throw PrivacyRingsException(
        'aws-nitro hosts no GPU, gpu must be null',
        code: 'malformed_attestation',
      );
    }
    final evidence = attestation['evidence'];
    if (evidence is! Map) {
      throw PrivacyRingsException(
        'prover attestation has no Nitro document',
        code: 'malformed_attestation',
      );
    }
    final document = _decodeHex(evidence['document'], null, 'document');
    final verdict = verifyNitroAttestation(
      document: document,
      measurements: policy.measurements,
      nonce: nonce,
      hpkePublicKey: key,
      nowSecs: policy.nowSecs ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      anchors: policy.anchors,
    );
    final expected = proverReportData(nonce, key);
    if (!_same(verdict.reportData)(expected)) {
      throw PrivacyRingsException(
        'prover report_data does not bind this nonce and key',
        code: 'tee_report',
      );
    }
    if (!policy.imageIds.any(_same(verdict.imageId))) {
      throw PrivacyRingsException(
        'prover image id is not in the policy',
        code: 'tee_image',
      );
    }
    return AttestedProver(
      platform: policy.platform,
      hpkePublicKey: key.asUnmodifiableView(),
      imageId: Uint8List.fromList(verdict.imageId).asUnmodifiableView(),
      gpuVerified: false,
    );
  }
}

Uint8List _nonce() {
  final random = Random.secure();
  return Uint8List.fromList(List<int>.generate(32, (_) => random.nextInt(256)));
}

Uint8List _decodeHex(Object? value, int? length, String name) {
  if (value is! String || value.length.isOdd || !_hexPattern.hasMatch(value)) {
    throw PrivacyRingsException(
      '$name is not hex',
      code: 'malformed_attestation',
    );
  }
  final bytes = Uint8List(value.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(value.substring(i * 2, i * 2 + 2), radix: 16);
  }
  if (length != null && bytes.length != length) {
    throw PrivacyRingsException(
      '$name is ${bytes.length} bytes',
      code: 'malformed_attestation',
    );
  }
  return bytes;
}

final _hexPattern = RegExp(r'^[0-9a-fA-F]*$');

bool Function(List<int>) _same(List<int> left) {
  return (List<int> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  };
}
