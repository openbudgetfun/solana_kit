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

/// The discriminator field name: 'interestBearingMintDiscriminator'.
/// Offset: 1.

@immutable
class UpdateRateInterestBearingMintInstructionData {
  const UpdateRateInterestBearingMintInstructionData({
    required this.rate,
  }) : discriminator = 33,
       interestBearingMintDiscriminator = 1;

  final int discriminator;
  final int interestBearingMintDiscriminator;
  final int rate;
}

Encoder<UpdateRateInterestBearingMintInstructionData>
getUpdateRateInterestBearingMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('interestBearingMintDiscriminator', getU8Encoder()),
    ('rate', getI16Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateRateInterestBearingMintInstructionData value) => <String, Object?>{
      'discriminator': 33,
      'interestBearingMintDiscriminator': 1,
      'rate': value.rate,
    },
  );
}

Decoder<UpdateRateInterestBearingMintInstructionData>
getUpdateRateInterestBearingMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('interestBearingMintDiscriminator', getU8Decoder()),
    ('rate', getI16Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateRateInterestBearingMint instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateRateInterestBearingMintInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(33),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateRateInterestBearingMintInstructionData(
        rate: map['rate']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateRateInterestBearingMintInstructionData>(
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
      VariableSizeDecoder<UpdateRateInterestBearingMintInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateRateInterestBearingMintInstructionData,
  UpdateRateInterestBearingMintInstructionData
>
getUpdateRateInterestBearingMintInstructionDataCodec() {
  return combineCodec(
    getUpdateRateInterestBearingMintInstructionDataEncoder(),
    getUpdateRateInterestBearingMintInstructionDataDecoder(),
  );
}

/// Creates a [UpdateRateInterestBearingMint] instruction.
/// Set [rateAuthorityIsSigner] to false when [rateAuthority] does not sign (for example, a multisig authority).
Instruction getUpdateRateInterestBearingMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address rateAuthority,
  required int rate,
  bool rateAuthorityIsSigner = true,
}) {
  final instructionData = UpdateRateInterestBearingMintInstructionData(
    rate: rate,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: rateAuthority,
        role: rateAuthorityIsSigner
            ? AccountRole.writableSigner
            : AccountRole.writable,
      ),
    ],
    data: getUpdateRateInterestBearingMintInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateRateInterestBearingMint] instruction from raw instruction data.
UpdateRateInterestBearingMintInstructionData
parseUpdateRateInterestBearingMintInstruction(Instruction instruction) {
  return getUpdateRateInterestBearingMintInstructionDataDecoder().decode(
    instruction.data!,
  );
}
