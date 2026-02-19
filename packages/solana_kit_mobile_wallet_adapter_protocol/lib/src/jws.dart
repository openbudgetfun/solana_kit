import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/crypto.dart';

/// Creates a JWS (JSON Web Signature) compact serialization using ES256
/// (ECDSA P-256 with SHA-256).
///
/// Format: `base64url(header).base64url(payload).base64url(signature)`
///
/// The header is always `{"alg":"ES256"}`.
String getJws(ECPrivateKey privateKey, Map<String, Object?> payload) {
  final headerEncoded = _base64UrlEncodeJson({'alg': 'ES256'});
  final payloadEncoded = _base64UrlEncodeJson(payload);
  final message = '$headerEncoded.$payloadEncoded';

  final signatureBytes = ecdsaSign(
    Uint8List.fromList(utf8.encode(message)),
    privateKey,
  );

  final signatureEncoded = base64Url.encode(signatureBytes).replaceAll('=', '');

  return '$message.$signatureEncoded';
}

String _base64UrlEncodeJson(Map<String, Object?> data) {
  return base64Url.encode(utf8.encode(json.encode(data))).replaceAll('=', '');
}
