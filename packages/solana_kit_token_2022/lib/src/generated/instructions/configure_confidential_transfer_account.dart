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

/// The discriminator field name: 'confidentialTransferDiscriminator'.
/// Offset: 1.

@immutable
class ConfigureConfidentialTransferAccountInstructionData {
  const ConfigureConfidentialTransferAccountInstructionData({
    required this.decryptableZeroBalance,
    required this.maximumPendingBalanceCreditCounter,
    required this.proofInstructionOffset,
  }) : discriminator = 27,
       confidentialTransferDiscriminator = 2;

  final int discriminator;
  final int confidentialTransferDiscriminator;
  final DecryptableBalance decryptableZeroBalance;
  final BigInt maximumPendingBalanceCreditCounter;
  final int proofInstructionOffset;
}

Encoder<ConfigureConfidentialTransferAccountInstructionData>
getConfigureConfidentialTransferAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferDiscriminator', getU8Encoder()),
    ('decryptableZeroBalance', getDecryptableBalanceEncoder()),
    ('maximumPendingBalanceCreditCounter', getU64Encoder()),
    ('proofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfigureConfidentialTransferAccountInstructionData value) =>
        <String, Object?>{
          'discriminator': 27,
          'confidentialTransferDiscriminator': 2,
          'decryptableZeroBalance': value.decryptableZeroBalance,
          'maximumPendingBalanceCreditCounter':
              value.maximumPendingBalanceCreditCounter,
          'proofInstructionOffset': value.proofInstructionOffset,
        },
  );
}

Decoder<ConfigureConfidentialTransferAccountInstructionData>
getConfigureConfidentialTransferAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferDiscriminator', getU8Decoder()),
    ('decryptableZeroBalance', getDecryptableBalanceDecoder()),
    ('maximumPendingBalanceCreditCounter', getU64Decoder()),
    ('proofInstructionOffset', getI8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'configureConfidentialTransferAccount instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ConfigureConfidentialTransferAccountInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(2),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ConfigureConfidentialTransferAccountInstructionData(
        decryptableZeroBalance:
            map['decryptableZeroBalance']! as DecryptableBalance,
        maximumPendingBalanceCreditCounter:
            map['maximumPendingBalanceCreditCounter']! as BigInt,
        proofInstructionOffset: map['proofInstructionOffset']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ConfigureConfidentialTransferAccountInstructionData>(
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
      VariableSizeDecoder<ConfigureConfidentialTransferAccountInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ConfigureConfidentialTransferAccountInstructionData,
  ConfigureConfidentialTransferAccountInstructionData
>
getConfigureConfidentialTransferAccountInstructionDataCodec() {
  return combineCodec(
    getConfigureConfidentialTransferAccountInstructionDataEncoder(),
    getConfigureConfidentialTransferAccountInstructionDataDecoder(),
  );
}

/// Creates a [ConfigureConfidentialTransferAccount] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getConfigureConfidentialTransferAccountInstruction({
  required Address programAddress,
  required Address token,
  required Address mint,
  required Address instructionsSysvarOrContextState,
  required Address authority,
  required DecryptableBalance decryptableZeroBalance,
  required BigInt maximumPendingBalanceCreditCounter,
  required int proofInstructionOffset,
  bool authorityIsSigner = true,
}) {
  final instructionData = ConfigureConfidentialTransferAccountInstructionData(
    decryptableZeroBalance: decryptableZeroBalance,
    maximumPendingBalanceCreditCounter: maximumPendingBalanceCreditCounter,
    proofInstructionOffset: proofInstructionOffset,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(
        address: instructionsSysvarOrContextState,
        role: AccountRole.readonly,
      ),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getConfigureConfidentialTransferAccountInstructionDataEncoder()
        .encode(instructionData),
  );
}

/// Parses a [ConfigureConfidentialTransferAccount] instruction from raw instruction data.
ConfigureConfidentialTransferAccountInstructionData
parseConfigureConfidentialTransferAccountInstruction(Instruction instruction) {
  return getConfigureConfidentialTransferAccountInstructionDataDecoder().decode(
    instruction.data!,
  );
}
