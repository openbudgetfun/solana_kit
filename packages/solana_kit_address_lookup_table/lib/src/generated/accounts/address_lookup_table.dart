// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class AddressLookupTable {
  const AddressLookupTable({
    required this.discriminator,
    required this.deactivationSlot,
    required this.lastExtendedSlot,
    required this.lastExtendedSlotStartIndex,
    required this.authority,
    required this.padding,
    required this.addresses,
  });

  final int discriminator;
  final BigInt deactivationSlot;
  final BigInt lastExtendedSlot;
  final int lastExtendedSlotStartIndex;
  final Address? authority;
  final int padding;
  final List<Address> addresses;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressLookupTable &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          deactivationSlot == other.deactivationSlot &&
          lastExtendedSlot == other.lastExtendedSlot &&
          lastExtendedSlotStartIndex == other.lastExtendedSlotStartIndex &&
          authority == other.authority &&
          padding == other.padding &&
          addresses == other.addresses;

  @override
  int get hashCode => Object.hash(
    discriminator,
    deactivationSlot,
    lastExtendedSlot,
    lastExtendedSlotStartIndex,
    authority,
    padding,
    addresses,
  );

  @override
  String toString() =>
      'AddressLookupTable(discriminator: $discriminator, deactivationSlot: $deactivationSlot, lastExtendedSlot: $lastExtendedSlot, lastExtendedSlotStartIndex: $lastExtendedSlotStartIndex, authority: $authority, padding: $padding, addresses: $addresses)';
}

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<AddressLookupTable> getAddressLookupTableEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('deactivationSlot', getU64Encoder()),
    ('lastExtendedSlot', getU64Encoder()),
    ('lastExtendedSlotStartIndex', getU8Encoder()),
    (
      'authority',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    ('padding', getU16Encoder()),
    (
      'addresses',
      getArrayEncoder(getAddressEncoder(), size: RemainderArraySize()),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (AddressLookupTable value) => <String, Object?>{
      'discriminator': value.discriminator,
      'deactivationSlot': value.deactivationSlot,
      'lastExtendedSlot': value.lastExtendedSlot,
      'lastExtendedSlotStartIndex': value.lastExtendedSlotStartIndex,
      'authority': value.authority,
      'padding': value.padding,
      'addresses': value.addresses,
    },
  );
}

Decoder<AddressLookupTable> getAddressLookupTableDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('deactivationSlot', getU64Decoder()),
    ('lastExtendedSlot', getU64Decoder()),
    ('lastExtendedSlotStartIndex', getU8Decoder()),
    (
      'authority',
      getNullableDecoder<Address>(
        getAddressDecoder(),
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    ('padding', getU16Decoder()),
    (
      'addresses',
      getArrayDecoder(getAddressDecoder(), size: RemainderArraySize()),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AddressLookupTable(
          discriminator: map['discriminator']! as int,
          deactivationSlot: map['deactivationSlot']! as BigInt,
          lastExtendedSlot: map['lastExtendedSlot']! as BigInt,
          lastExtendedSlotStartIndex: map['lastExtendedSlotStartIndex']! as int,
          authority: map['authority'] as Address?,
          padding: map['padding']! as int,
          addresses: map['addresses']! as List<Address>,
        ),
  );
}

Codec<AddressLookupTable, AddressLookupTable> getAddressLookupTableCodec() {
  return combineCodec(
    getAddressLookupTableEncoder(),
    getAddressLookupTableDecoder(),
  );
}

Account<AddressLookupTable> decodeAddressLookupTable(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getAddressLookupTableDecoder());
}
