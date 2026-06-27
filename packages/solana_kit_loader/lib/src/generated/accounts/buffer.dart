import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

const bufferAccountDiscriminator = 1;
const bufferAccountSize = 40;

@immutable
class BufferAccount {
  const BufferAccount({this.authorityAddress});

  final Address? authorityAddress;

  @override
  bool operator ==(Object other) =>
      other is BufferAccount && other.authorityAddress == authorityAddress;

  @override
  int get hashCode => authorityAddress.hashCode;

  @override
  String toString() => 'BufferAccount(authorityAddress: $authorityAddress)';
}

Encoder<BufferAccount> getBufferAccountEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    (
      'authorityAddress',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        prefix: getU32Encoder(),
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (value) => <String, Object?>{
      'discriminator': bufferAccountDiscriminator,
      'authorityAddress': value.authorityAddress,
    },
  );
}

Decoder<BufferAccount> getBufferAccountDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    (
      'authorityAddress',
      getNullableDecoder<Address>(
        getAddressDecoder(),
        prefix: getU32Decoder(),
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (map, _, _) =>
        BufferAccount(authorityAddress: map['authorityAddress'] as Address?),
  );
}

Codec<BufferAccount, BufferAccount> getBufferAccountCodec() =>
    combineCodec(getBufferAccountEncoder(), getBufferAccountDecoder());
