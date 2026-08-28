// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './agent_identity.dart';
import './app_data.dart';
import './data_section.dart';
import './lifecycle_hook.dart';
import './linked_app_data.dart';
import './linked_lifecycle_hook.dart';
import './oracle.dart';

sealed class ExternalPluginAdapter {
  const ExternalPluginAdapter();
}

final class ExternalPluginAdapterLifecycleHook extends ExternalPluginAdapter {
  const ExternalPluginAdapterLifecycleHook(this.value);

  final LifecycleHook value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterLifecycleHook && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapter.LifecycleHook($value)';
}

final class ExternalPluginAdapterOracle extends ExternalPluginAdapter {
  const ExternalPluginAdapterOracle(this.value);

  final Oracle value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterOracle && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapter.Oracle($value)';
}

final class ExternalPluginAdapterAppData extends ExternalPluginAdapter {
  const ExternalPluginAdapterAppData(this.value);

  final AppData value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterAppData && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapter.AppData($value)';
}

final class ExternalPluginAdapterLinkedLifecycleHook
    extends ExternalPluginAdapter {
  const ExternalPluginAdapterLinkedLifecycleHook(this.value);

  final LinkedLifecycleHook value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterLinkedLifecycleHook && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapter.LinkedLifecycleHook($value)';
}

final class ExternalPluginAdapterLinkedAppData extends ExternalPluginAdapter {
  const ExternalPluginAdapterLinkedAppData(this.value);

  final LinkedAppData value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterLinkedAppData && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapter.LinkedAppData($value)';
}

final class ExternalPluginAdapterDataSection extends ExternalPluginAdapter {
  const ExternalPluginAdapterDataSection(this.value);

  final DataSection value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterDataSection && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapter.DataSection($value)';
}

final class ExternalPluginAdapterAgentIdentity extends ExternalPluginAdapter {
  const ExternalPluginAdapterAgentIdentity(this.value);

  final AgentIdentity value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterAgentIdentity && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapter.AgentIdentity($value)';
}

Encoder<ExternalPluginAdapter> getExternalPluginAdapterEncoder() {
  return transformEncoder<Map<String, Object?>, ExternalPluginAdapter>(
    getDiscriminatedUnionEncoder([
      (
        0,
        transformEncoder<LifecycleHook, Map<String, Object?>>(
          getLifecycleHookEncoder(),
          (Map<String, Object?> map) => map['value']! as LifecycleHook,
        ),
      ),
      (
        1,
        transformEncoder<Oracle, Map<String, Object?>>(
          getOracleEncoder(),
          (Map<String, Object?> map) => map['value']! as Oracle,
        ),
      ),
      (
        2,
        transformEncoder<AppData, Map<String, Object?>>(
          getAppDataEncoder(),
          (Map<String, Object?> map) => map['value']! as AppData,
        ),
      ),
      (
        3,
        transformEncoder<LinkedLifecycleHook, Map<String, Object?>>(
          getLinkedLifecycleHookEncoder(),
          (Map<String, Object?> map) => map['value']! as LinkedLifecycleHook,
        ),
      ),
      (
        4,
        transformEncoder<LinkedAppData, Map<String, Object?>>(
          getLinkedAppDataEncoder(),
          (Map<String, Object?> map) => map['value']! as LinkedAppData,
        ),
      ),
      (
        5,
        transformEncoder<DataSection, Map<String, Object?>>(
          getDataSectionEncoder(),
          (Map<String, Object?> map) => map['value']! as DataSection,
        ),
      ),
      (
        6,
        transformEncoder<AgentIdentity, Map<String, Object?>>(
          getAgentIdentityEncoder(),
          (Map<String, Object?> map) => map['value']! as AgentIdentity,
        ),
      ),
    ], size: getU8Encoder()),
    (ExternalPluginAdapter value) => switch (value) {
      ExternalPluginAdapterLifecycleHook(value: final value) =>
        <String, Object?>{'__kind': 0, 'value': value},
      ExternalPluginAdapterOracle(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
      ExternalPluginAdapterAppData(value: final value) => <String, Object?>{
        '__kind': 2,
        'value': value,
      },
      ExternalPluginAdapterLinkedLifecycleHook(value: final value) =>
        <String, Object?>{'__kind': 3, 'value': value},
      ExternalPluginAdapterLinkedAppData(value: final value) =>
        <String, Object?>{'__kind': 4, 'value': value},
      ExternalPluginAdapterDataSection(value: final value) => <String, Object?>{
        '__kind': 5,
        'value': value,
      },
      ExternalPluginAdapterAgentIdentity(value: final value) =>
        <String, Object?>{'__kind': 6, 'value': value},
    },
  );
}

Decoder<ExternalPluginAdapter> getExternalPluginAdapterDecoder() {
  return transformDecoder<Map<String, Object?>, ExternalPluginAdapter>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<LifecycleHook, Map<String, Object?>>(
          getLifecycleHookDecoder(),
          (LifecycleHook value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        1,
        transformDecoder<Oracle, Map<String, Object?>>(
          getOracleDecoder(),
          (Oracle value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        2,
        transformDecoder<AppData, Map<String, Object?>>(
          getAppDataDecoder(),
          (AppData value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        3,
        transformDecoder<LinkedLifecycleHook, Map<String, Object?>>(
          getLinkedLifecycleHookDecoder(),
          (LinkedLifecycleHook value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        4,
        transformDecoder<LinkedAppData, Map<String, Object?>>(
          getLinkedAppDataDecoder(),
          (LinkedAppData value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        5,
        transformDecoder<DataSection, Map<String, Object?>>(
          getDataSectionDecoder(),
          (DataSection value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        6,
        transformDecoder<AgentIdentity, Map<String, Object?>>(
          getAgentIdentityDecoder(),
          (AgentIdentity value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return ExternalPluginAdapterLifecycleHook(
            map['value']! as LifecycleHook,
          );
        case 1:
          return ExternalPluginAdapterOracle(map['value']! as Oracle);
        case 2:
          return ExternalPluginAdapterAppData(map['value']! as AppData);
        case 3:
          return ExternalPluginAdapterLinkedLifecycleHook(
            map['value']! as LinkedLifecycleHook,
          );
        case 4:
          return ExternalPluginAdapterLinkedAppData(
            map['value']! as LinkedAppData,
          );
        case 5:
          return ExternalPluginAdapterDataSection(map['value']! as DataSection);
        case 6:
          return ExternalPluginAdapterAgentIdentity(
            map['value']! as AgentIdentity,
          );
      }
      throw StateError(
        'Unsupported ExternalPluginAdapter discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<ExternalPluginAdapter, ExternalPluginAdapter>
getExternalPluginAdapterCodec() {
  return combineCodec(
    getExternalPluginAdapterEncoder(),
    getExternalPluginAdapterDecoder(),
  );
}
