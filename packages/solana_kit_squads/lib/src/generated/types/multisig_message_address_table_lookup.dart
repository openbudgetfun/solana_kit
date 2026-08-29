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
          _listEquals(writableIndexes, other.writableIndexes) &&
          _listEquals(readonlyIndexes, other.readonlyIndexes);

  @override
  int get hashCode => Object.hash(
    accountKey,
    _listHashCode(writableIndexes),
    _listHashCode(readonlyIndexes),
  );

  @override
  String toString() =>
      'MultisigMessageAddressTableLookup(accountKey: $accountKey, writableIndexes: $writableIndexes, readonlyIndexes: $readonlyIndexes)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final left = a[i];
    final right = b[i];
    if (left is List<Object?> && right is List<Object?>) {
      if (!_listEquals(left, right)) return false;
    } else if (left != right) {
      return false;
    }
  }
  return true;
}

Object? _deepHash(Object? value) {
  if (value is List<Object?>) {
    return Object.hashAll(value.map(_deepHash));
  }
  return value;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a.map(_deepHash));
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
