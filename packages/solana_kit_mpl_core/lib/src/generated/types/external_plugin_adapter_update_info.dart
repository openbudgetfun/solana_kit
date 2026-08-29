// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './agent_identity_update_info.dart';
import './app_data_update_info.dart';
import './lifecycle_hook_update_info.dart';
import './linked_app_data_update_info.dart';
import './linked_lifecycle_hook_update_info.dart';
import './oracle_update_info.dart';

sealed class ExternalPluginAdapterUpdateInfo {
  const ExternalPluginAdapterUpdateInfo();
}

final class ExternalPluginAdapterUpdateInfoLifecycleHook
    extends ExternalPluginAdapterUpdateInfo {
  const ExternalPluginAdapterUpdateInfoLifecycleHook(this.value);

  final LifecycleHookUpdateInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterUpdateInfoLifecycleHook &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterUpdateInfo.LifecycleHook($value)';
}

final class ExternalPluginAdapterUpdateInfoOracle
    extends ExternalPluginAdapterUpdateInfo {
  const ExternalPluginAdapterUpdateInfoOracle(this.value);

  final OracleUpdateInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterUpdateInfoOracle && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterUpdateInfo.Oracle($value)';
}

final class ExternalPluginAdapterUpdateInfoAppData
    extends ExternalPluginAdapterUpdateInfo {
  const ExternalPluginAdapterUpdateInfoAppData(this.value);

  final AppDataUpdateInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterUpdateInfoAppData && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterUpdateInfo.AppData($value)';
}

final class ExternalPluginAdapterUpdateInfoLinkedLifecycleHook
    extends ExternalPluginAdapterUpdateInfo {
  const ExternalPluginAdapterUpdateInfoLinkedLifecycleHook(this.value);

  final LinkedLifecycleHookUpdateInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterUpdateInfoLinkedLifecycleHook &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      'ExternalPluginAdapterUpdateInfo.LinkedLifecycleHook($value)';
}

final class ExternalPluginAdapterUpdateInfoLinkedAppData
    extends ExternalPluginAdapterUpdateInfo {
  const ExternalPluginAdapterUpdateInfoLinkedAppData(this.value);

  final LinkedAppDataUpdateInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterUpdateInfoLinkedAppData &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterUpdateInfo.LinkedAppData($value)';
}

final class ExternalPluginAdapterUpdateInfoAgentIdentity
    extends ExternalPluginAdapterUpdateInfo {
  const ExternalPluginAdapterUpdateInfoAgentIdentity(this.value);

  final AgentIdentityUpdateInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalPluginAdapterUpdateInfoAgentIdentity &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExternalPluginAdapterUpdateInfo.AgentIdentity($value)';
}

Encoder<ExternalPluginAdapterUpdateInfo>
getExternalPluginAdapterUpdateInfoEncoder() {
  return transformEncoder<
    Map<String, Object?>,
    ExternalPluginAdapterUpdateInfo
  >(
    getDiscriminatedUnionEncoder([
      (
        0,
        transformEncoder<LifecycleHookUpdateInfo, Map<String, Object?>>(
          getLifecycleHookUpdateInfoEncoder(),
          (Map<String, Object?> map) =>
              map['value']! as LifecycleHookUpdateInfo,
        ),
      ),
      (
        1,
        transformEncoder<OracleUpdateInfo, Map<String, Object?>>(
          getOracleUpdateInfoEncoder(),
          (Map<String, Object?> map) => map['value']! as OracleUpdateInfo,
        ),
      ),
      (
        2,
        transformEncoder<AppDataUpdateInfo, Map<String, Object?>>(
          getAppDataUpdateInfoEncoder(),
          (Map<String, Object?> map) => map['value']! as AppDataUpdateInfo,
        ),
      ),
      (
        3,
        transformEncoder<LinkedLifecycleHookUpdateInfo, Map<String, Object?>>(
          getLinkedLifecycleHookUpdateInfoEncoder(),
          (Map<String, Object?> map) =>
              map['value']! as LinkedLifecycleHookUpdateInfo,
        ),
      ),
      (
        4,
        transformEncoder<LinkedAppDataUpdateInfo, Map<String, Object?>>(
          getLinkedAppDataUpdateInfoEncoder(),
          (Map<String, Object?> map) =>
              map['value']! as LinkedAppDataUpdateInfo,
        ),
      ),
      (
        5,
        transformEncoder<AgentIdentityUpdateInfo, Map<String, Object?>>(
          getAgentIdentityUpdateInfoEncoder(),
          (Map<String, Object?> map) =>
              map['value']! as AgentIdentityUpdateInfo,
        ),
      ),
    ], size: getU8Encoder()),
    (ExternalPluginAdapterUpdateInfo value) => switch (value) {
      ExternalPluginAdapterUpdateInfoLifecycleHook(value: final value) =>
        <String, Object?>{'__kind': 0, 'value': value},
      ExternalPluginAdapterUpdateInfoOracle(value: final value) =>
        <String, Object?>{'__kind': 1, 'value': value},
      ExternalPluginAdapterUpdateInfoAppData(value: final value) =>
        <String, Object?>{'__kind': 2, 'value': value},
      ExternalPluginAdapterUpdateInfoLinkedLifecycleHook(value: final value) =>
        <String, Object?>{'__kind': 3, 'value': value},
      ExternalPluginAdapterUpdateInfoLinkedAppData(value: final value) =>
        <String, Object?>{'__kind': 4, 'value': value},
      ExternalPluginAdapterUpdateInfoAgentIdentity(value: final value) =>
        <String, Object?>{'__kind': 5, 'value': value},
    },
  );
}

Decoder<ExternalPluginAdapterUpdateInfo>
getExternalPluginAdapterUpdateInfoDecoder() {
  return transformDecoder<
    Map<String, Object?>,
    ExternalPluginAdapterUpdateInfo
  >(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<LifecycleHookUpdateInfo, Map<String, Object?>>(
          getLifecycleHookUpdateInfoDecoder(),
          (LifecycleHookUpdateInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        1,
        transformDecoder<OracleUpdateInfo, Map<String, Object?>>(
          getOracleUpdateInfoDecoder(),
          (OracleUpdateInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        2,
        transformDecoder<AppDataUpdateInfo, Map<String, Object?>>(
          getAppDataUpdateInfoDecoder(),
          (AppDataUpdateInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        3,
        transformDecoder<LinkedLifecycleHookUpdateInfo, Map<String, Object?>>(
          getLinkedLifecycleHookUpdateInfoDecoder(),
          (LinkedLifecycleHookUpdateInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        4,
        transformDecoder<LinkedAppDataUpdateInfo, Map<String, Object?>>(
          getLinkedAppDataUpdateInfoDecoder(),
          (LinkedAppDataUpdateInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
      (
        5,
        transformDecoder<AgentIdentityUpdateInfo, Map<String, Object?>>(
          getAgentIdentityUpdateInfoDecoder(),
          (AgentIdentityUpdateInfo value, Uint8List bytes, int offset) =>
              <String, Object?>{'value': value},
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return ExternalPluginAdapterUpdateInfoLifecycleHook(
            map['value']! as LifecycleHookUpdateInfo,
          );
        case 1:
          return ExternalPluginAdapterUpdateInfoOracle(
            map['value']! as OracleUpdateInfo,
          );
        case 2:
          return ExternalPluginAdapterUpdateInfoAppData(
            map['value']! as AppDataUpdateInfo,
          );
        case 3:
          return ExternalPluginAdapterUpdateInfoLinkedLifecycleHook(
            map['value']! as LinkedLifecycleHookUpdateInfo,
          );
        case 4:
          return ExternalPluginAdapterUpdateInfoLinkedAppData(
            map['value']! as LinkedAppDataUpdateInfo,
          );
        case 5:
          return ExternalPluginAdapterUpdateInfoAgentIdentity(
            map['value']! as AgentIdentityUpdateInfo,
          );
      }
      throw StateError(
        'Unsupported ExternalPluginAdapterUpdateInfo discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<ExternalPluginAdapterUpdateInfo, ExternalPluginAdapterUpdateInfo>
getExternalPluginAdapterUpdateInfoCodec() {
  return combineCodec(
    getExternalPluginAdapterUpdateInfoEncoder(),
    getExternalPluginAdapterUpdateInfoDecoder(),
  );
}
