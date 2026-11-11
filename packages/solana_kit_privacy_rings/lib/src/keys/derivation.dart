import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:solana_kit_privacy_rings/src/exception.dart';

/// `"TSPP/derive/v1"`, the payload an ed25519 derivation signature covers.
const ed25519DerivationPayload = 'TSPP/derive/v1';

/// Prefix that marks a message as a derivation seed request.
const derivationPayloadPrefix = 'TSPP/derive/';

/// An ed25519 derivation seed is a 64-byte RFC 8032 signature.
const ed25519SeedLength = 64;

const _infoNullifier = 'TSPP/nf_key/ed25519/v1';
const _infoViewing = 'TSPP/view_key/ed25519/x25519/v1';

/// Solana off-chain message magic.
final Uint8List offchainMessageMagic = Uint8List.fromList([
  0xff,
  0x73,
  0x6f,
  0x6c,
  0x61,
  0x6e,
  0x61,
  0x20,
  0x6f,
  0x66,
  0x66,
  0x63,
  0x68,
  0x61,
  0x69,
  0x6e,
]);

/// `sha256("TSPP/derive/v1")`, the off-chain application domain.
final Uint8List tsppApplicationDomain = Uint8List.fromList([
  0x1d,
  0x32,
  0xa8,
  0x85,
  0x33,
  0xaf,
  0x12,
  0xd3,
  0x5e,
  0x5a,
  0xc6,
  0xfc,
  0xe8,
  0x17,
  0xa4,
  0xcb,
  0x81,
  0x0b,
  0xcc,
  0x41,
  0x15,
  0x38,
  0x6b,
  0x14,
  0xa7,
  0x8e,
  0x8b,
  0x2e,
  0xf0,
  0x9d,
  0x86,
  0x4c,
]);

/// Solana off-chain message v0 whose payload is [ed25519DerivationPayload].
///
/// `ed25519_derivation_message`. [signerPublicKey] is 32 bytes.
Uint8List ed25519DerivationMessage(List<int> signerPublicKey) {
  if (signerPublicKey.length != 32) {
    throw PrivacyRingsException(
      'a derivation signer is ${signerPublicKey.length} bytes, it takes 32',
      code: 'invalid_length',
    );
  }
  final payload = utf8.encode(ed25519DerivationPayload);
  final message = Uint8List(85 + payload.length)
    ..setRange(0, 16, offchainMessageMagic)
    ..setRange(17, 49, tsppApplicationDomain)
    ..[50] = 1
    ..setRange(51, 83, signerPublicKey)
    ..[83] = payload.length & 0xff
    ..[84] = payload.length >> 8
    ..setRange(85, 85 + payload.length, payload);
  return message;
}

/// True when signing [message] would produce a derivation seed.
///
/// The payload, bare or inside an off-chain v0 envelope, must begin with
/// [derivationPayloadPrefix]. A truncated envelope is not a derivation input.
bool isDerivationInput(List<int> message) {
  final prefix = utf8.encode(derivationPayloadPrefix);
  if (_startsWith(message, prefix)) return true;
  final payload = _offchainPayload(message);
  return payload != null && _startsWith(payload, prefix);
}

/// Nullifier and viewing secrets expanded from a 64-byte derivation seed.
///
/// `role_expansion` on the ed25519 rail. One HKDF-Extract over [seed], then
/// one Expand per role. The viewing secret is clamped the way X25519 clamps
/// a scalar. The working buffers are wiped before this returns.
({Uint8List nullifierSecret, Uint8List viewingSecret}) expandShieldedSeed(
  List<int> seed,
) {
  if (seed.length != ed25519SeedLength) {
    throw PrivacyRingsException(
      'a derivation seed is ${seed.length} bytes, it takes $ed25519SeedLength',
      code: 'invalid_length',
    );
  }
  final prk = _hkdfExtract(Uint8List(32), seed);
  final nullifier = _hkdfExpand(prk, utf8.encode(_infoNullifier), 31);
  final okm = _hkdfExpand(prk, utf8.encode(_infoViewing), 32);
  prk.fillRange(0, prk.length, 0);
  final viewing = clampViewingSecret(okm);
  okm.fillRange(0, okm.length, 0);
  return (nullifierSecret: nullifier, viewingSecret: viewing);
}

/// X25519 clamp: clear the bottom three bits, clear the top bit, set bit 254.
Uint8List clampViewingSecret(List<int> secret) {
  if (secret.length != 32) {
    throw PrivacyRingsException(
      'a viewing secret is ${secret.length} bytes, it takes 32',
      code: 'invalid_length',
    );
  }
  final clamped = Uint8List.fromList(secret);
  clamped[0] &= 248;
  clamped[31] = (clamped[31] & 127) | 64;
  return clamped;
}

Uint8List _hkdfExtract(Uint8List salt, List<int> ikm) {
  return Uint8List.fromList(Hmac(sha256, salt).convert(ikm).bytes);
}

Uint8List _hkdfExpand(Uint8List prk, List<int> info, int length) {
  final out = BytesBuilder(copy: false);
  var previous = Uint8List(0);
  var counter = 1;
  while (out.length < length) {
    previous = Uint8List.fromList(
      Hmac(sha256, prk).convert([...previous, ...info, counter]).bytes,
    );
    out.add(previous);
    counter++;
  }
  final bytes = out.toBytes();
  return Uint8List.fromList(bytes.sublist(0, length));
}

bool _startsWith(List<int> message, List<int> prefix) {
  if (message.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (message[i] != prefix[i]) return false;
  }
  return true;
}

Uint8List? _offchainPayload(List<int> message) {
  if (!_startsWith(message, offchainMessageMagic)) return null;
  final rest = message.sublist(offchainMessageMagic.length);
  if (rest.isEmpty || rest[0] != 0 || rest.length < 1 + 32 + 2) return null;
  final afterDomain = rest.sublist(1 + 32);
  if (afterDomain.length < 2) return null;
  final signerCount = afterDomain[1];
  final afterSigners = afterDomain.sublist(2 + 32 * signerCount);
  if (afterSigners.length < 2) return null;
  final declared = afterSigners[0] | (afterSigners[1] << 8);
  final payload = afterSigners.sublist(2);
  if (payload.length != declared) return null;
  return Uint8List.fromList(payload);
}
