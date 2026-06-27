import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_helius/src/types/auth_types.dart';

const _invalidKeypairMessage =
    'Invalid keypair format. Expected Uint8Array of 64 bytes (Solana CLI format).';

KeypairResult loadKeypair(Uint8List bytes) {
  if (bytes.length != 64) throw ArgumentError(_invalidKeypairMessage);
  final secretKey = Uint8List.fromList(bytes);
  final publicKey = Uint8List.sublistView(secretKey, 32);
  return KeypairResult(
    publicKey: base64Encode(publicKey),
    secretKey: base64Encode(secretKey),
  );
}

Future<String> getAddress(KeypairResult keypair) async {
  final publicKey = base64Decode(keypair.publicKey);
  return getBase58Decoder().decode(Uint8List.fromList(publicKey));
}
