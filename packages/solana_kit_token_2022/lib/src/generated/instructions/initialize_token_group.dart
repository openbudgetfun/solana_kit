// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class InitializeTokenGroupInstructionData {
  InitializeTokenGroupInstructionData({
    Uint8List? discriminator,
    required this.updateAuthority,
    required this.maxSize,
  }) :
      discriminator = discriminator ?? Uint8List.fromList([121, 113, 108, 39, 54, 51, 0, 4]);

  final Uint8List discriminator;
  final Address? updateAuthority;
  final BigInt maxSize;
}

Encoder<InitializeTokenGroupInstructionData> getInitializeTokenGroupInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getBytesEncoder()),
    ('updateAuthority', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('maxSize', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeTokenGroupInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'updateAuthority': value.updateAuthority,
      'maxSize': value.maxSize,
    },
  );
}

Decoder<InitializeTokenGroupInstructionData> getInitializeTokenGroupInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getBytesDecoder()),
    ('updateAuthority', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('maxSize', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeTokenGroupInstructionData(
      discriminator: map['discriminator']! as Uint8List,
      updateAuthority: map['updateAuthority'] as Address?,
      maxSize: map['maxSize']! as BigInt,
    ),
  );
}

Codec<InitializeTokenGroupInstructionData, InitializeTokenGroupInstructionData> getInitializeTokenGroupInstructionDataCodec() {
  return combineCodec(getInitializeTokenGroupInstructionDataEncoder(), getInitializeTokenGroupInstructionDataDecoder());
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
    data: getInitializeTokenGroupInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeTokenGroup] instruction from raw instruction data.
InitializeTokenGroupInstructionData parseInitializeTokenGroupInstruction(Instruction instruction) {
  return getInitializeTokenGroupInstructionDataDecoder().decode(instruction.data!);
}
