// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './external_check_result.dart';
import './extra_account.dart';
import './hookable_lifecycle_event.dart';
import './validation_results_offset.dart';

@immutable
class OracleUpdateInfo {
  const OracleUpdateInfo({
    required this.lifecycleChecks,
    required this.baseAddressConfig,
    required this.resultsOffset,
  });

  final List<(HookableLifecycleEvent, ExternalCheckResult)>? lifecycleChecks;
  final ExtraAccount? baseAddressConfig;
  final ValidationResultsOffset? resultsOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OracleUpdateInfo &&
          runtimeType == other.runtimeType &&
          _listEquals(lifecycleChecks, other.lifecycleChecks) &&
          baseAddressConfig == other.baseAddressConfig &&
          resultsOffset == other.resultsOffset;

  @override
  int get hashCode => Object.hash(
    _listHashCode(lifecycleChecks),
    baseAddressConfig,
    resultsOffset,
  );

  @override
  String toString() =>
      'OracleUpdateInfo(lifecycleChecks: $lifecycleChecks, baseAddressConfig: $baseAddressConfig, resultsOffset: $resultsOffset)';
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

Encoder<OracleUpdateInfo> getOracleUpdateInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'lifecycleChecks',
      getNullableEncoder<List<(HookableLifecycleEvent, ExternalCheckResult)>>(
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
    (OracleUpdateInfo value) => <String, Object?>{
      'lifecycleChecks': value.lifecycleChecks,
      'baseAddressConfig': value.baseAddressConfig,
      'resultsOffset': value.resultsOffset,
    },
  );
}

Decoder<OracleUpdateInfo> getOracleUpdateInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'lifecycleChecks',
      getNullableDecoder<List<(HookableLifecycleEvent, ExternalCheckResult)>>(
        getArrayDecoder(
          getTuple2Decoder(
            getHookableLifecycleEventDecoder(),
            getExternalCheckResultDecoder(),
          ),
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
    (Map<String, Object?> map, Uint8List bytes, int offset) => OracleUpdateInfo(
      lifecycleChecks:
          map['lifecycleChecks']
              as List<(HookableLifecycleEvent, ExternalCheckResult)>?,
      baseAddressConfig: map['baseAddressConfig'] as ExtraAccount?,
      resultsOffset: map['resultsOffset'] as ValidationResultsOffset?,
    ),
  );
}

Codec<OracleUpdateInfo, OracleUpdateInfo> getOracleUpdateInfoCodec() {
  return combineCodec(
    getOracleUpdateInfoEncoder(),
    getOracleUpdateInfoDecoder(),
  );
}
