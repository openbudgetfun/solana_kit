// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_address_lookup_table/src/generated/programs/address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Discriminator value for the DeactivateLookupTable instruction.
const deactivateLookupTableDiscriminator = 3;

/// Data for the DeactivateLookupTable instruction.
@immutable
class DeactivateLookupTableInstructionData {
  /// Creates [DeactivateLookupTableInstructionData].
  const DeactivateLookupTableInstructionData({
    this.discriminator = deactivateLookupTableDiscriminator,
  });

  /// The instruction discriminator (u32).
  final int discriminator;

  @override
  String toString() =>
      'DeactivateLookupTableInstructionData(discriminator: $discriminator)';

  @override
  bool operator ==(Object other) =>
      other is DeactivateLookupTableInstructionData &&
      other.discriminator == discriminator;

  @override
  int get hashCode => discriminator.hashCode;
}

/// Returns the encoder for [DeactivateLookupTableInstructionData].
Encoder<DeactivateLookupTableInstructionData>
getDeactivateLookupTableInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DeactivateLookupTableInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

/// Returns the decoder for [DeactivateLookupTableInstructionData].
Decoder<DeactivateLookupTableInstructionData>
getDeactivateLookupTableInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        DeactivateLookupTableInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

/// Returns the codec for [DeactivateLookupTableInstructionData].
Codec<DeactivateLookupTableInstructionData,
    DeactivateLookupTableInstructionData>
getDeactivateLookupTableInstructionDataCodec() {
  return combineCodec(
    getDeactivateLookupTableInstructionDataEncoder(),
    getDeactivateLookupTableInstructionDataDecoder(),
  );
}

/// Creates a DeactivateLookupTable instruction.
///
/// Deactivates the lookup table at [address]. Only the [authority] can
/// deactivate. The table must be deactivated before it can be closed.
Instruction getDeactivateLookupTableInstruction({
  required Address address,
  required Address authority,
  Address programAddress = addressLookupTableProgramAddress,
}) {
  const data = DeactivateLookupTableInstructionData();
  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: address, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getDeactivateLookupTableInstructionDataEncoder().encode(data),
  );
}

/// Parses a DeactivateLookupTable instruction from [instruction].
DeactivateLookupTableInstructionData parseDeactivateLookupTableInstruction(
  Instruction instruction,
) {
  return getDeactivateLookupTableInstructionDataDecoder().decode(
    instruction.data!,
  );
}
