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
class TransferAuthorityInstructionData {
  const TransferAuthorityInstructionData({
    this.discriminator = 2,
    required this.newAuthority,
  });

  final int discriminator;
  final Address newAuthority;
}

Encoder<TransferAuthorityInstructionData>
getTransferAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('newAuthority', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferAuthorityInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'newAuthority': value.newAuthority,
    },
  );
}

Decoder<TransferAuthorityInstructionData>
getTransferAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('newAuthority', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        TransferAuthorityInstructionData(
          discriminator: map['discriminator']! as int,
          newAuthority: map['newAuthority']! as Address,
        ),
  );
}

Codec<TransferAuthorityInstructionData, TransferAuthorityInstructionData>
getTransferAuthorityInstructionDataCodec() {
  return combineCodec(
    getTransferAuthorityInstructionDataEncoder(),
    getTransferAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [TransferAuthority] instruction.
Instruction getTransferAuthorityInstruction({
  required Address programAddress,
  required Address merkleTree,
  required Address authority,

  required Address newAuthority,
}) {
  final instructionData = TransferAuthorityInstructionData(
    newAuthority: newAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getTransferAuthorityInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [TransferAuthority] instruction from raw instruction data.
TransferAuthorityInstructionData parseTransferAuthorityInstruction(
  Instruction instruction,
) {
  return getTransferAuthorityInstructionDataDecoder().decode(instruction.data!);
}
