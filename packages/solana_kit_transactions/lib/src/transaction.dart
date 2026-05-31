import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

/// A compiled transaction consisting of message bytes and a signatures map.
///
/// The [messageBytes] are the compiled transaction message in wire format.
/// The [signatures] map associates each signer's address with their 64-byte
/// Ed25519 signature, or `null` if the address has not yet signed.
class Transaction {
  /// Creates a [Transaction] with the given [messageBytes] and [signatures].
  Transaction({
    required this.messageBytes,
    required Map<Address, SignatureBytes?> signatures,
  }) : signatures = Map<Address, SignatureBytes?>.unmodifiable(signatures);

  /// The bytes of a compiled transaction message, encoded in wire format.
  final Uint8List messageBytes;

  /// A map between the addresses of a transaction message's signers, and the
  /// 64-byte Ed25519 signature of the transaction's [messageBytes] by the
  /// private key associated with each. A `null` value means the address has
  /// not yet signed.
  final Map<Address, SignatureBytes?> signatures;
}
