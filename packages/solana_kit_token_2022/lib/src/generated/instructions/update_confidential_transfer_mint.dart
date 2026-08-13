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

/// The discriminator field name: 'confidentialTransferDiscriminator'.
/// Offset: 1.

@immutable
class UpdateConfidentialTransferMintInstructionData {
  const UpdateConfidentialTransferMintInstructionData({
    this.discriminator = 27,
    this.confidentialTransferDiscriminator = 1,
    required this.autoApproveNewAccounts,
    required this.auditorElgamalPubkey,
  });

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final bool autoApproveNewAccounts;
  final Address? auditorElgamalPubkey;
}

Encoder<UpdateConfidentialTransferMintInstructionData> getUpdateConfidentialTransferMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('autoApproveNewAccounts', getBooleanEncoder()),
    ('auditorElgamalPubkey', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateConfidentialTransferMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferDiscriminator': value.confidentialTransferDiscriminator,
      'autoApproveNewAccounts': value.autoApproveNewAccounts,
      'auditorElgamalPubkey': value.auditorElgamalPubkey,
    },
  );
}

Decoder<UpdateConfidentialTransferMintInstructionData> getUpdateConfidentialTransferMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('autoApproveNewAccounts', getBooleanDecoder()),
    ('auditorElgamalPubkey', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateConfidentialTransferMintInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferDiscriminator: map['confidentialTransferDiscriminator']! as int,
      autoApproveNewAccounts: map['autoApproveNewAccounts']! as bool,
      auditorElgamalPubkey: map['auditorElgamalPubkey'] as Address?,
    ),
  );
}

Codec<UpdateConfidentialTransferMintInstructionData, UpdateConfidentialTransferMintInstructionData> getUpdateConfidentialTransferMintInstructionDataCodec() {
  return combineCodec(getUpdateConfidentialTransferMintInstructionDataEncoder(), getUpdateConfidentialTransferMintInstructionDataDecoder());
}

/// Creates a [UpdateConfidentialTransferMint] instruction.
Instruction getUpdateConfidentialTransferMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,
  required bool autoApproveNewAccounts,
  required Address? auditorElgamalPubkey,
}) {
  final instructionData = UpdateConfidentialTransferMintInstructionData(
      autoApproveNewAccounts: autoApproveNewAccounts,
      auditorElgamalPubkey: auditorElgamalPubkey,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateConfidentialTransferMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateConfidentialTransferMint] instruction from raw instruction data.
UpdateConfidentialTransferMintInstructionData parseUpdateConfidentialTransferMintInstruction(Instruction instruction) {
  return getUpdateConfidentialTransferMintInstructionDataDecoder().decode(instruction.data!);
}
