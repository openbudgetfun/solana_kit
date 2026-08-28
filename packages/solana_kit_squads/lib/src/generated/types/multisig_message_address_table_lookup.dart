// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class MultisigMessageAddressTableLookup {
  const MultisigMessageAddressTableLookup({
    required this.accountKey,
    required this.writableIndexes,
    required this.readonlyIndexes,
  });

  final Address accountKey;
  final Uint8List writableIndexes;
  final Uint8List readonlyIndexes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultisigMessageAddressTableLookup &&
          runtimeType == other.runtimeType &&
          accountKey == other.accountKey &&
          writableIndexes == other.writableIndexes &&
          readonlyIndexes == other.readonlyIndexes;

  @override
  int get hashCode => Object.hash(accountKey, writableIndexes, readonlyIndexes);

  @override
  String toString() =>
      'MultisigMessageAddressTableLookup(accountKey: $accountKey, writableIndexes: $writableIndexes, readonlyIndexes: $readonlyIndexes)';
}

Encoder<MultisigMessageAddressTableLookup>
getMultisigMessageAddressTableLookupEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('accountKey', getAddressEncoder()),
    (
      'writableIndexes',
      addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
    ),
    (
      'readonlyIndexes',
      addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (MultisigMessageAddressTableLookup value) => <String, Object?>{
      'accountKey': value.accountKey,
      'writableIndexes': value.writableIndexes,
      'readonlyIndexes': value.readonlyIndexes,
    },
  );
}

Decoder<MultisigMessageAddressTableLookup>
getMultisigMessageAddressTableLookupDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('accountKey', getAddressDecoder()),
    (
      'writableIndexes',
      addDecoderSizePrefix(getBytesDecoder(), getU32Decoder()),
    ),
    (
      'readonlyIndexes',
      addDecoderSizePrefix(getBytesDecoder(), getU32Decoder()),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        MultisigMessageAddressTableLookup(
          accountKey: map['accountKey']! as Address,
          writableIndexes: map['writableIndexes']! as Uint8List,
          readonlyIndexes: map['readonlyIndexes']! as Uint8List,
        ),
  );
}

Codec<MultisigMessageAddressTableLookup, MultisigMessageAddressTableLookup>
getMultisigMessageAddressTableLookupCodec() {
  return combineCodec(
    getMultisigMessageAddressTableLookupEncoder(),
    getMultisigMessageAddressTableLookupDecoder(),
  );
}
