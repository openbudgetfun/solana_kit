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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'scaledUiAmountMintDiscriminator'.
/// Offset: 1.

@immutable
class UpdateMultiplierScaledUiMintInstructionData {
  const UpdateMultiplierScaledUiMintInstructionData({
    required this.multiplier,
    required this.effectiveTimestamp,
  }) : discriminator = 43,
       scaledUiAmountMintDiscriminator = 1;

  final int discriminator;
  final int scaledUiAmountMintDiscriminator;
  final double multiplier;
  final BigInt effectiveTimestamp;
}

Encoder<UpdateMultiplierScaledUiMintInstructionData>
getUpdateMultiplierScaledUiMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('scaledUiAmountMintDiscriminator', getU8Encoder()),
    ('multiplier', getF64Encoder()),
    ('effectiveTimestamp', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateMultiplierScaledUiMintInstructionData value) => <String, Object?>{
      'discriminator': 43,
      'scaledUiAmountMintDiscriminator': 1,
      'multiplier': value.multiplier,
      'effectiveTimestamp': value.effectiveTimestamp,
    },
  );
}

Decoder<UpdateMultiplierScaledUiMintInstructionData>
getUpdateMultiplierScaledUiMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('scaledUiAmountMintDiscriminator', getU8Decoder()),
    ('multiplier', getF64Decoder()),
    ('effectiveTimestamp', getI64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateMultiplierScaledUiMint instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateMultiplierScaledUiMintInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(43),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateMultiplierScaledUiMintInstructionData(
        multiplier: map['multiplier']! as double,
        effectiveTimestamp: map['effectiveTimestamp']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateMultiplierScaledUiMintInstructionData>(
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
      VariableSizeDecoder<UpdateMultiplierScaledUiMintInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateMultiplierScaledUiMintInstructionData,
  UpdateMultiplierScaledUiMintInstructionData
>
getUpdateMultiplierScaledUiMintInstructionDataCodec() {
  return combineCodec(
    getUpdateMultiplierScaledUiMintInstructionDataEncoder(),
    getUpdateMultiplierScaledUiMintInstructionDataDecoder(),
  );
}

/// Creates a [UpdateMultiplierScaledUiMint] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getUpdateMultiplierScaledUiMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,
  required double multiplier,
  required BigInt effectiveTimestamp,
  bool authorityIsSigner = true,
}) {
  final instructionData = UpdateMultiplierScaledUiMintInstructionData(
    multiplier: multiplier,
    effectiveTimestamp: effectiveTimestamp,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.writableSigner
            : AccountRole.writable,
      ),
    ],
    data: getUpdateMultiplierScaledUiMintInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateMultiplierScaledUiMint] instruction from raw instruction data.
UpdateMultiplierScaledUiMintInstructionData
parseUpdateMultiplierScaledUiMintInstruction(Instruction instruction) {
  return getUpdateMultiplierScaledUiMintInstructionDataDecoder().decode(
    instruction.data!,
  );
}
