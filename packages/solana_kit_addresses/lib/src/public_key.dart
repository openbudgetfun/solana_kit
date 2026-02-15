import 'dart:typed_data';

import 'package:solana_kit_addresses/src/address.dart';
import 'package:solana_kit_addresses/src/address_codec.dart';

/// Returns the [Address] corresponding to a 32-byte Ed25519 public key.
///
/// The [publicKeyBytes] must be exactly 32 bytes.
Address getAddressFromPublicKey(Uint8List publicKeyBytes) {
  return getAddressDecoder().decode(publicKeyBytes);
}

/// Returns the 32-byte Ed25519 public key for the given [addr].
Uint8List getPublicKeyFromAddress(Address addr) {
  return getAddressEncoder().encode(addr);
}
