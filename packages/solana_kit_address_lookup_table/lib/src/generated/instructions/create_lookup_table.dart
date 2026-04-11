// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_address_lookup_table/src/generated/programs/address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Discriminator value for the CreateLookupTable instruction.
const createLookupTableDiscriminator = 0;

/// Data for the CreateLookupTable instruction.
@immutable
class CreateLookupTableInstructionData {
  /// Creates [CreateLookupTableInstructionData].
  const CreateLookupTableInstructionData({
    required this.recentSlot,
    required this.bump,
    this.discriminator = createLookupTableDiscriminator,
  });

  /// The instruction discriminator (u32).
  final int discriminator;

  /// A recent slot used to derive the lookup table address.
  final BigInt recentSlot;

  /// The PDA bump seed for the lookup table address.
  final int bump;

  @override
  String toString() =>
      'CreateLookupTableInstructionData('
      'discriminator: $discriminator, '
      'recentSlot: $recentSlot, '
      'bump: $bump)';

  @override
  bool operator ==(Object other) =>
      other is CreateLookupTableInstructionData &&
      other.discriminator == discriminator &&
      other.recentSlot == recentSlot &&
      other.bump == bump;

  @override
  int get hashCode => Object.hash(discriminator, recentSlot, bump);
}

/// Returns the encoder for [CreateLookupTableInstructionData].
Encoder<CreateLookupTableInstructionData>
getCreateLookupTableInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('recentSlot', getU64Encoder()),
    ('bump', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateLookupTableInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'recentSlot': value.recentSlot,
      'bump': value.bump,
    },
  );
}

/// Returns the decoder for [CreateLookupTableInstructionData].
Decoder<CreateLookupTableInstructionData>
getCreateLookupTableInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('recentSlot', getU64Decoder()),
    ('bump', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CreateLookupTableInstructionData(
          discriminator: map['discriminator']! as int,
          recentSlot: map['recentSlot']! as BigInt,
          bump: map['bump']! as int,
        ),
  );
}

/// Returns the codec for [CreateLookupTableInstructionData].
Codec<CreateLookupTableInstructionData, CreateLookupTableInstructionData>
getCreateLookupTableInstructionDataCodec() {
  return combineCodec(
    getCreateLookupTableInstructionDataEncoder(),
    getCreateLookupTableInstructionDataDecoder(),
  );
}

/// Creates a CreateLookupTable instruction.
///
/// Creates a new address lookup table derived from [authority] and
/// [recentSlot]. The [address] parameter is the PDA of the new table and
/// [bump] is its bump seed.
Instruction getCreateLookupTableInstruction({
  required Address address,
  required Address authority,
  required Address payer,
  required BigInt recentSlot,
  required int bump,
  Address programAddress = addressLookupTableProgramAddress,
  Address systemProgramAddress = const Address(
    '11111111111111111111111111111111',
  ),
}) {
  final data = CreateLookupTableInstructionData(
    recentSlot: recentSlot,
    bump: bump,
  );
  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: address, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgramAddress, role: AccountRole.readonly),
    ],
    data: getCreateLookupTableInstructionDataEncoder().encode(data),
  );
}

/// Parses a CreateLookupTable instruction from [instruction].
CreateLookupTableInstructionData parseCreateLookupTableInstruction(
  Instruction instruction,
) {
  return getCreateLookupTableInstructionDataDecoder().decode(
    instruction.data!,
  );
}
