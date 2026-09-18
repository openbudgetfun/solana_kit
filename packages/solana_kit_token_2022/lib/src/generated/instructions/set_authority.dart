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

import '../types/authority_type.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class SetAuthorityInstructionData {
  const SetAuthorityInstructionData({
    required this.authorityType,
    required this.newAuthority,
  }) : discriminator = 6;

  final int discriminator;
  final AuthorityType authorityType;
  final Address? newAuthority;
}

Encoder<SetAuthorityInstructionData> getSetAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('authorityType', getAuthorityTypeEncoder()),
    (
      'newAuthority',
      getNullableEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (SetAuthorityInstructionData value) => <String, Object?>{
      'discriminator': 6,
      'authorityType': value.authorityType,
      'newAuthority': value.newAuthority,
    },
  );
}

Decoder<SetAuthorityInstructionData> getSetAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('authorityType', getAuthorityTypeDecoder()),
    ('newAuthority', getNullableDecoder<Address>(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'setAuthority instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (SetAuthorityInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(6),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      SetAuthorityInstructionData(
        authorityType: map['authorityType']! as AuthorityType,
        newAuthority: map['newAuthority'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<SetAuthorityInstructionData>(
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
      VariableSizeDecoder<SetAuthorityInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<SetAuthorityInstructionData, SetAuthorityInstructionData>
getSetAuthorityInstructionDataCodec() {
  return combineCodec(
    getSetAuthorityInstructionDataEncoder(),
    getSetAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [SetAuthority] instruction.
/// Set [ownerIsSigner] to false when [owner] does not sign (for example, a multisig authority).
Instruction getSetAuthorityInstruction({
  required Address programAddress,
  required Address owned,
  required Address owner,
  required AuthorityType authorityType,
  required Address? newAuthority,
  bool ownerIsSigner = true,
}) {
  final instructionData = SetAuthorityInstructionData(
    authorityType: authorityType,
    newAuthority: newAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: owned, role: AccountRole.writable),
      AccountMeta(
        address: owner,
        role: ownerIsSigner ? AccountRole.readonlySigner : AccountRole.readonly,
      ),
    ],
    data: getSetAuthorityInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetAuthority] instruction from raw instruction data.
SetAuthorityInstructionData parseSetAuthorityInstruction(
  Instruction instruction,
) {
  return getSetAuthorityInstructionDataDecoder().decode(instruction.data!);
}
