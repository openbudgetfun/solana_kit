// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './extra_account.dart';
import './validation_results_offset.dart';

@immutable
class Oracle {
  const Oracle({
    required this.baseAddress,
    required this.baseAddressConfig,
    required this.resultsOffset,
  });

  final Address baseAddress;
  final ExtraAccount? baseAddressConfig;
  final ValidationResultsOffset resultsOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Oracle &&
          runtimeType == other.runtimeType &&
          baseAddress == other.baseAddress &&
          baseAddressConfig == other.baseAddressConfig &&
          resultsOffset == other.resultsOffset;

  @override
  int get hashCode =>
      Object.hash(baseAddress, baseAddressConfig, resultsOffset);

  @override
  String toString() =>
      'Oracle(baseAddress: $baseAddress, baseAddressConfig: $baseAddressConfig, resultsOffset: $resultsOffset)';
}

Encoder<Oracle> getOracleEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('baseAddress', getAddressEncoder()),
    (
      'baseAddressConfig',
      getNullableEncoder<ExtraAccount>(getExtraAccountEncoder()),
    ),
    ('resultsOffset', getValidationResultsOffsetEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Oracle value) => <String, Object?>{
      'baseAddress': value.baseAddress,
      'baseAddressConfig': value.baseAddressConfig,
      'resultsOffset': value.resultsOffset,
    },
  );
}

Decoder<Oracle> getOracleDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('baseAddress', getAddressDecoder()),
    (
      'baseAddressConfig',
      getNullableDecoder<ExtraAccount>(getExtraAccountDecoder()),
    ),
    ('resultsOffset', getValidationResultsOffsetDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Oracle(
      baseAddress: map['baseAddress']! as Address,
      baseAddressConfig: map['baseAddressConfig'] as ExtraAccount?,
      resultsOffset: map['resultsOffset']! as ValidationResultsOffset,
    ),
  );
}

Codec<Oracle, Oracle> getOracleCodec() {
  return combineCodec(getOracleEncoder(), getOracleDecoder());
}
