import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

/// An envelope wrapping an encoded offchain message with its signatures.
@immutable
class OffchainMessageEnvelope {
  /// Creates an [OffchainMessageEnvelope].
  const OffchainMessageEnvelope({
    required this.content,
    required this.signatures,
  });

  /// The bytes of the combined offchain message preamble and content.
  final Uint8List content;

  /// A map between the addresses of required signers and their 64-byte
  /// Ed25519 signatures.
  ///
  /// A `null` value indicates a missing signature.
  final Map<Address, SignatureBytes?> signatures;
}
