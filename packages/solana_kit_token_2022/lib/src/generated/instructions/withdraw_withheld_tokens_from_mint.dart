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

/// The discriminator field name: 'transferFeeDiscriminator'.
/// Offset: 1.

@immutable
class WithdrawWithheldTokensFromMintInstructionData {
  const WithdrawWithheldTokensFromMintInstructionData()
    : discriminator = 26,
      transferFeeDiscriminator = 2;

  final int discriminator;
  final int transferFeeDiscriminator;
}

Encoder<WithdrawWithheldTokensFromMintInstructionData>
getWithdrawWithheldTokensFromMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferFeeDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (WithdrawWithheldTokensFromMintInstructionData value) => <String, Object?>{
      'discriminator': 26,
      'transferFeeDiscriminator': 2,
    },
  );
}

Decoder<WithdrawWithheldTokensFromMintInstructionData>
getWithdrawWithheldTokensFromMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferFeeDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'withdrawWithheldTokensFromMint instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (WithdrawWithheldTokensFromMintInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(26),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(2),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      WithdrawWithheldTokensFromMintInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<WithdrawWithheldTokensFromMintInstructionData>(
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
      VariableSizeDecoder<WithdrawWithheldTokensFromMintInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  WithdrawWithheldTokensFromMintInstructionData,
  WithdrawWithheldTokensFromMintInstructionData
>
getWithdrawWithheldTokensFromMintInstructionDataCodec() {
  return combineCodec(
    getWithdrawWithheldTokensFromMintInstructionDataEncoder(),
    getWithdrawWithheldTokensFromMintInstructionDataDecoder(),
  );
}

/// Creates a [WithdrawWithheldTokensFromMint] instruction.
/// Set [withdrawWithheldAuthorityIsSigner] to false when [withdrawWithheldAuthority] does not sign (for example, a multisig authority).
Instruction getWithdrawWithheldTokensFromMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address feeReceiver,
  required Address withdrawWithheldAuthority,

  bool withdrawWithheldAuthorityIsSigner = true,
}) {
  final instructionData = WithdrawWithheldTokensFromMintInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: feeReceiver, role: AccountRole.writable),
      AccountMeta(
        address: withdrawWithheldAuthority,
        role: withdrawWithheldAuthorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getWithdrawWithheldTokensFromMintInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [WithdrawWithheldTokensFromMint] instruction from raw instruction data.
WithdrawWithheldTokensFromMintInstructionData
parseWithdrawWithheldTokensFromMintInstruction(Instruction instruction) {
  return getWithdrawWithheldTokensFromMintInstructionDataDecoder().decode(
    instruction.data!,
  );
}
