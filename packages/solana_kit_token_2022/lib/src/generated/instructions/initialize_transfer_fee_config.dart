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

/// The discriminator field name: 'transferFeeDiscriminator'.
/// Offset: 1.

@immutable
class InitializeTransferFeeConfigInstructionData {
  const InitializeTransferFeeConfigInstructionData({
    this.discriminator = 26,
    this.transferFeeDiscriminator = 0,
    required this.transferFeeConfigAuthority,
    required this.withdrawWithheldAuthority,
    required this.transferFeeBasisPoints,
    required this.maximumFee,
  });

  final int discriminator;
  final int transferFeeDiscriminator;
  final Address? transferFeeConfigAuthority;
  final Address? withdrawWithheldAuthority;
  final int transferFeeBasisPoints;
  final BigInt maximumFee;
}

Encoder<InitializeTransferFeeConfigInstructionData> getInitializeTransferFeeConfigInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferFeeDiscriminator', getU8Encoder()),
    ('transferFeeConfigAuthority', getNullableEncoder<Address>(getAddressEncoder())),
    ('withdrawWithheldAuthority', getNullableEncoder<Address>(getAddressEncoder())),
    ('transferFeeBasisPoints', getU16Encoder()),
    ('maximumFee', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeTransferFeeConfigInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'transferFeeDiscriminator': value.transferFeeDiscriminator,
      'transferFeeConfigAuthority': value.transferFeeConfigAuthority,
      'withdrawWithheldAuthority': value.withdrawWithheldAuthority,
      'transferFeeBasisPoints': value.transferFeeBasisPoints,
      'maximumFee': value.maximumFee,
    },
  );
}

Decoder<InitializeTransferFeeConfigInstructionData> getInitializeTransferFeeConfigInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferFeeDiscriminator', getU8Decoder()),
    ('transferFeeConfigAuthority', getNullableDecoder<Address>(getAddressDecoder())),
    ('withdrawWithheldAuthority', getNullableDecoder<Address>(getAddressDecoder())),
    ('transferFeeBasisPoints', getU16Decoder()),
    ('maximumFee', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeTransferFeeConfigInstructionData(
      discriminator: map['discriminator']! as int,
      transferFeeDiscriminator: map['transferFeeDiscriminator']! as int,
      transferFeeConfigAuthority: map['transferFeeConfigAuthority'] as Address?,
      withdrawWithheldAuthority: map['withdrawWithheldAuthority'] as Address?,
      transferFeeBasisPoints: map['transferFeeBasisPoints']! as int,
      maximumFee: map['maximumFee']! as BigInt,
    ),
  );
}

Codec<InitializeTransferFeeConfigInstructionData, InitializeTransferFeeConfigInstructionData> getInitializeTransferFeeConfigInstructionDataCodec() {
  return combineCodec(getInitializeTransferFeeConfigInstructionDataEncoder(), getInitializeTransferFeeConfigInstructionDataDecoder());
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
    data: getInitializeTransferFeeConfigInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeTransferFeeConfig] instruction from raw instruction data.
InitializeTransferFeeConfigInstructionData parseInitializeTransferFeeConfigInstruction(Instruction instruction) {
  return getInitializeTransferFeeConfigInstructionDataDecoder().decode(instruction.data!);
}
