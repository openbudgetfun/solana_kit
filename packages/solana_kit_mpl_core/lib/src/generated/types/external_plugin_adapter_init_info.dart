// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './agent_identity_init_info.dart';
import './app_data_init_info.dart';
import './data_section_init_info.dart';
import './lifecycle_hook_init_info.dart';
import './linked_app_data_init_info.dart';
import './linked_lifecycle_hook_init_info.dart';
import './oracle_init_info.dart';

sealed class ExternalPluginAdapterInitInfo {
  const ExternalPluginAdapterInitInfo();
}

final class ExternalPluginAdapterInitInfoLifecycleHook
    extends ExternalPluginAdapterInitInfo {
  const ExternalPluginAdapterInitInfoLifecycleHook(this.value);

  final LifecycleHookInitInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterInitInfoLifecycleHook &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterInitInfo.LifecycleHook($value)';
}

final class ExternalPluginAdapterInitInfoOracle
    extends ExternalPluginAdapterInitInfo {
  const ExternalPluginAdapterInitInfoOracle(this.value);

  final OracleInitInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterInitInfoOracle && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterInitInfo.Oracle($value)';
}

final class ExternalPluginAdapterInitInfoAppData
    extends ExternalPluginAdapterInitInfo {
  const ExternalPluginAdapterInitInfoAppData(this.value);

  final AppDataInitInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterInitInfoAppData && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterInitInfo.AppData($value)';
}

final class ExternalPluginAdapterInitInfoLinkedLifecycleHook
    extends ExternalPluginAdapterInitInfo {
  const ExternalPluginAdapterInitInfoLinkedLifecycleHook(this.value);

  final LinkedLifecycleHookInitInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterInitInfoLinkedLifecycleHook &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      'ExternalPluginAdapterInitInfo.LinkedLifecycleHook($value)';
}

final class ExternalPluginAdapterInitInfoLinkedAppData
    extends ExternalPluginAdapterInitInfo {
  const ExternalPluginAdapterInitInfoLinkedAppData(this.value);

  final LinkedAppDataInitInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterInitInfoLinkedAppData &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterInitInfo.LinkedAppData($value)';
}

final class ExternalPluginAdapterInitInfoDataSection
    extends ExternalPluginAdapterInitInfo {
  const ExternalPluginAdapterInitInfoDataSection(this.value);

  final DataSectionInitInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterInitInfoDataSection && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterInitInfo.DataSection($value)';
}

final class ExternalPluginAdapterInitInfoAgentIdentity
    extends ExternalPluginAdapterInitInfo {
  const ExternalPluginAdapterInitInfoAgentIdentity(this.value);

  final AgentIdentityInitInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterInitInfoAgentIdentity &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterInitInfo.AgentIdentity($value)';
}

Encoder<ExternalPluginAdapterInitInfo>
getExternalPluginAdapterInitInfoEncoder() {
  return transformEncoder<Map<String, Object?>, ExternalPluginAdapterInitInfo>(
    getDiscriminatedUnionEncoder([
      (
        0,
        transformEncoder<LifecycleHookInitInfo, Map<String, Object?>>(
          getLifecycleHookInitInfoEncoder(),
          (Map<String, Object?> map) => map['value']! as LifecycleHookInitInfo,
        ),
      ),
      (
        1,
        transformEncoder<OracleInitInfo, Map<String, Object?>>(
          getOracleInitInfoEncoder(),
          (Map<String, Object?> map) => map['value']! as OracleInitInfo,
        ),
      ),
      (
        2,
        transformEncoder<AppDataInitInfo, Map<String, Object?>>(
          getAppDataInitInfoEncoder(),
          (Map<String, Object?> map) => map['value']! as AppDataInitInfo,
        ),
      ),
      (
        3,
        transformEncoder<LinkedLifecycleHookInitInfo, Map<String, Object?>>(
          getLinkedLifecycleHookInitInfoEncoder(),
          (Map<String, Object?> map) =>
              map['value']! as LinkedLifecycleHookInitInfo,
        ),
      ),
      (
        4,
        transformEncoder<LinkedAppDataInitInfo, Map<String, Object?>>(
          getLinkedAppDataInitInfoEncoder(),
          (Map<String, Object?> map) => map['value']! as LinkedAppDataInitInfo,
        ),
      ),
      (
        5,
        transformEncoder<DataSectionInitInfo, Map<String, Object?>>(
          getDataSectionInitInfoEncoder(),
          (Map<String, Object?> map) => map['value']! as DataSectionInitInfo,
        ),
      ),
      (
        6,
        transformEncoder<AgentIdentityInitInfo, Map<String, Object?>>(
          getAgentIdentityInitInfoEncoder(),
          (Map<String, Object?> map) => map['value']! as AgentIdentityInitInfo,
        ),
      ),
    ], size: getU8Encoder()),
    (ExternalPluginAdapterInitInfo value) => switch (value) {
      ExternalPluginAdapterInitInfoLifecycleHook(value: final value) =>
        <String, Object?>{'__kind': 0, 'value': value},
      ExternalPluginAdapterInitInfoOracle(value: final value) =>
        <String, Object?>{'__kind': 1, 'value': value},
      ExternalPluginAdapterInitInfoAppData(value: final value) =>
        <String, Object?>{'__kind': 2, 'value': value},
      ExternalPluginAdapterInitInfoLinkedLifecycleHook(value: final value) =>
        <String, Object?>{'__kind': 3, 'value': value},
      ExternalPluginAdapterInitInfoLinkedAppData(value: final value) =>
        <String, Object?>{'__kind': 4, 'value': value},
      ExternalPluginAdapterInitInfoDataSection(value: final value) =>
        <String, Object?>{'__kind': 5, 'value': value},
      ExternalPluginAdapterInitInfoAgentIdentity(value: final value) =>
        <String, Object?>{'__kind': 6, 'value': value},
    },
  );
}

Decoder<ExternalPluginAdapterInitInfo>
getExternalPluginAdapterInitInfoDecoder() {
  return transformDecoder<Map<String, Object?>, ExternalPluginAdapterInitInfo>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<LifecycleHookInitInfo, Map<String, Object?>>(
          getLifecycleHookInitInfoDecoder(),
          (LifecycleHookInitInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        1,
        transformDecoder<OracleInitInfo, Map<String, Object?>>(
          getOracleInitInfoDecoder(),
          (OracleInitInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        2,
        transformDecoder<AppDataInitInfo, Map<String, Object?>>(
          getAppDataInitInfoDecoder(),
          (AppDataInitInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        3,
        transformDecoder<LinkedLifecycleHookInitInfo, Map<String, Object?>>(
          getLinkedLifecycleHookInitInfoDecoder(),
          (LinkedLifecycleHookInitInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        4,
        transformDecoder<LinkedAppDataInitInfo, Map<String, Object?>>(
          getLinkedAppDataInitInfoDecoder(),
          (LinkedAppDataInitInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        5,
        transformDecoder<DataSectionInitInfo, Map<String, Object?>>(
          getDataSectionInitInfoDecoder(),
          (DataSectionInitInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        6,
        transformDecoder<AgentIdentityInitInfo, Map<String, Object?>>(
          getAgentIdentityInitInfoDecoder(),
          (AgentIdentityInitInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return ExternalPluginAdapterInitInfoLifecycleHook(
            map['value']! as LifecycleHookInitInfo,
          );
        case 1:
          return ExternalPluginAdapterInitInfoOracle(
            map['value']! as OracleInitInfo,
          );
        case 2:
          return ExternalPluginAdapterInitInfoAppData(
            map['value']! as AppDataInitInfo,
          );
        case 3:
          return ExternalPluginAdapterInitInfoLinkedLifecycleHook(
            map['value']! as LinkedLifecycleHookInitInfo,
          );
        case 4:
          return ExternalPluginAdapterInitInfoLinkedAppData(
            map['value']! as LinkedAppDataInitInfo,
          );
        case 5:
          return ExternalPluginAdapterInitInfoDataSection(
            map['value']! as DataSectionInitInfo,
          );
        case 6:
          return ExternalPluginAdapterInitInfoAgentIdentity(
            map['value']! as AgentIdentityInitInfo,
          );
      }
      throw StateError(
        'Unsupported ExternalPluginAdapterInitInfo discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<ExternalPluginAdapterInitInfo, ExternalPluginAdapterInitInfo>
getExternalPluginAdapterInitInfoCodec() {
  return combineCodec(
    getExternalPluginAdapterInitInfoEncoder(),
    getExternalPluginAdapterInitInfoDecoder(),
  );
}
