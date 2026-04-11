// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_address_lookup_table/src/generated/programs/address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Discriminator value for the CloseLookupTable instruction.
const closeLookupTableDiscriminator = 4;

/// Data for the CloseLookupTable instruction.
@immutable
class CloseLookupTableInstructionData {
  /// Creates [CloseLookupTableInstructionData].
  const CloseLookupTableInstructionData({
    this.discriminator = closeLookupTableDiscriminator,
  });

  /// The instruction discriminator (u32).
  final int discriminator;

  @override
  String toString() =>
      'CloseLookupTableInstructionData(discriminator: $discriminator)';

  @override
  bool operator ==(Object other) =>
      other is CloseLookupTableInstructionData &&
      other.discriminator == discriminator;

  @override
  int get hashCode => discriminator.hashCode;
}

/// Returns the encoder for [CloseLookupTableInstructionData].
Encoder<CloseLookupTableInstructionData>
getCloseLookupTableInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseLookupTableInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

/// Returns the decoder for [CloseLookupTableInstructionData].
Decoder<CloseLookupTableInstructionData>
getCloseLookupTableInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CloseLookupTableInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

/// Returns the codec for [CloseLookupTableInstructionData].
Codec<CloseLookupTableInstructionData, CloseLookupTableInstructionData>
getCloseLookupTableInstructionDataCodec() {
  return combineCodec(
    getCloseLookupTableInstructionDataEncoder(),
    getCloseLookupTableInstructionDataDecoder(),
  );
}

/// Creates a CloseLookupTable instruction.
///
/// Closes the deactivated lookup table at [address] and transfers reclaimed
/// lamports to [recipient]. Only the [authority] can close the table.
Instruction getCloseLookupTableInstruction({
  required Address address,
  required Address authority,
  required Address recipient,
  Address programAddress = addressLookupTableProgramAddress,
}) {
  const data = CloseLookupTableInstructionData();
  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: address, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: recipient, role: AccountRole.writable),
    ],
    data: getCloseLookupTableInstructionDataEncoder().encode(data),
  );
}

/// Parses a CloseLookupTable instruction from [instruction].
CloseLookupTableInstructionData parseCloseLookupTableInstruction(
  Instruction instruction,
) {
  return getCloseLookupTableInstructionDataDecoder().decode(
    instruction.data!,
  );
}
