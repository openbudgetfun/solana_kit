import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Data for the ATA create instruction.
@immutable
class CreateAssociatedTokenInstructionData {
  /// Creates [CreateAssociatedTokenInstructionData].
  const CreateAssociatedTokenInstructionData({this.discriminator = 0});

  /// The ATA instruction discriminator.
  final int discriminator;

  @override
  String toString() {
    return 'CreateAssociatedTokenInstructionData('
        'discriminator: $discriminator)';
  }

  @override
  bool operator ==(Object other) {
    return other is CreateAssociatedTokenInstructionData &&
        other.discriminator == discriminator;
  }

  @override
  int get hashCode => discriminator.hashCode;
}

/// Returns the encoder for [CreateAssociatedTokenInstructionData].
Encoder<CreateAssociatedTokenInstructionData>
getCreateAssociatedTokenInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateAssociatedTokenInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

/// Returns the decoder for [CreateAssociatedTokenInstructionData].
Decoder<CreateAssociatedTokenInstructionData>
getCreateAssociatedTokenInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CreateAssociatedTokenInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

/// Returns the codec for [CreateAssociatedTokenInstructionData].
Codec<
  CreateAssociatedTokenInstructionData,
  CreateAssociatedTokenInstructionData
>
getCreateAssociatedTokenInstructionDataCodec() {
  return combineCodec(
    getCreateAssociatedTokenInstructionDataEncoder(),
    getCreateAssociatedTokenInstructionDataDecoder(),
  );
}

/// Creates the ATA create instruction.
Instruction getCreateAssociatedTokenInstruction({
  required Address programAddress,
  required Address payer,
  required Address ata,
  required Address owner,
  required Address mint,
  required Address systemProgram,
  required Address tokenProgram,
}) {
  const instructionData = CreateAssociatedTokenInstructionData();
  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: ata, role: AccountRole.writable),
      AccountMeta(address: owner, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getCreateAssociatedTokenInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Backwards-compatible alias with the explicit “Account” noun included.
Instruction getCreateAssociatedTokenAccountInstruction({
  required Address programAddress,
  required Address payer,
  required Address ata,
  required Address owner,
  required Address mint,
  required Address systemProgram,
  required Address tokenProgram,
}) {
  return getCreateAssociatedTokenInstruction(
    programAddress: programAddress,
    payer: payer,
    ata: ata,
    owner: owner,
    mint: mint,
    systemProgram: systemProgram,
    tokenProgram: tokenProgram,
  );
}

/// Parses a create instruction from [instruction].
CreateAssociatedTokenInstructionData parseCreateAssociatedTokenInstruction(
  Instruction instruction,
) {
  return getCreateAssociatedTokenInstructionDataDecoder().decode(
    instruction.data!,
  );
}
