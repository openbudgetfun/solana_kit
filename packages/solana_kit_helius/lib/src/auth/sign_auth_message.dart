import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_helius/src/types/auth_types.dart';

/// Signs an authentication message with the given secret key.
///
/// In a full implementation, this would use Ed25519 signing with the secret
/// key from [SignAuthMessageRequest.secretKey]. For now, returns a
/// base64-encoded representation of the message bytes as a placeholder.
Future<SignAuthMessageResponse> authSignAuthMessage(
  SignAuthMessageRequest request,
) async {
  // In a full implementation, this would use Ed25519 signing.
  // For now, return a base64 encoding of the message bytes as a placeholder.
  final messageBytes = utf8.encode(request.message);
  return SignAuthMessageResponse(
    signature: base64Encode(Uint8List.fromList(messageBytes)),
  );
}
