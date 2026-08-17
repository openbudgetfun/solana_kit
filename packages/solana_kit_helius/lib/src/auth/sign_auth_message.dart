import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

const _verificationText =
    'Please sign this message to verify ownership of your wallet and connect to Helius.';

/// Signs a Helius authentication message with the given Solana CLI-format key.
///
/// This mirrors upstream Helius behavior by generating the auth message when
/// [SignAuthMessageRequest.message] is omitted, signing the UTF-8 message bytes
/// with Ed25519, and returning a base58-encoded signature.
Future<SignAuthMessageResponse> signAuthMessage(
  SignAuthMessageRequest request,
) async {
  final secretKey = base64Decode(request.secretKey);
  KeyPair? keyPair;
  Uint8List? privateKey;
  try {
    keyPair = createKeyPairFromBytes(Uint8List.fromList(secretKey));
    final message = request.message ?? _createAuthMessage(request.timestamp);
    final messageBytes = Uint8List.fromList(utf8.encode(message));
    privateKey = keyPair.privateKey;
    final signatureBytes = signBytes(privateKey, messageBytes);

    return SignAuthMessageResponse(
      message: message,
      signature: _encodeBase58(signatureBytes.value),
    );
  } finally {
    secretKey.fillRange(0, secretKey.length, 0);
    privateKey?.fillRange(0, privateKey.length, 0);
    keyPair?.dispose();
  }
}

String _encodeBase58(Uint8List bytes) => getBase58Decoder().decode(bytes);

String _createAuthMessage(int? timestamp) {
  return jsonEncode({
    'message': _verificationText,
    'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
  });
}
