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

/// The discriminator field name: 'permissionedBurnDiscriminator'.
/// Offset: 1.

@immutable
class InitializePermissionedBurnInstructionData {
  const InitializePermissionedBurnInstructionData({
    required this.authority,
  }) : discriminator = 46,
       permissionedBurnDiscriminator = 0;

  final int discriminator;
  final int permissionedBurnDiscriminator;
  final Address authority;
}

Encoder<InitializePermissionedBurnInstructionData>
getInitializePermissionedBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('permissionedBurnDiscriminator', getU8Encoder()),
    ('authority', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializePermissionedBurnInstructionData value) => <String, Object?>{
      'discriminator': 46,
      'permissionedBurnDiscriminator': 0,
      'authority': value.authority,
    },
  );
}

Decoder<InitializePermissionedBurnInstructionData>
getInitializePermissionedBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('permissionedBurnDiscriminator', getU8Decoder()),
    ('authority', getAddressDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializePermissionedBurn instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializePermissionedBurnInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(46),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializePermissionedBurnInstructionData(
        authority: map['authority']! as Address,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializePermissionedBurnInstructionData>(
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
      VariableSizeDecoder<InitializePermissionedBurnInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializePermissionedBurnInstructionData,
  InitializePermissionedBurnInstructionData
>
getInitializePermissionedBurnInstructionDataCodec() {
  return combineCodec(
    getInitializePermissionedBurnInstructionDataEncoder(),
    getInitializePermissionedBurnInstructionDataDecoder(),
  );
}

/// Creates a [InitializePermissionedBurn] instruction.
Instruction getInitializePermissionedBurnInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,
}) {
  final instructionData = InitializePermissionedBurnInstructionData(
    authority: authority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializePermissionedBurnInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializePermissionedBurn] instruction from raw instruction data.
InitializePermissionedBurnInstructionData
parseInitializePermissionedBurnInstruction(Instruction instruction) {
  return getInitializePermissionedBurnInstructionDataDecoder().decode(
    instruction.data!,
  );
}
