// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_address_lookup_table/src/generated/programs/address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Discriminator value for the FreezeLookupTable instruction.
const freezeLookupTableDiscriminator = 1;

/// Data for the FreezeLookupTable instruction.
@immutable
class FreezeLookupTableInstructionData {
  /// Creates [FreezeLookupTableInstructionData].
  const FreezeLookupTableInstructionData({
    this.discriminator = freezeLookupTableDiscriminator,
  });

  /// The instruction discriminator (u32).
  final int discriminator;

  @override
  String toString() =>
      'FreezeLookupTableInstructionData(discriminator: $discriminator)';

  @override
  bool operator ==(Object other) =>
      other is FreezeLookupTableInstructionData &&
      other.discriminator == discriminator;

  @override
  int get hashCode => discriminator.hashCode;
}

/// Returns the encoder for [FreezeLookupTableInstructionData].
Encoder<FreezeLookupTableInstructionData>
getFreezeLookupTableInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (FreezeLookupTableInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

/// Returns the decoder for [FreezeLookupTableInstructionData].
Decoder<FreezeLookupTableInstructionData>
getFreezeLookupTableInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        FreezeLookupTableInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

/// Returns the codec for [FreezeLookupTableInstructionData].
Codec<FreezeLookupTableInstructionData, FreezeLookupTableInstructionData>
getFreezeLookupTableInstructionDataCodec() {
  return combineCodec(
    getFreezeLookupTableInstructionDataEncoder(),
    getFreezeLookupTableInstructionDataDecoder(),
  );
}

/// Creates a FreezeLookupTable instruction.
///
/// Freezes the lookup table at [address], preventing further modifications.
/// Only the [authority] can freeze the table.
Instruction getFreezeLookupTableInstruction({
  required Address address,
  required Address authority,
  Address programAddress = addressLookupTableProgramAddress,
}) {
  const data = FreezeLookupTableInstructionData();
  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: address, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getFreezeLookupTableInstructionDataEncoder().encode(data),
  );
}

/// Parses a FreezeLookupTable instruction from [instruction].
FreezeLookupTableInstructionData parseFreezeLookupTableInstruction(
  Instruction instruction,
) {
  return getFreezeLookupTableInstructionDataDecoder().decode(
    instruction.data!,
  );
}
