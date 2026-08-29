// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './authority.dart';
import './external_check_result.dart';
import './extra_account.dart';
import './hookable_lifecycle_event.dart';
import './validation_results_offset.dart';

@immutable
class OracleInitInfo {
  const OracleInitInfo({
    required this.baseAddress,
    required this.initPluginAuthority,
    required this.lifecycleChecks,
    required this.baseAddressConfig,
    required this.resultsOffset,
  });

  final Address baseAddress;
  final Authority? initPluginAuthority;
  final List<(HookableLifecycleEvent, ExternalCheckResult)> lifecycleChecks;
  final ExtraAccount? baseAddressConfig;
  final ValidationResultsOffset? resultsOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OracleInitInfo &&
          runtimeType == other.runtimeType &&
          baseAddress == other.baseAddress &&
          initPluginAuthority == other.initPluginAuthority &&
          _listEquals(lifecycleChecks, other.lifecycleChecks) &&
          baseAddressConfig == other.baseAddressConfig &&
          resultsOffset == other.resultsOffset;

  @override
  int get hashCode => Object.hash(
    baseAddress,
    initPluginAuthority,
    _listHashCode(lifecycleChecks),
    baseAddressConfig,
    resultsOffset,
  );

  @override
  String toString() =>
      'OracleInitInfo(baseAddress: $baseAddress, initPluginAuthority: $initPluginAuthority, lifecycleChecks: $lifecycleChecks, baseAddressConfig: $baseAddressConfig, resultsOffset: $resultsOffset)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a);
}

Encoder<OracleInitInfo> getOracleInitInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('baseAddress', getAddressEncoder()),
    (
      'initPluginAuthority',
      getNullableEncoder<Authority>(getAuthorityEncoder()),
    ),
    (
      'lifecycleChecks',
      getArrayEncoder<(HookableLifecycleEvent, ExternalCheckResult)>(
        transformEncoder(
          getTuple2Encoder(
            getHookableLifecycleEventEncoder(),
            getExternalCheckResultEncoder(),
          ),
          ((HookableLifecycleEvent, ExternalCheckResult) value) => value,
        ),
      ),
    ),
    (
      'baseAddressConfig',
      getNullableEncoder<ExtraAccount>(getExtraAccountEncoder()),
    ),
    (
      'resultsOffset',
      getNullableEncoder<ValidationResultsOffset>(
        getValidationResultsOffsetEncoder(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (OracleInitInfo value) => <String, Object?>{
      'baseAddress': value.baseAddress,
      'initPluginAuthority': value.initPluginAuthority,
      'lifecycleChecks': value.lifecycleChecks,
      'baseAddressConfig': value.baseAddressConfig,
      'resultsOffset': value.resultsOffset,
    },
  );
}

Decoder<OracleInitInfo> getOracleInitInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('baseAddress', getAddressDecoder()),
    (
      'initPluginAuthority',
      getNullableDecoder<Authority>(getAuthorityDecoder()),
    ),
    (
      'lifecycleChecks',
      getArrayDecoder(
        getTuple2Decoder(
          getHookableLifecycleEventDecoder(),
          getExternalCheckResultDecoder(),
        ),
      ),
    ),
    (
      'baseAddressConfig',
      getNullableDecoder<ExtraAccount>(getExtraAccountDecoder()),
    ),
    (
      'resultsOffset',
      getNullableDecoder<ValidationResultsOffset>(
        getValidationResultsOffsetDecoder(),
      ),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => OracleInitInfo(
      baseAddress: map['baseAddress']! as Address,
      initPluginAuthority: map['initPluginAuthority'] as Authority?,
      lifecycleChecks:
          map['lifecycleChecks']!
              as List<(HookableLifecycleEvent, ExternalCheckResult)>,
      baseAddressConfig: map['baseAddressConfig'] as ExtraAccount?,
      resultsOffset: map['resultsOffset'] as ValidationResultsOffset?,
    ),
  );
}

Codec<OracleInitInfo, OracleInitInfo> getOracleInitInfoCodec() {
  return combineCodec(getOracleInitInfoEncoder(), getOracleInitInfoDecoder());
}
