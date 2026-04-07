// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_compute_budget/src/generated/programs/compute_budget.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Discriminator byte for the SetComputeUnitLimit instruction.
const setComputeUnitLimitDiscriminator = 2;

/// Data for the SetComputeUnitLimit instruction.
@immutable
class SetComputeUnitLimitInstructionData {
  /// Creates [SetComputeUnitLimitInstructionData].
  const SetComputeUnitLimitInstructionData({
    required this.units, this.discriminator = setComputeUnitLimitDiscriminator,
  });

  /// The instruction discriminator byte.
  final int discriminator;

  /// Transaction-wide compute unit limit.
  final int units;

  @override
  String toString() =>
      'SetComputeUnitLimitInstructionData('
      'discriminator: $discriminator, '
      'units: $units)';

  @override
  bool operator ==(Object other) =>
      other is SetComputeUnitLimitInstructionData &&
      other.discriminator == discriminator &&
      other.units == units;

  @override
  int get hashCode => Object.hash(discriminator, units);
}

/// Returns the encoder for [SetComputeUnitLimitInstructionData].
Encoder<SetComputeUnitLimitInstructionData>
getSetComputeUnitLimitInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('units', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetComputeUnitLimitInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'units': value.units,
    },
  );
}

/// Returns the decoder for [SetComputeUnitLimitInstructionData].
Decoder<SetComputeUnitLimitInstructionData>
getSetComputeUnitLimitInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('units', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetComputeUnitLimitInstructionData(
          discriminator: map['discriminator']! as int,
          units: map['units']! as int,
        ),
  );
}

/// Returns the codec for [SetComputeUnitLimitInstructionData].
Codec<SetComputeUnitLimitInstructionData, SetComputeUnitLimitInstructionData>
getSetComputeUnitLimitInstructionDataCodec() {
  return combineCodec(
    getSetComputeUnitLimitInstructionDataEncoder(),
    getSetComputeUnitLimitInstructionDataDecoder(),
  );
}

/// Creates a SetComputeUnitLimit instruction.
///
/// Sets the transaction-wide compute unit limit to [units].
Instruction getSetComputeUnitLimitInstruction({
  required int units,
  Address programAddress = computeBudgetProgramAddress,
}) {
  final data = SetComputeUnitLimitInstructionData(units: units);
  return Instruction(
    programAddress: programAddress,
    accounts: const [],
    data: getSetComputeUnitLimitInstructionDataEncoder().encode(data),
  );
}

/// Parses a SetComputeUnitLimit instruction from [instruction].
SetComputeUnitLimitInstructionData parseSetComputeUnitLimitInstruction(
  Instruction instruction,
) {
  return getSetComputeUnitLimitInstructionDataDecoder().decode(
    instruction.data!,
  );
}
