// ignore_for_file: public_member_api_docs

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

const programDataAccountDiscriminator = 3;
const programDataAccountSize = 48;

@immutable
class ProgramDataAccount {
  const ProgramDataAccount({required this.slot, this.upgradeAuthorityAddress});

  final BigInt slot;
  final Address? upgradeAuthorityAddress;

  @override
  bool operator ==(Object other) =>
      other is ProgramDataAccount &&
      other.slot == slot &&
      other.upgradeAuthorityAddress == upgradeAuthorityAddress;

  @override
  int get hashCode => Object.hash(slot, upgradeAuthorityAddress);

  @override
  String toString() =>
      'ProgramDataAccount(slot: $slot, '
      'upgradeAuthorityAddress: $upgradeAuthorityAddress)';
}

Encoder<ProgramDataAccount> getProgramDataAccountEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('slot', getU64Encoder()),
    (
      'upgradeAuthorityAddress',
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
      'discriminator': programDataAccountDiscriminator,
      'slot': value.slot,
      'upgradeAuthorityAddress': value.upgradeAuthorityAddress,
    },
  );
}

Decoder<ProgramDataAccount> getProgramDataAccountDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('slot', getU64Decoder()),
    (
      'upgradeAuthorityAddress',
      getNullableDecoder<Address>(
        getAddressDecoder(),
        prefix: getU32Decoder(),
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (map, _, _) => ProgramDataAccount(
      slot: map['slot']! as BigInt,
      upgradeAuthorityAddress: map['upgradeAuthorityAddress'] as Address?,
    ),
  );
}

Codec<ProgramDataAccount, ProgramDataAccount> getProgramDataAccountCodec() =>
    combineCodec(
      getProgramDataAccountEncoder(),
      getProgramDataAccountDecoder(),
    );
