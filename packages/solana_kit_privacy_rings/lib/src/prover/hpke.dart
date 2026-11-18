import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' hide Hmac;

import 'package:solana_kit_privacy_rings/src/exception.dart';

const _kemSuite = [0x4b, 0x45, 0x4d, 0x00, 0x20];
const _hpkeSuite = [0x48, 0x50, 0x4b, 0x45, 0x00, 0x20, 0x00, 0x01, 0x00, 0x02];
const _info = 'zolana/prover-tee/v1';
const _responseExport = 'zolana/prover-tee/v1/response';

/// HPKE ciphertext and the key that opens the prover's answer.
class EncryptedProverRequest {
  /// Creates an encrypted request.
  EncryptedProverRequest({
    required this.enc,
    required this.body,
    required this.responseKey,
  });

  /// Encapsulated ephemeral public key, raw X25519.
  final Uint8List enc;

  /// AEAD ciphertext, including the tag.
  final Uint8List body;

  /// Exporter secret used as the response AES-256-GCM key.
  final Uint8List responseKey;
}

/// Status and body recovered from an encrypted prover response.
class DecryptedProverResponse {
  /// Creates a decrypted response.
  const DecryptedProverResponse({required this.status, required this.body});

  /// HTTP status the enclave put in the first two bytes.
  final int status;

  /// Response body after those two bytes.
  final Uint8List body;
}

/// AAD of one prover call.
///
/// `requestAad` in `sdk-libs/ts/src/client/prover/tee/encryption.ts`.
/// Trailing slashes are removed, a leading `/v1/spr` prefix is removed,
/// and every `api-key` query pair is dropped. The pair name is
/// percent-decoded before the comparison, matching `URLSearchParams`.
String proverRequestAad(String method, String requestUri) {
  final separator = requestUri.indexOf('?');
  final received = separator == -1
      ? requestUri
      : requestUri.substring(0, separator);
  var trimmed = received;
  while (trimmed.endsWith('/')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }
  const gateway = '/v1/spr';
  final path = trimmed.startsWith('$gateway/')
      ? trimmed.substring(gateway.length)
      : trimmed;
  final route = path.isEmpty ? '/' : path;
  final query = separator == -1 ? '' : requestUri.substring(separator + 1);
  final kept = <String>[];
  if (query.isNotEmpty) {
    for (final pair in query.split('&')) {
      if (pair.isEmpty) continue;
      final name = pair.split('=').first;
      var decoded = name;
      try {
        decoded = Uri.decodeQueryComponent(name);
      } on Object {
        decoded = name;
      }
      if (decoded == 'api-key') continue;
      kept.add(pair);
    }
  }
  return kept.isEmpty ? '$method $route' : '$method $route?${kept.join('&')}';
}

/// Lowercase hex, two characters per byte.
String hexEncode(List<int> bytes) {
  final buffer = StringBuffer();
  for (final byte in bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

/// SHA-256 nonce a GPU quote binds to the same session.
///
/// `SHA-256("zolana/prover-tee/v1/gpu" || nonce || hpke_public_key)`.
/// Both inputs are 32 bytes.
Uint8List proverGpuNonce(Uint8List nonce, Uint8List hpkePublicKey) {
  if (nonce.length != 32 || hpkePublicKey.length != 32) {
    throw PrivacyRingsException(
      'a GPU nonce takes 32-byte inputs',
      code: 'invalid_length',
    );
  }
  final prefix = utf8.encode('zolana/prover-tee/v1/gpu');
  return Uint8List.fromList(
    sha256.convert([...prefix, ...nonce, ...hpkePublicKey]).bytes,
  );
}

/// SHA-512 report binding the Go prover computes.
///
/// `reportData` in `sdk-libs/ts/src/client/prover/tee/verify.ts`.
Uint8List proverReportData(
  Uint8List nonce,
  Uint8List hpkePublicKey, {
  List<int>? gpuToken,
}) {
  final gpuDigest = gpuToken == null
      ? Uint8List(32)
      : Uint8List.fromList(sha256.convert(gpuToken).bytes);
  final prefix = utf8.encode('zolana/prover-tee/v1/report');
  return Uint8List.fromList(
    sha512.convert([...prefix, ...nonce, ...hpkePublicKey, ...gpuDigest]).bytes,
  );
}

/// Encrypts [plaintext] to [hpkePublicKey] with DHKEM(X25519, HKDF-SHA256)
/// and AES-256-GCM, info `zolana/prover-tee/v1`.
Future<EncryptedProverRequest> encryptProverRequest({
  required Uint8List hpkePublicKey,
  required String method,
  required String requestUri,
  required List<int> plaintext,
  List<int>? ephemeralSeed,
}) async {
  final seed = ephemeralSeed ?? _random32();
  final pair = await X25519().newKeyPairFromSeed(Uint8List.fromList(seed));
  final enc = Uint8List.fromList((await pair.extractPublicKey()).bytes);
  final shared = await _sharedSecret(pair, hpkePublicKey);
  final context = await _context(shared, enc, hpkePublicKey);
  final aad = utf8.encode(proverRequestAad(method, requestUri));
  final sealed = await AesGcm.with256bits().encrypt(
    plaintext,
    secretKey: SecretKey(context.key),
    nonce: context.nonce,
    aad: aad,
  );
  return EncryptedProverRequest(
    enc: enc,
    body: Uint8List.fromList([...sealed.cipherText, ...sealed.mac.bytes]),
    responseKey: context.exporter,
  );
}

/// Opens an HPKE ciphertext produced for the recipient [ikm].
///
/// Used to check the Go prover vector. [enc] is the sender's ephemeral
/// public key.
Future<Uint8List> openProverCiphertext({
  required Uint8List ikm,
  required Uint8List enc,
  required Uint8List ciphertext,
  required String method,
  required String requestUri,
}) async {
  final pair = await _keyPairFromIkm(ikm);
  final publicKey = Uint8List.fromList((await pair.extractPublicKey()).bytes);
  final shared = await _sharedSecret(pair, enc);
  final context = await _context(shared, enc, publicKey);
  final aad = utf8.encode(proverRequestAad(method, requestUri));
  if (ciphertext.length < 16) {
    throw PrivacyRingsException(
      'prover ciphertext is shorter than an AES-GCM tag',
      code: 'tee_encryption',
    );
  }
  final macStart = ciphertext.length - 16;
  try {
    final clear = await AesGcm.with256bits().decrypt(
      SecretBox(
        ciphertext.sublist(0, macStart),
        nonce: context.nonce,
        mac: Mac(ciphertext.sublist(macStart)),
      ),
      secretKey: SecretKey(context.key),
      aad: aad,
    );
    return Uint8List.fromList(clear);
  } on SecretBoxAuthenticationError {
    throw PrivacyRingsException(
      'prover ciphertext did not authenticate',
      code: 'tee_encryption',
    );
  }
}

/// X25519 public key the HPKE recipient derives from [ikm].
Future<Uint8List> proverRecipientPublicKey(Uint8List ikm) async {
  final pair = await _keyPairFromIkm(ikm);
  return Uint8List.fromList((await pair.extractPublicKey()).bytes);
}

/// Decrypts a TEE response with the exported response key.
///
/// The nonce is the first 12 bytes. The plaintext starts with a
/// big-endian HTTP status.
Future<DecryptedProverResponse> decryptProverResponse(
  Uint8List key,
  Uint8List encrypted,
) async {
  if (encrypted.length < 12 + 2 + 16) {
    throw PrivacyRingsException(
      'encrypted prover response is truncated',
      code: 'tee_encryption',
    );
  }
  final nonce = encrypted.sublist(0, 12);
  final body = encrypted.sublist(12, encrypted.length - 16);
  final mac = encrypted.sublist(encrypted.length - 16);
  List<int> clear;
  try {
    clear = await AesGcm.with256bits().decrypt(
      SecretBox(body, nonce: nonce, mac: Mac(mac)),
      secretKey: SecretKey(key),
    );
  } on SecretBoxAuthenticationError {
    throw PrivacyRingsException(
      'encrypted prover response did not authenticate',
      code: 'tee_encryption',
    );
  }
  return DecryptedProverResponse(
    status: (clear[0] << 8) | clear[1],
    body: Uint8List.fromList(clear.sublist(2)),
  );
}

class _Context {
  _Context(this.key, this.nonce, this.exporter);
  final Uint8List key;
  final List<int> nonce;
  final Uint8List exporter;
}

Future<SimpleKeyPair> _keyPairFromIkm(Uint8List ikm) async {
  final prk = _labeledExtract(_kemSuite, Uint8List(0), 'dkp_prk', ikm);
  final secret = _labeledExpand(prk, _kemSuite, 'sk', Uint8List(0), 32);
  return X25519().newKeyPairFromSeed(secret);
}

Future<Uint8List> _sharedSecret(KeyPair pair, Uint8List remote) async {
  final secret = await X25519().sharedSecretKey(
    keyPair: pair,
    remotePublicKey: SimplePublicKey(remote, type: KeyPairType.x25519),
  );
  final bytes = Uint8List.fromList(await secret.extractBytes());
  if (bytes.every((byte) => byte == 0)) {
    throw PrivacyRingsException(
      'HPKE peer has a non-contributory key',
      code: 'non_contributory_key',
    );
  }
  return bytes;
}

Future<_Context> _context(
  Uint8List dh,
  Uint8List enc,
  Uint8List recipient,
) async {
  final kemContext = Uint8List.fromList([...enc, ...recipient]);
  final eae = _labeledExtract(_kemSuite, Uint8List(0), 'eae_prk', dh);
  final shared = _labeledExpand(
    eae,
    _kemSuite,
    'shared_secret',
    kemContext,
    32,
  );
  final info = utf8.encode(_info);
  final pskHash = _labeledExtract(
    _hpkeSuite,
    Uint8List(0),
    'psk_id_hash',
    Uint8List(0),
  );
  final infoHash = _labeledExtract(_hpkeSuite, Uint8List(0), 'info_hash', info);
  final schedule = Uint8List.fromList([0, ...pskHash, ...infoHash]);
  final secret = _labeledExtract(_hpkeSuite, shared, 'secret', Uint8List(0));
  return _Context(
    _labeledExpand(secret, _hpkeSuite, 'key', schedule, 32),
    _labeledExpand(secret, _hpkeSuite, 'base_nonce', schedule, 12),
    _labeledExpand(
      _labeledExpand(secret, _hpkeSuite, 'exp', schedule, 32),
      _hpkeSuite,
      _responseExport,
      Uint8List(0),
      32,
    ),
  );
}

Uint8List _labeledExtract(
  List<int> suite,
  List<int> salt,
  String label,
  List<int> ikm,
) {
  final used = salt.isEmpty ? Uint8List(32) : salt;
  final labeled = <int>[
    ...utf8.encode('HPKE-v1'),
    ...suite,
    ...utf8.encode(label),
    ...ikm,
  ];
  return Uint8List.fromList(Hmac(sha256, used).convert(labeled).bytes);
}

Uint8List _labeledExpand(
  List<int> prk,
  List<int> suite,
  String label,
  List<int> info,
  int length,
) {
  final labeled = <int>[
    (length >> 8) & 0xff,
    length & 0xff,
    ...utf8.encode('HPKE-v1'),
    ...suite,
    ...utf8.encode(label),
    ...info,
  ];
  final out = <int>[];
  var previous = <int>[];
  var counter = 1;
  while (out.length < length) {
    previous = Hmac(
      sha256,
      prk,
    ).convert([...previous, ...labeled, counter]).bytes;
    out.addAll(previous);
    counter++;
  }
  return Uint8List.fromList(out.sublist(0, length));
}

Uint8List _random32() {
  final random = Random.secure();
  return Uint8List.fromList(List<int>.generate(32, (_) => random.nextInt(256)));
}
