// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_address_lookup_table/src/generated/constants.dart';
import 'package:solana_kit_address_lookup_table/src/generated/pdas/address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

/// Account discriminator for the AddressLookupTable account.
const addressLookupTableAccountDiscriminator = 1;

/// Decoded data for an AddressLookupTable account.
@immutable
class AddressLookupTableAccountData {
  /// Creates [AddressLookupTableAccountData].
  const AddressLookupTableAccountData({
    required this.deactivationSlot,
    required this.lastExtendedSlot,
    required this.lastExtendedSlotStartIndex,
    required this.addresses,
    this.discriminator = addressLookupTableAccountDiscriminator,
    this.authority,
  });

  /// The account discriminator (u32).
  final int discriminator;

  /// The slot at which this table was deactivated, or `u64::MAX` if active.
  final BigInt deactivationSlot;

  /// The most recent slot in which the table was extended.
  final BigInt lastExtendedSlot;

  /// The start index of addresses added in the last extension.
  final int lastExtendedSlotStartIndex;

  /// The authority that can modify this table, or `null` if frozen.
  final Address? authority;

  /// The addresses stored in this lookup table.
  final List<Address> addresses;

  @override
  String toString() =>
      'AddressLookupTableAccountData('
      'discriminator: $discriminator, '
      'deactivationSlot: $deactivationSlot, '
      'lastExtendedSlot: $lastExtendedSlot, '
      'lastExtendedSlotStartIndex: $lastExtendedSlotStartIndex, '
      'authority: $authority, '
      'addresses: $addresses)';

  @override
  bool operator ==(Object other) {
    if (other is! AddressLookupTableAccountData) return false;
    if (other.discriminator != discriminator) return false;
    if (other.deactivationSlot != deactivationSlot) return false;
    if (other.lastExtendedSlot != lastExtendedSlot) return false;
    if (other.lastExtendedSlotStartIndex != lastExtendedSlotStartIndex) {
      return false;
    }
    if (other.authority != authority) return false;
    if (other.addresses.length != addresses.length) return false;
    for (var i = 0; i < addresses.length; i++) {
      if (other.addresses[i] != addresses[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    discriminator,
    deactivationSlot,
    lastExtendedSlot,
    lastExtendedSlotStartIndex,
    authority,
    Object.hashAll(addresses),
  );
}

/// Returns the encoder for [AddressLookupTableAccountData].
Encoder<AddressLookupTableAccountData>
getAddressLookupTableAccountDataEncoder() {
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
      getArrayEncoder(getAddressEncoder(), size: const RemainderArraySize()),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (AddressLookupTableAccountData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'deactivationSlot': value.deactivationSlot,
      'lastExtendedSlot': value.lastExtendedSlot,
      'lastExtendedSlotStartIndex': value.lastExtendedSlotStartIndex,
      'authority': value.authority,
      'padding': 0,
      'addresses': value.addresses,
    },
  );
}

/// Returns the decoder for [AddressLookupTableAccountData].
Decoder<AddressLookupTableAccountData>
getAddressLookupTableAccountDataDecoder() {
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
      getArrayDecoder(getAddressDecoder(), size: const RemainderArraySize()),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AddressLookupTableAccountData(
          discriminator: map['discriminator']! as int,
          deactivationSlot: map['deactivationSlot']! as BigInt,
          lastExtendedSlot: map['lastExtendedSlot']! as BigInt,
          lastExtendedSlotStartIndex: map['lastExtendedSlotStartIndex']! as int,
          authority: map['authority'] as Address?,
          addresses: (map['addresses']! as List).cast<Address>(),
        ),
  );
}

/// Returns the codec for [AddressLookupTableAccountData].
Codec<AddressLookupTableAccountData, AddressLookupTableAccountData>
getAddressLookupTableAccountDataCodec() {
  return combineCodec(
    getAddressLookupTableAccountDataEncoder(),
    getAddressLookupTableAccountDataDecoder(),
  );
}

/// Decodes an encoded Address Lookup Table account.
Account<AddressLookupTableAccountData> decodeAddressLookupTable(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(
    encodedAccount,
    getAddressLookupTableAccountDataDecoder(),
  );
}

/// Fetches and decodes an Address Lookup Table account.
Future<Account<AddressLookupTableAccountData>> fetchAddressLookupTable(
  Rpc rpc,
  Address address, {
  FetchAccountConfig? config,
}) async {
  final maybeAccount = await fetchMaybeAddressLookupTable(
    rpc,
    address,
    config: config,
  );
  assertAccountExists(maybeAccount);
  return (maybeAccount as ExistingAccount<AddressLookupTableAccountData>)
      .account;
}

/// Fetches and decodes an Address Lookup Table account if it exists.
Future<MaybeAccount<AddressLookupTableAccountData>>
fetchMaybeAddressLookupTable(
  Rpc rpc,
  Address address, {
  FetchAccountConfig? config,
}) async {
  final maybeEncodedAccount = await fetchEncodedAccount(
    rpc,
    address,
    config: config,
  );
  return decodeMaybeAccount(
    maybeEncodedAccount,
    getAddressLookupTableAccountDataDecoder(),
  );
}

/// Derives, fetches, and decodes an Address Lookup Table account.
Future<Account<AddressLookupTableAccountData>> fetchAddressLookupTableFromSeeds(
  Rpc rpc, {
  required Address authority,
  required BigInt recentSlot,
  Address programAddress = addressLookupTableProgramAddress,
  FetchAccountConfig? config,
}) async {
  final (address, _) = await findAddressLookupTablePda(
    authority: authority,
    recentSlot: recentSlot,
    programAddress: programAddress,
  );
  return fetchAddressLookupTable(rpc, address, config: config);
}

/// Derives, fetches, and decodes an Address Lookup Table account if it exists.
Future<MaybeAccount<AddressLookupTableAccountData>>
fetchMaybeAddressLookupTableFromSeeds(
  Rpc rpc, {
  required Address authority,
  required BigInt recentSlot,
  Address programAddress = addressLookupTableProgramAddress,
  FetchAccountConfig? config,
}) async {
  final (address, _) = await findAddressLookupTablePda(
    authority: authority,
    recentSlot: recentSlot,
    programAddress: programAddress,
  );
  return fetchMaybeAddressLookupTable(rpc, address, config: config);
}
