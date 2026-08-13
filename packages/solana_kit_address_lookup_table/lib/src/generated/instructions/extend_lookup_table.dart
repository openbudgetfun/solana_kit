// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ExtendLookupTableInstructionData {
  const ExtendLookupTableInstructionData({
    this.discriminator = 2,
    required this.addresses,
  });

  final int discriminator;
  final List<Address> addresses;
}

Encoder<ExtendLookupTableInstructionData> getExtendLookupTableInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('addresses', getArrayEncoder(getAddressEncoder(), size: PrefixedArraySize(getU64Encoder()))),
  ]);

  return transformEncoder(
    structEncoder,
    (ExtendLookupTableInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'addresses': value.addresses,
    },
  );
}

Decoder<ExtendLookupTableInstructionData> getExtendLookupTableInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('addresses', getArrayDecoder(getAddressDecoder(), size: PrefixedArraySize(getU64Encoder()))),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ExtendLookupTableInstructionData(
      discriminator: map['discriminator']! as int,
      addresses: map['addresses']! as List<Address>,
    ),
  );
}

Codec<ExtendLookupTableInstructionData, ExtendLookupTableInstructionData> getExtendLookupTableInstructionDataCodec() {
  return combineCodec(getExtendLookupTableInstructionDataEncoder(), getExtendLookupTableInstructionDataDecoder());
}

/// Creates a [ExtendLookupTable] instruction.
Instruction getExtendLookupTableInstruction({
  required Address programAddress,
  required Address address,
  required Address authority,
  required Address payer,
  required Address systemProgram,
  required List<Address> addresses,
}) {
  final instructionData = ExtendLookupTableInstructionData(
      addresses: addresses,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: address, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    AccountMeta(address: payer, role: AccountRole.writableSigner),
    AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getExtendLookupTableInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ExtendLookupTable] instruction from raw instruction data.
ExtendLookupTableInstructionData parseExtendLookupTableInstruction(Instruction instruction) {
  return getExtendLookupTableInstructionDataDecoder().decode(instruction.data!);
}
