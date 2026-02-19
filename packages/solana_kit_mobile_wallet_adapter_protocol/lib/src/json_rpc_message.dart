import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/encrypted_message.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/src/protocol_error.dart';

/// Encrypts a JSON-RPC request for transmission over an MWA session.
///
/// The [id] is used as both the JSON-RPC message ID and the sequence number
/// for the encrypted message.
Uint8List encryptJsonRpcRequest(
  int id,
  String method,
  Map<String, Object?> params,
  Uint8List sharedSecret,
) {
  final jsonRpcMessage = {
    'id': id,
    'jsonrpc': '2.0',
    'method': method,
    'params': params,
  };
  final plaintext = json.encode(jsonRpcMessage);
  return encryptMessage(plaintext, id, sharedSecret);
}

/// Decrypts a JSON-RPC response from the wallet.
///
/// Throws [MwaProtocolError] if the response contains a JSON-RPC error.
/// Returns the `result` field of the response.
Map<String, Object?> decryptJsonRpcResponse(
  Uint8List message,
  Uint8List sharedSecret,
) {
  final decrypted = decryptMessage(message, sharedSecret);
  final jsonRpcMessage =
      json.decode(decrypted.plaintext) as Map<String, Object?>;

  if (jsonRpcMessage.containsKey('error')) {
    final error = jsonRpcMessage['error']! as Map<String, Object?>;
    throw MwaProtocolError(
      jsonRpcMessageId: jsonRpcMessage['id']! as int,
      code: error['code']! as int,
      message: error['message']! as String,
      data: error['data'],
    );
  }

  return jsonRpcMessage['result']! as Map<String, Object?>;
}
