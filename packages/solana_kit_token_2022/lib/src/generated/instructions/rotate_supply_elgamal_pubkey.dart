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

/// The discriminator field name: 'confidentialMintBurnDiscriminator'.
/// Offset: 1.

@immutable
class RotateSupplyElgamalPubkeyInstructionData {
  const RotateSupplyElgamalPubkeyInstructionData({
    this.discriminator = 42,
    this.confidentialMintBurnDiscriminator = 1,
    required this.newSupplyElgamalPubkey,
    required this.proofInstructionOffset,
  });

  final int discriminator;
  final int confidentialMintBurnDiscriminator;
  final Address newSupplyElgamalPubkey;
  final int proofInstructionOffset;
}

Encoder<RotateSupplyElgamalPubkeyInstructionData>
getRotateSupplyElgamalPubkeyInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialMintBurnDiscriminator', getU8Encoder()),
    ('newSupplyElgamalPubkey', getAddressEncoder()),
    ('proofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RotateSupplyElgamalPubkeyInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialMintBurnDiscriminator':
          value.confidentialMintBurnDiscriminator,
      'newSupplyElgamalPubkey': value.newSupplyElgamalPubkey,
      'proofInstructionOffset': value.proofInstructionOffset,
    },
  );
}

Decoder<RotateSupplyElgamalPubkeyInstructionData>
getRotateSupplyElgamalPubkeyInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialMintBurnDiscriminator', getU8Decoder()),
    ('newSupplyElgamalPubkey', getAddressDecoder()),
    ('proofInstructionOffset', getI8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        RotateSupplyElgamalPubkeyInstructionData(
          discriminator: map['discriminator']! as int,
          confidentialMintBurnDiscriminator:
              map['confidentialMintBurnDiscriminator']! as int,
          newSupplyElgamalPubkey: map['newSupplyElgamalPubkey']! as Address,
          proofInstructionOffset: map['proofInstructionOffset']! as int,
        ),
  );
}

Codec<
  RotateSupplyElgamalPubkeyInstructionData,
  RotateSupplyElgamalPubkeyInstructionData
>
getRotateSupplyElgamalPubkeyInstructionDataCodec() {
  return combineCodec(
    getRotateSupplyElgamalPubkeyInstructionDataEncoder(),
    getRotateSupplyElgamalPubkeyInstructionDataDecoder(),
  );
}

/// Creates a [RotateSupplyElgamalPubkey] instruction.
Instruction getRotateSupplyElgamalPubkeyInstruction({
  required Address programAddress,
  required Address mint,
  required Address instructionsSysvarOrContextState,
  required Address authority,
  required Address newSupplyElgamalPubkey,
  required int proofInstructionOffset,
}) {
  final instructionData = RotateSupplyElgamalPubkeyInstructionData(
    newSupplyElgamalPubkey: newSupplyElgamalPubkey,
    proofInstructionOffset: proofInstructionOffset,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: instructionsSysvarOrContextState,
        role: AccountRole.readonly,
      ),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getRotateSupplyElgamalPubkeyInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [RotateSupplyElgamalPubkey] instruction from raw instruction data.
RotateSupplyElgamalPubkeyInstructionData
parseRotateSupplyElgamalPubkeyInstruction(Instruction instruction) {
  return getRotateSupplyElgamalPubkeyInstructionDataDecoder().decode(
    instruction.data!,
  );
}
