import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/encrypted_message.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/src/types.dart';

/// Parses encrypted session properties from the HELLO_RSP payload.
///
/// The encrypted payload, once decrypted, contains a JSON object with a `v`
/// field indicating the protocol version:
/// - `1`, `"1"`, or `"v1"` -> [ProtocolVersion.v1]
/// - `"legacy"` -> [ProtocolVersion.legacy]
///
/// If the `v` field is missing, defaults to [ProtocolVersion.legacy].
SessionProperties parseSessionProps(
  Uint8List encryptedMessage,
  Uint8List sharedSecret,
) {
  final decrypted = decryptMessage(encryptedMessage, sharedSecret);
  final jsonProperties =
      json.decode(decrypted.plaintext) as Map<String, Object?>;

  var protocolVersion = ProtocolVersion.legacy;

  if (jsonProperties.containsKey('v')) {
    final v = jsonProperties['v'];
    switch (v) {
      case 1:
      case '1':
      case 'v1':
        protocolVersion = ProtocolVersion.v1;
      case 'legacy':
        protocolVersion = ProtocolVersion.legacy;
      default:
        throw SolanaError(
          SolanaErrorCode.mwaInvalidProtocolVersion,
          {'version': '$v'},
        );
    }
  }

  return SessionProperties(protocolVersion: protocolVersion);
}
