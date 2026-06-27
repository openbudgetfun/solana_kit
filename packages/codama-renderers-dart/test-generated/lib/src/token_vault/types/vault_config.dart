// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class VaultConfig {
  const VaultConfig({
    required this.maxCapacity,
    required this.minDeposit,
    required this.feeRate,
    required this.isActive,
  });

  final BigInt maxCapacity;
  final BigInt minDeposit;
  final int feeRate;
  final bool isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultConfig &&
          runtimeType == other.runtimeType &&
          maxCapacity == other.maxCapacity &&
          minDeposit == other.minDeposit &&
          feeRate == other.feeRate &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(maxCapacity, minDeposit, feeRate, isActive);

  @override
  String toString() =>
      'VaultConfig(maxCapacity: $maxCapacity, minDeposit: $minDeposit, feeRate: $feeRate, isActive: $isActive)';
}

Encoder<VaultConfig> getVaultConfigEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('maxCapacity', getU64Encoder()),
    ('minDeposit', getU64Encoder()),
    ('feeRate', getU16Encoder()),
    ('isActive', getBooleanEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (VaultConfig value) => <String, Object?>{
      'maxCapacity': value.maxCapacity,
      'minDeposit': value.minDeposit,
      'feeRate': value.feeRate,
      'isActive': value.isActive,
    },
  );
}

Decoder<VaultConfig> getVaultConfigDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('maxCapacity', getU64Decoder()),
    ('minDeposit', getU64Decoder()),
    ('feeRate', getU16Decoder()),
    ('isActive', getBooleanDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => VaultConfig(
      maxCapacity: map['maxCapacity']! as BigInt,
      minDeposit: map['minDeposit']! as BigInt,
      feeRate: map['feeRate']! as int,
      isActive: map['isActive']! as bool,
    ),
  );
}

Codec<VaultConfig, VaultConfig> getVaultConfigCodec() {
  return combineCodec(getVaultConfigEncoder(), getVaultConfigDecoder());
}
