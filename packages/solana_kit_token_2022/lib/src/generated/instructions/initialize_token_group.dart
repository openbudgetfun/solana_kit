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

@immutable
class InitializeTokenGroupInstructionData {
  InitializeTokenGroupInstructionData({
    required this.updateAuthority,
    required this.maxSize,
  }) : discriminator = Uint8List.fromList([
         0x79,
         0x71,
         0x6c,
         0x27,
         0x36,
         0x33,
         0x00,
         0x04,
       ]);

  final Uint8List discriminator;
  final Address? updateAuthority;
  final BigInt maxSize;
}

Encoder<InitializeTokenGroupInstructionData>
getInitializeTokenGroupInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    (
      'updateAuthority',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    ('maxSize', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeTokenGroupInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x79,
        0x71,
        0x6c,
        0x27,
        0x36,
        0x33,
        0x00,
        0x04,
      ]),
      'updateAuthority': value.updateAuthority,
      'maxSize': value.maxSize,
    },
  );
}

Decoder<InitializeTokenGroupInstructionData>
getInitializeTokenGroupInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    (
      'updateAuthority',
      getNullableDecoder<Address>(
        getAddressDecoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
    ('maxSize', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeTokenGroup instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeTokenGroupInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x79, 0x71, 0x6c, 0x27, 0x36, 0x33, 0x00, 0x04]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeTokenGroupInstructionData(
        updateAuthority: map['updateAuthority'] as Address?,
        maxSize: map['maxSize']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeTokenGroupInstructionData>(
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
      VariableSizeDecoder<InitializeTokenGroupInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<InitializeTokenGroupInstructionData, InitializeTokenGroupInstructionData>
getInitializeTokenGroupInstructionDataCodec() {
  return combineCodec(
    getInitializeTokenGroupInstructionDataEncoder(),
    getInitializeTokenGroupInstructionDataDecoder(),
  );
}

/// Creates a [InitializeTokenGroup] instruction.
Instruction getInitializeTokenGroupInstruction({
  required Address programAddress,
  required Address group,
  required Address mint,
  required Address mintAuthority,
  required Address? updateAuthority,
  required BigInt maxSize,
}) {
  final instructionData = InitializeTokenGroupInstructionData(
    updateAuthority: updateAuthority,
    maxSize: maxSize,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: group, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
    ],
    data: getInitializeTokenGroupInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeTokenGroup] instruction from raw instruction data.
InitializeTokenGroupInstructionData parseInitializeTokenGroupInstruction(
  Instruction instruction,
) {
  return getInitializeTokenGroupInstructionDataDecoder().decode(
    instruction.data!,
  );
}
