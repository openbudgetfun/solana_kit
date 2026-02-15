import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_offchain_messages/src/application_domain.dart';

/// Returns a fixed-size encoder for an offchain message application domain.
///
/// Encodes a base58-encoded application domain string to exactly 32 bytes.
FixedSizeEncoder<OffchainMessageApplicationDomain>
getOffchainMessageApplicationDomainEncoder() {
  return transformEncoder<Address, OffchainMessageApplicationDomain>(
        getAddressEncoder(),
        (putativeApplicationDomain) {
          offchainMessageApplicationDomain(putativeApplicationDomain.value);
          return putativeApplicationDomain;
        },
      )
      as FixedSizeEncoder<OffchainMessageApplicationDomain>;
}

/// Returns a fixed-size decoder for an offchain message application domain.
///
/// Decodes 32 bytes to a base58-encoded application domain string.
FixedSizeDecoder<OffchainMessageApplicationDomain>
getOffchainMessageApplicationDomainDecoder() {
  return getAddressDecoder();
}

/// Returns a codec for offchain message application domains.
FixedSizeCodec<
  OffchainMessageApplicationDomain,
  OffchainMessageApplicationDomain
>
getOffchainMessageApplicationDomainCodec() {
  return combineCodec(
        getOffchainMessageApplicationDomainEncoder(),
        getOffchainMessageApplicationDomainDecoder(),
      )
      as FixedSizeCodec<
        OffchainMessageApplicationDomain,
        OffchainMessageApplicationDomain
      >;
}
