import 'package:solana_kit_addresses/src/address.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

/// Memoized encoder/decoder instances.
FixedSizeEncoder<Address>? _memoizedAddressEncoder;
FixedSizeDecoder<Address>? _memoizedAddressDecoder;

/// Returns a fixed-size encoder that encodes an [Address] into exactly 32
/// bytes.
///
/// The encoder validates the address before encoding.
FixedSizeEncoder<Address> getAddressEncoder() {
  if (_memoizedAddressEncoder != null) return _memoizedAddressEncoder!;
  final base58Encoder = fixEncoderSize(getBase58Encoder(), 32);
  _memoizedAddressEncoder =
      transformEncoder<String, Address>(base58Encoder, (addr) {
            assertIsAddress(addr.value);
            return addr.value;
          })
          as FixedSizeEncoder<Address>;
  return _memoizedAddressEncoder!;
}

/// Returns a fixed-size decoder that decodes exactly 32 bytes into an
/// [Address].
FixedSizeDecoder<Address> getAddressDecoder() {
  if (_memoizedAddressDecoder != null) return _memoizedAddressDecoder!;
  final base58Decoder = fixDecoderSize(getBase58Decoder(), 32);
  _memoizedAddressDecoder =
      transformDecoder<String, Address>(
            base58Decoder,
            (value, bytes, offset) => Address(value),
          )
          as FixedSizeDecoder<Address>;
  return _memoizedAddressDecoder!;
}

/// Returns a fixed-size codec that encodes and decodes [Address] values
/// as exactly 32 bytes.
FixedSizeCodec<Address, Address> getAddressCodec() {
  return combineCodec(getAddressEncoder(), getAddressDecoder())
      as FixedSizeCodec<Address, Address>;
}
