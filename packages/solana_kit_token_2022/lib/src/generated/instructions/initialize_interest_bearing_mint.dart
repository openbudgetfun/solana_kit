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
class InitializeInterestBearingMintInstructionData {
  const InitializeInterestBearingMintInstructionData({
    required this.rateAuthority,
    required this.rate,
  }) : discriminator = 33,
       interestBearingMintDiscriminator = 0;

  final int discriminator;
  final int interestBearingMintDiscriminator;
  final Address? rateAuthority;
  final int rate;
}

Encoder<InitializeInterestBearingMintInstructionData>
getInitializeInterestBearingMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('interestBearingMintDiscriminator', getU8Encoder()),
    (
      'rateAuthority',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    ('rate', getI16Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeInterestBearingMintInstructionData value) => <String, Object?>{
      'discriminator': 33,
      'interestBearingMintDiscriminator': 0,
      'rateAuthority': value.rateAuthority,
      'rate': value.rate,
    },
  );
}

Decoder<InitializeInterestBearingMintInstructionData>
getInitializeInterestBearingMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('interestBearingMintDiscriminator', getU8Decoder()),
    (
      'rateAuthority',
      getNullableDecoder<Address>(
        getAddressDecoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    ('rate', getI16Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeInterestBearingMint instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeInterestBearingMintInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(33),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeInterestBearingMintInstructionData(
        rateAuthority: map['rateAuthority'] as Address?,
        rate: map['rate']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeInterestBearingMintInstructionData>(
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
      VariableSizeDecoder<InitializeInterestBearingMintInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializeInterestBearingMintInstructionData,
  InitializeInterestBearingMintInstructionData
>
getInitializeInterestBearingMintInstructionDataCodec() {
  return combineCodec(
    getInitializeInterestBearingMintInstructionDataEncoder(),
    getInitializeInterestBearingMintInstructionDataDecoder(),
  );
}

/// Creates a [InitializeInterestBearingMint] instruction.
Instruction getInitializeInterestBearingMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address? rateAuthority,
  required int rate,
}) {
  final instructionData = InitializeInterestBearingMintInstructionData(
    rateAuthority: rateAuthority,
    rate: rate,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeInterestBearingMintInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeInterestBearingMint] instruction from raw instruction data.
InitializeInterestBearingMintInstructionData
parseInitializeInterestBearingMintInstruction(Instruction instruction) {
  return getInitializeInterestBearingMintInstructionDataDecoder().decode(
    instruction.data!,
  );
}
