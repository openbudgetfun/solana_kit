// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authority.dart';
import './linked_data_key.dart';

sealed class ExternalPluginAdapterKey {
  const ExternalPluginAdapterKey();
}

final class ExternalPluginAdapterKeyLifecycleHook
    extends ExternalPluginAdapterKey {
  const ExternalPluginAdapterKeyLifecycleHook(this.value);

  final Address value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterKeyLifecycleHook && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterKey.LifecycleHook($value)';
}

final class ExternalPluginAdapterKeyOracle extends ExternalPluginAdapterKey {
  const ExternalPluginAdapterKeyOracle(this.value);

  final Address value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterKeyOracle && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterKey.Oracle($value)';
}

final class ExternalPluginAdapterKeyAppData extends ExternalPluginAdapterKey {
  const ExternalPluginAdapterKeyAppData(this.value);

  final Authority value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterKeyAppData && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterKey.AppData($value)';
}

final class ExternalPluginAdapterKeyLinkedLifecycleHook
    extends ExternalPluginAdapterKey {
  const ExternalPluginAdapterKeyLinkedLifecycleHook(this.value);

  final Address value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterKeyLinkedLifecycleHook &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterKey.LinkedLifecycleHook($value)';
}

final class ExternalPluginAdapterKeyLinkedAppData
    extends ExternalPluginAdapterKey {
  const ExternalPluginAdapterKeyLinkedAppData(this.value);

  final Authority value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterKeyLinkedAppData && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterKey.LinkedAppData($value)';
}

final class ExternalPluginAdapterKeyDataSection
    extends ExternalPluginAdapterKey {
  const ExternalPluginAdapterKeyDataSection(this.value);

  final LinkedDataKey value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterKeyDataSection && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterKey.DataSection($value)';
}

final class ExternalPluginAdapterKeyAgentIdentity
    extends ExternalPluginAdapterKey {
  const ExternalPluginAdapterKeyAgentIdentity();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExternalPluginAdapterKeyAgentIdentity;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterKey.AgentIdentity()';
}

Encoder<ExternalPluginAdapterKey> getExternalPluginAdapterKeyEncoder() {
  return transformEncoder<Map<String, Object?>, ExternalPluginAdapterKey>(
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
        transformEncoder<Address, Map<String, Object?>>(
          getAddressEncoder(),
          (Map<String, Object?> map) => map['value']! as Address,
        ),
      ),
      (
        2,
        transformEncoder<Authority, Map<String, Object?>>(
          getAuthorityEncoder(),
          (Map<String, Object?> map) => map['value']! as Authority,
        ),
      ),
      (
        3,
        transformEncoder<Address, Map<String, Object?>>(
          getAddressEncoder(),
          (Map<String, Object?> map) => map['value']! as Address,
        ),
      ),
      (
        4,
        transformEncoder<Authority, Map<String, Object?>>(
          getAuthorityEncoder(),
          (Map<String, Object?> map) => map['value']! as Authority,
        ),
      ),
      (
        5,
        transformEncoder<LinkedDataKey, Map<String, Object?>>(
          getLinkedDataKeyEncoder(),
          (Map<String, Object?> map) => map['value']! as LinkedDataKey,
        ),
      ),
      (6, getStructEncoder(<(String, Encoder<Object?>)>[])),
    ], size: getU8Encoder()),
    (ExternalPluginAdapterKey value) => switch (value) {
      ExternalPluginAdapterKeyLifecycleHook(value: final value) =>
        <String, Object?>{'__kind': 0, 'value': value},
      ExternalPluginAdapterKeyOracle(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
      ExternalPluginAdapterKeyAppData(value: final value) => <String, Object?>{
        '__kind': 2,
        'value': value,
      },
      ExternalPluginAdapterKeyLinkedLifecycleHook(value: final value) =>
        <String, Object?>{'__kind': 3, 'value': value},
      ExternalPluginAdapterKeyLinkedAppData(value: final value) =>
        <String, Object?>{'__kind': 4, 'value': value},
      ExternalPluginAdapterKeyDataSection(value: final value) =>
        <String, Object?>{'__kind': 5, 'value': value},
      ExternalPluginAdapterKeyAgentIdentity() => <String, Object?>{'__kind': 6},
    },
  );
}

Decoder<ExternalPluginAdapterKey> getExternalPluginAdapterKeyDecoder() {
  return transformDecoder<Map<String, Object?>, ExternalPluginAdapterKey>(
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
        transformDecoder<Address, Map<String, Object?>>(
          getAddressDecoder(),
          (Address value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        2,
        transformDecoder<Authority, Map<String, Object?>>(
          getAuthorityDecoder(),
          (Authority value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        3,
        transformDecoder<Address, Map<String, Object?>>(
          getAddressDecoder(),
          (Address value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        4,
        transformDecoder<Authority, Map<String, Object?>>(
          getAuthorityDecoder(),
          (Authority value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        5,
        transformDecoder<LinkedDataKey, Map<String, Object?>>(
          getLinkedDataKeyDecoder(),
          (LinkedDataKey value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        6,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return ExternalPluginAdapterKeyLifecycleHook(
            map['value']! as Address,
          );
        case 1:
          return ExternalPluginAdapterKeyOracle(map['value']! as Address);
        case 2:
          return ExternalPluginAdapterKeyAppData(map['value']! as Authority);
        case 3:
          return ExternalPluginAdapterKeyLinkedLifecycleHook(
            map['value']! as Address,
          );
        case 4:
          return ExternalPluginAdapterKeyLinkedAppData(
            map['value']! as Authority,
          );
        case 5:
          return ExternalPluginAdapterKeyDataSection(
            map['value']! as LinkedDataKey,
          );
        case 6:
          return const ExternalPluginAdapterKeyAgentIdentity();
      }
      throw StateError(
        'Unsupported ExternalPluginAdapterKey discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<ExternalPluginAdapterKey, ExternalPluginAdapterKey>
getExternalPluginAdapterKeyCodec() {
  return combineCodec(
    getExternalPluginAdapterKeyEncoder(),
    getExternalPluginAdapterKeyDecoder(),
  );
}
