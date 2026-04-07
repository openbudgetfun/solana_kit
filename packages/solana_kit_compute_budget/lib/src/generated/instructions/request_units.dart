// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_compute_budget/src/generated/programs/compute_budget.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Discriminator byte for the deprecated RequestUnits instruction.
const requestUnitsDiscriminator = 0;

/// Data for the deprecated RequestUnits instruction.
///
/// This instruction is deprecated. Use `SetComputeUnitLimit` and
/// `SetComputeUnitPrice` instead.
@immutable
class RequestUnitsInstructionData {
  /// Creates [RequestUnitsInstructionData].
  const RequestUnitsInstructionData({
    required this.units, required this.additionalFee, this.discriminator = requestUnitsDiscriminator,
  });

  /// The instruction discriminator byte.
  final int discriminator;

  /// Units to request for transaction-wide compute.
  final int units;

  /// Prioritization fee lamports.
  final int additionalFee;

  @override
  String toString() =>
      'RequestUnitsInstructionData('
      'discriminator: $discriminator, '
      'units: $units, '
      'additionalFee: $additionalFee)';

  @override
  bool operator ==(Object other) =>
      other is RequestUnitsInstructionData &&
      other.discriminator == discriminator &&
      other.units == units &&
      other.additionalFee == additionalFee;

  @override
  int get hashCode => Object.hash(discriminator, units, additionalFee);
}

/// Returns the encoder for [RequestUnitsInstructionData].
Encoder<RequestUnitsInstructionData>
getRequestUnitsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('units', getU32Encoder()),
    ('additionalFee', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RequestUnitsInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'units': value.units,
      'additionalFee': value.additionalFee,
    },
  );
}

/// Returns the decoder for [RequestUnitsInstructionData].
Decoder<RequestUnitsInstructionData>
getRequestUnitsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('units', getU32Decoder()),
    ('additionalFee', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        RequestUnitsInstructionData(
          discriminator: map['discriminator']! as int,
          units: map['units']! as int,
          additionalFee: map['additionalFee']! as int,
        ),
  );
}

/// Returns the codec for [RequestUnitsInstructionData].
Codec<RequestUnitsInstructionData, RequestUnitsInstructionData>
getRequestUnitsInstructionDataCodec() {
  return combineCodec(
    getRequestUnitsInstructionDataEncoder(),
    getRequestUnitsInstructionDataDecoder(),
  );
}

/// Creates a deprecated RequestUnits instruction.
///
/// Prefer `getSetComputeUnitLimitInstruction` and
/// `getSetComputeUnitPriceInstruction` for new code.
@Deprecated('Use setComputeUnitLimit + setComputeUnitPrice instead')
Instruction getRequestUnitsInstruction({
  required int units,
  required int additionalFee,
  Address programAddress = computeBudgetProgramAddress,
}) {
  final data = RequestUnitsInstructionData(
    units: units,
    additionalFee: additionalFee,
  );
  return Instruction(
    programAddress: programAddress,
    accounts: const [],
    data: getRequestUnitsInstructionDataEncoder().encode(data),
  );
}

/// Parses a RequestUnits instruction from [instruction].
RequestUnitsInstructionData parseRequestUnitsInstruction(
  Instruction instruction,
) {
  return getRequestUnitsInstructionDataDecoder().decode(instruction.data!);
}
