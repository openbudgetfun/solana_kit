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

/// The discriminator field name: 'confidentialTransferFeeDiscriminator'.
/// Offset: 1.

@immutable
class InitializeConfidentialTransferFeeInstructionData {
  const InitializeConfidentialTransferFeeInstructionData({
    required this.authority,
    required this.withdrawWithheldAuthorityElGamalPubkey,
  }) : discriminator = 37,
       confidentialTransferFeeDiscriminator = 0;

  final int discriminator;
  final int confidentialTransferFeeDiscriminator;
  final Address? authority;
  final Address withdrawWithheldAuthorityElGamalPubkey;
}

Encoder<InitializeConfidentialTransferFeeInstructionData>
getInitializeConfidentialTransferFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferFeeDiscriminator', getU8Encoder()),
    (
      'authority',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    ('withdrawWithheldAuthorityElGamalPubkey', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeConfidentialTransferFeeInstructionData value) =>
        <String, Object?>{
          'discriminator': 37,
          'confidentialTransferFeeDiscriminator': 0,
          'authority': value.authority,
          'withdrawWithheldAuthorityElGamalPubkey':
              value.withdrawWithheldAuthorityElGamalPubkey,
        },
  );
}

Decoder<InitializeConfidentialTransferFeeInstructionData>
getInitializeConfidentialTransferFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferFeeDiscriminator', getU8Decoder()),
    (
      'authority',
      getNullableDecoder<Address>(
        getAddressDecoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    ('withdrawWithheldAuthorityElGamalPubkey', getAddressDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'initializeConfidentialTransferFee instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeConfidentialTransferFeeInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(37),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeConfidentialTransferFeeInstructionData(
        authority: map['authority'] as Address?,
        withdrawWithheldAuthorityElGamalPubkey:
            map['withdrawWithheldAuthorityElGamalPubkey']! as Address,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeConfidentialTransferFeeInstructionData>(
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
      VariableSizeDecoder<InitializeConfidentialTransferFeeInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializeConfidentialTransferFeeInstructionData,
  InitializeConfidentialTransferFeeInstructionData
>
getInitializeConfidentialTransferFeeInstructionDataCodec() {
  return combineCodec(
    getInitializeConfidentialTransferFeeInstructionDataEncoder(),
    getInitializeConfidentialTransferFeeInstructionDataDecoder(),
  );
}

/// Creates a [InitializeConfidentialTransferFee] instruction.
Instruction getInitializeConfidentialTransferFeeInstruction({
  required Address programAddress,
  required Address mint,
  required Address? authority,
  required Address withdrawWithheldAuthorityElGamalPubkey,
}) {
  final instructionData = InitializeConfidentialTransferFeeInstructionData(
    authority: authority,
    withdrawWithheldAuthorityElGamalPubkey:
        withdrawWithheldAuthorityElGamalPubkey,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeConfidentialTransferFeeInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeConfidentialTransferFee] instruction from raw instruction data.
InitializeConfidentialTransferFeeInstructionData
parseInitializeConfidentialTransferFeeInstruction(Instruction instruction) {
  return getInitializeConfidentialTransferFeeInstructionDataDecoder().decode(
    instruction.data!,
  );
}
