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
class InitializeTransferFeeConfigInstructionData {
  const InitializeTransferFeeConfigInstructionData({
    required this.transferFeeConfigAuthority,
    required this.withdrawWithheldAuthority,
    required this.transferFeeBasisPoints,
    required this.maximumFee,
  }) : discriminator = 26,
       transferFeeDiscriminator = 0;

  final int discriminator;
  final int transferFeeDiscriminator;
  final Address? transferFeeConfigAuthority;
  final Address? withdrawWithheldAuthority;
  final int transferFeeBasisPoints;
  final BigInt maximumFee;
}

Encoder<InitializeTransferFeeConfigInstructionData>
getInitializeTransferFeeConfigInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferFeeDiscriminator', getU8Encoder()),
    (
      'transferFeeConfigAuthority',
      getNullableEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
    (
      'withdrawWithheldAuthority',
      getNullableEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
    ('transferFeeBasisPoints', getU16Encoder()),
    ('maximumFee', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeTransferFeeConfigInstructionData value) => <String, Object?>{
      'discriminator': 26,
      'transferFeeDiscriminator': 0,
      'transferFeeConfigAuthority': value.transferFeeConfigAuthority,
      'withdrawWithheldAuthority': value.withdrawWithheldAuthority,
      'transferFeeBasisPoints': value.transferFeeBasisPoints,
      'maximumFee': value.maximumFee,
    },
  );
}

Decoder<InitializeTransferFeeConfigInstructionData>
getInitializeTransferFeeConfigInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferFeeDiscriminator', getU8Decoder()),
    (
      'transferFeeConfigAuthority',
      getNullableDecoder<Address>(getAddressDecoder()),
    ),
    (
      'withdrawWithheldAuthority',
      getNullableDecoder<Address>(getAddressDecoder()),
    ),
    ('transferFeeBasisPoints', getU16Decoder()),
    ('maximumFee', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeTransferFeeConfig instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeTransferFeeConfigInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(26),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeTransferFeeConfigInstructionData(
        transferFeeConfigAuthority:
            map['transferFeeConfigAuthority'] as Address?,
        withdrawWithheldAuthority: map['withdrawWithheldAuthority'] as Address?,
        transferFeeBasisPoints: map['transferFeeBasisPoints']! as int,
        maximumFee: map['maximumFee']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeTransferFeeConfigInstructionData>(
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
      VariableSizeDecoder<InitializeTransferFeeConfigInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializeTransferFeeConfigInstructionData,
  InitializeTransferFeeConfigInstructionData
>
getInitializeTransferFeeConfigInstructionDataCodec() {
  return combineCodec(
    getInitializeTransferFeeConfigInstructionDataEncoder(),
    getInitializeTransferFeeConfigInstructionDataDecoder(),
  );
}

/// Creates a [InitializeTransferFeeConfig] instruction.
Instruction getInitializeTransferFeeConfigInstruction({
  required Address programAddress,
  required Address mint,
  required Address? transferFeeConfigAuthority,
  required Address? withdrawWithheldAuthority,
  required int transferFeeBasisPoints,
  required BigInt maximumFee,
}) {
  final instructionData = InitializeTransferFeeConfigInstructionData(
    transferFeeConfigAuthority: transferFeeConfigAuthority,
    withdrawWithheldAuthority: withdrawWithheldAuthority,
    transferFeeBasisPoints: transferFeeBasisPoints,
    maximumFee: maximumFee,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeTransferFeeConfigInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeTransferFeeConfig] instruction from raw instruction data.
InitializeTransferFeeConfigInstructionData
parseInitializeTransferFeeConfigInstruction(Instruction instruction) {
  return getInitializeTransferFeeConfigInstructionDataDecoder().decode(
    instruction.data!,
  );
}
