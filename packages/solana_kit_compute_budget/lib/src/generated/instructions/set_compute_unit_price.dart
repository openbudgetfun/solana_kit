// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_compute_budget/src/generated/programs/compute_budget.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Discriminator byte for the SetComputeUnitPrice instruction.
const setComputeUnitPriceDiscriminator = 3;

/// Data for the SetComputeUnitPrice instruction.
@immutable
class SetComputeUnitPriceInstructionData {
  /// Creates [SetComputeUnitPriceInstructionData].
  const SetComputeUnitPriceInstructionData({
    required this.microLamports, this.discriminator = setComputeUnitPriceDiscriminator,
  });

  /// The instruction discriminator byte.
  final int discriminator;

  /// Transaction compute unit price used for prioritization fees.
  final BigInt microLamports;

  @override
  String toString() =>
      'SetComputeUnitPriceInstructionData('
      'discriminator: $discriminator, '
      'microLamports: $microLamports)';

  @override
  bool operator ==(Object other) =>
      other is SetComputeUnitPriceInstructionData &&
      other.discriminator == discriminator &&
      other.microLamports == microLamports;

  @override
  int get hashCode => Object.hash(discriminator, microLamports);
}

/// Returns the encoder for [SetComputeUnitPriceInstructionData].
Encoder<SetComputeUnitPriceInstructionData>
getSetComputeUnitPriceInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('microLamports', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetComputeUnitPriceInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'microLamports': value.microLamports,
    },
  );
}

/// Returns the decoder for [SetComputeUnitPriceInstructionData].
Decoder<SetComputeUnitPriceInstructionData>
getSetComputeUnitPriceInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('microLamports', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetComputeUnitPriceInstructionData(
          discriminator: map['discriminator']! as int,
          microLamports: map['microLamports']! as BigInt,
        ),
  );
}

/// Returns the codec for [SetComputeUnitPriceInstructionData].
Codec<SetComputeUnitPriceInstructionData, SetComputeUnitPriceInstructionData>
getSetComputeUnitPriceInstructionDataCodec() {
  return combineCodec(
    getSetComputeUnitPriceInstructionDataEncoder(),
    getSetComputeUnitPriceInstructionDataDecoder(),
  );
}

/// Creates a SetComputeUnitPrice instruction.
///
/// Sets the compute unit price to [microLamports] for priority fee
/// calculation.
Instruction getSetComputeUnitPriceInstruction({
  required BigInt microLamports,
  Address programAddress = computeBudgetProgramAddress,
}) {
  final data = SetComputeUnitPriceInstructionData(
    microLamports: microLamports,
  );
  return Instruction(
    programAddress: programAddress,
    accounts: const [],
    data: getSetComputeUnitPriceInstructionDataEncoder().encode(data),
  );
}

/// Parses a SetComputeUnitPrice instruction from [instruction].
SetComputeUnitPriceInstructionData parseSetComputeUnitPriceInstruction(
  Instruction instruction,
) {
  return getSetComputeUnitPriceInstructionDataDecoder().decode(
    instruction.data!,
  );
}
