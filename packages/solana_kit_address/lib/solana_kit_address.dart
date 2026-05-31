/// Core Address extension type, codecs, comparator, and PublicKey utilities
/// for the Solana Kit Dart SDK.
///
/// Provides the [Address] extension type for validated base58-encoded Solana
/// addresses, codecs for serializing and deserializing addresses,
/// a comparator for sorting addresses by base58 collation rules,
/// and helpers for converting between public key bytes and addresses.
///
/// ```dart
/// import 'package:solana_kit_address/solana_kit_address.dart';
///
/// // Create a validated address
/// final addr = address('11111111111111111111111111111111');
///
/// // Encode/decode addresses
/// final codec = getAddressCodec();
/// final bytes = codec.encode(addr);
/// final decoded = codec.decode(bytes);
///
/// // Compare addresses using base58 collation order
/// final comparator = getAddressComparator();
/// ```
library;

export 'src/address.dart';
export 'src/address_codec.dart';
export 'src/address_comparator.dart';
export 'src/public_key.dart';