// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authority.dart';

sealed class LinkedDataKey {
  const LinkedDataKey();
}

final class LinkedDataKeyLinkedLifecycleHook extends LinkedDataKey {
  const LinkedDataKeyLinkedLifecycleHook(this.value);

  final Address value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkedDataKeyLinkedLifecycleHook && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'LinkedDataKey.LinkedLifecycleHook($value)';
}

final class LinkedDataKeyLinkedAppData extends LinkedDataKey {
  const LinkedDataKeyLinkedAppData(this.value);

  final Authority value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkedDataKeyLinkedAppData && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'LinkedDataKey.LinkedAppData($value)';
}

Encoder<LinkedDataKey> getLinkedDataKeyEncoder() {
  return transformEncoder<Map<String, Object?>, LinkedDataKey>(
    getDiscriminatedUnionEncoder([
      (
        0,
        transformEncoder<Address, Map<String, Object?>>(
          getAddressEncoder(),
          (Map<String, Object?> map) => map['value']! as Address,
        ),
      ),
      (
        1,
        transformEncoder<Authority, Map<String, Object?>>(
          getAuthorityEncoder(),
          (Map<String, Object?> map) => map['value']! as Authority,
        ),
      ),
    ], size: getU8Encoder()),
    (LinkedDataKey value) => switch (value) {
      LinkedDataKeyLinkedLifecycleHook(value: final value) => <String, Object?>{
        '__kind': 0,
        'value': value,
      },
      LinkedDataKeyLinkedAppData(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
    },
  );
}

Decoder<LinkedDataKey> getLinkedDataKeyDecoder() {
  return transformDecoder<Map<String, Object?>, LinkedDataKey>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Address, Map<String, Object?>>(
          getAddressDecoder(),
          (Address value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        1,
        transformDecoder<Authority, Map<String, Object?>>(
          getAuthorityDecoder(),
          (Authority value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return LinkedDataKeyLinkedLifecycleHook(map['value']! as Address);
        case 1:
          return LinkedDataKeyLinkedAppData(map['value']! as Authority);
      }
      throw StateError(
        'Unsupported LinkedDataKey discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<LinkedDataKey, LinkedDataKey> getLinkedDataKeyCodec() {
  return combineCodec(getLinkedDataKeyEncoder(), getLinkedDataKeyDecoder());
}
