import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Data for the ATA idempotent create instruction.
@immutable
class CreateAssociatedTokenIdempotentInstructionData {
  /// Creates [CreateAssociatedTokenIdempotentInstructionData].
  const CreateAssociatedTokenIdempotentInstructionData({
    this.discriminator = 1,
  });

  /// The ATA instruction discriminator.
  final int discriminator;

  @override
  String toString() {
    return 'CreateAssociatedTokenIdempotentInstructionData('
        'discriminator: $discriminator)';
  }

  @override
  bool operator ==(Object other) {
    return other is CreateAssociatedTokenIdempotentInstructionData &&
        other.discriminator == discriminator;
  }

  @override
  int get hashCode => discriminator.hashCode;
}

/// Returns the encoder for [CreateAssociatedTokenIdempotentInstructionData].
Encoder<CreateAssociatedTokenIdempotentInstructionData>
getCreateAssociatedTokenIdempotentInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateAssociatedTokenIdempotentInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

/// Returns the decoder for [CreateAssociatedTokenIdempotentInstructionData].
Decoder<CreateAssociatedTokenIdempotentInstructionData>
getCreateAssociatedTokenIdempotentInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CreateAssociatedTokenIdempotentInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

/// Returns the codec for [CreateAssociatedTokenIdempotentInstructionData].
Codec<
  CreateAssociatedTokenIdempotentInstructionData,
  CreateAssociatedTokenIdempotentInstructionData
>
getCreateAssociatedTokenIdempotentInstructionDataCodec() {
  return combineCodec(
    getCreateAssociatedTokenIdempotentInstructionDataEncoder(),
    getCreateAssociatedTokenIdempotentInstructionDataDecoder(),
  );
}

/// Creates the ATA idempotent create instruction.
Instruction getCreateAssociatedTokenIdempotentInstruction({
  required Address programAddress,
  required Address payer,
  required Address ata,
  required Address owner,
  required Address mint,
  required Address systemProgram,
  required Address tokenProgram,
}) {
  const instructionData = CreateAssociatedTokenIdempotentInstructionData();
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
    data: getCreateAssociatedTokenIdempotentInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Backwards-compatible alias with the explicit “Account” noun included.
Instruction getCreateAssociatedTokenAccountIdempotentInstruction({
  required Address programAddress,
  required Address payer,
  required Address ata,
  required Address owner,
  required Address mint,
  required Address systemProgram,
  required Address tokenProgram,
}) {
  return getCreateAssociatedTokenIdempotentInstruction(
    programAddress: programAddress,
    payer: payer,
    ata: ata,
    owner: owner,
    mint: mint,
    systemProgram: systemProgram,
    tokenProgram: tokenProgram,
  );
}

/// Parses an idempotent create instruction from [instruction].
CreateAssociatedTokenIdempotentInstructionData
parseCreateAssociatedTokenIdempotentInstruction(Instruction instruction) {
  return getCreateAssociatedTokenIdempotentInstructionDataDecoder().decode(
    instruction.data!,
  );
}
