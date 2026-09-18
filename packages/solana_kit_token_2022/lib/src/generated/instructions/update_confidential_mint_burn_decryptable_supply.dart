// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/decryptable_balance.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'confidentialMintBurnDiscriminator'.
/// Offset: 1.

@immutable
class UpdateConfidentialMintBurnDecryptableSupplyInstructionData {
  const UpdateConfidentialMintBurnDecryptableSupplyInstructionData({
    required this.newDecryptableSupply,
  }) : discriminator = 42,
       confidentialMintBurnDiscriminator = 2;

  final int discriminator;
  final int confidentialMintBurnDiscriminator;
  final DecryptableBalance newDecryptableSupply;
}

Encoder<UpdateConfidentialMintBurnDecryptableSupplyInstructionData>
getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialMintBurnDiscriminator', getU8Encoder()),
    ('newDecryptableSupply', getDecryptableBalanceEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateConfidentialMintBurnDecryptableSupplyInstructionData value) =>
        <String, Object?>{
          'discriminator': 42,
          'confidentialMintBurnDiscriminator': 2,
          'newDecryptableSupply': value.newDecryptableSupply,
        },
  );
}

Decoder<UpdateConfidentialMintBurnDecryptableSupplyInstructionData>
getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialMintBurnDiscriminator', getU8Decoder()),
    ('newDecryptableSupply', getDecryptableBalanceDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'updateConfidentialMintBurnDecryptableSupply instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateConfidentialMintBurnDecryptableSupplyInstructionData, int)
  readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(42),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(2),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateConfidentialMintBurnDecryptableSupplyInstructionData(
        newDecryptableSupply:
            map['newDecryptableSupply']! as DecryptableBalance,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<
        UpdateConfidentialMintBurnDecryptableSupplyInstructionData
      >(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readTopLevel(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<
        UpdateConfidentialMintBurnDecryptableSupplyInstructionData
      >(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateConfidentialMintBurnDecryptableSupplyInstructionData,
  UpdateConfidentialMintBurnDecryptableSupplyInstructionData
>
getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataCodec() {
  return combineCodec(
    getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataEncoder(),
    getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataDecoder(),
  );
}

/// Creates a [UpdateConfidentialMintBurnDecryptableSupply] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getUpdateConfidentialMintBurnDecryptableSupplyInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,
  required DecryptableBalance newDecryptableSupply,
  bool authorityIsSigner = true,
}) {
  final instructionData =
      UpdateConfidentialMintBurnDecryptableSupplyInstructionData(
        newDecryptableSupply: newDecryptableSupply,
      );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataEncoder()
        .encode(instructionData),
  );
}

/// Parses a [UpdateConfidentialMintBurnDecryptableSupply] instruction from raw instruction data.
UpdateConfidentialMintBurnDecryptableSupplyInstructionData
parseUpdateConfidentialMintBurnDecryptableSupplyInstruction(
  Instruction instruction,
) {
  return getUpdateConfidentialMintBurnDecryptableSupplyInstructionDataDecoder()
      .decode(instruction.data!);
}
