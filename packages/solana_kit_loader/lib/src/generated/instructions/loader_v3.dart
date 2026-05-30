// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_loader/src/generated/programs/bpf_loader_upgradeable.dart';

const initializeBufferDiscriminator = 0;
const loaderV3WriteDiscriminator = 1;
const deployWithMaxProgramLenDiscriminator = 2;
const upgradeDiscriminator = 3;
const setAuthorityDiscriminator = 4;
const closeDiscriminator = 5;
const extendProgramDiscriminator = 6;
const setAuthorityCheckedDiscriminator = 7;

const rentSysvarAddress = Address(
  'SysvarRent111111111111111111111111111111111',
);
const clockSysvarAddress = Address(
  'SysvarC1ock11111111111111111111111111111111',
);
const systemProgramAddress = Address('11111111111111111111111111111111');

AccountMeta _account(
  Address address, {
  required bool writable,
  bool signer = false,
}) {
  final role = switch ((writable, signer)) {
    (true, true) => AccountRole.writableSigner,
    (true, false) => AccountRole.writable,
    (false, true) => AccountRole.readonlySigner,
    (false, false) => AccountRole.readonly,
  };
  return AccountMeta(address: address, role: role);
}

Encoder<num> _getU64SizePrefixEncoder() =>
    transformEncoder<BigInt, num>(getU64Encoder(), BigInt.from);

Decoder<num> _getU64SizePrefixDecoder() => transformDecoder<BigInt, num>(
  getU64Decoder(),
  (value, _, _) => value.toInt(),
);

@immutable
class LoaderV3WriteInstructionData {
  const LoaderV3WriteInstructionData({
    required this.offset,
    required this.bytes,
    this.discriminator = loaderV3WriteDiscriminator,
  });

  final int discriminator;
  final int offset;
  final Uint8List bytes;
}

Encoder<LoaderV3WriteInstructionData> getLoaderV3WriteInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('offset', getU32Encoder()),
    (
      'bytes',
      addEncoderSizePrefix(getBytesEncoder(), _getU64SizePrefixEncoder()),
    ),
  ]);
  return transformEncoder(
    structEncoder,
    (LoaderV3WriteInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'offset': value.offset,
      'bytes': value.bytes,
    },
  );
}

Decoder<LoaderV3WriteInstructionData> getLoaderV3WriteInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('offset', getU32Decoder()),
    (
      'bytes',
      addDecoderSizePrefix(getBytesDecoder(), _getU64SizePrefixDecoder()),
    ),
  ]);
  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, _, _) => LoaderV3WriteInstructionData(
      discriminator: map['discriminator']! as int,
      offset: map['offset']! as int,
      bytes: map['bytes']! as Uint8List,
    ),
  );
}

@immutable
class DeployWithMaxProgramLenInstructionData {
  const DeployWithMaxProgramLenInstructionData({
    required this.maxDataLen,
    this.discriminator = deployWithMaxProgramLenDiscriminator,
  });

  final int discriminator;
  final BigInt maxDataLen;
}

Encoder<DeployWithMaxProgramLenInstructionData>
getDeployWithMaxProgramLenInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('maxDataLen', getU64Encoder()),
  ]);
  return transformEncoder(
    structEncoder,
    (DeployWithMaxProgramLenInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'maxDataLen': value.maxDataLen,
    },
  );
}

Decoder<DeployWithMaxProgramLenInstructionData>
getDeployWithMaxProgramLenInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('maxDataLen', getU64Decoder()),
  ]);
  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, _, _) => DeployWithMaxProgramLenInstructionData(
      discriminator: map['discriminator']! as int,
      maxDataLen: map['maxDataLen']! as BigInt,
    ),
  );
}

@immutable
class ExtendProgramInstructionData {
  const ExtendProgramInstructionData({
    required this.additionalBytes,
    this.discriminator = extendProgramDiscriminator,
  });

  final int discriminator;
  final int additionalBytes;
}

Encoder<ExtendProgramInstructionData> getExtendProgramInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('additionalBytes', getU32Encoder()),
  ]);
  return transformEncoder(
    structEncoder,
    (ExtendProgramInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'additionalBytes': value.additionalBytes,
    },
  );
}

Decoder<ExtendProgramInstructionData> getExtendProgramInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('additionalBytes', getU32Decoder()),
  ]);
  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, _, _) => ExtendProgramInstructionData(
      discriminator: map['discriminator']! as int,
      additionalBytes: map['additionalBytes']! as int,
    ),
  );
}

Uint8List _discriminatorData(int discriminator) =>
    getU32Encoder().encode(discriminator);

int parseDiscriminator(Instruction instruction) =>
    getU32Decoder().decode(instruction.data!);

Instruction getInitializeBufferInstruction({
  required Address sourceAccount,
  required Address bufferAuthority,
  Address programAddress = bpfLoaderUpgradeableProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(sourceAccount, writable: true),
    _account(bufferAuthority, writable: false),
  ],
  data: _discriminatorData(initializeBufferDiscriminator),
);

Instruction getLoaderV3WriteInstruction({
  required Address bufferAccount,
  required Address bufferAuthority,
  required int offset,
  required Uint8List bytes,
  Address programAddress = bpfLoaderUpgradeableProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(bufferAccount, writable: true),
    _account(bufferAuthority, writable: false, signer: true),
  ],
  data: getLoaderV3WriteInstructionDataEncoder().encode(
    LoaderV3WriteInstructionData(offset: offset, bytes: bytes),
  ),
);

LoaderV3WriteInstructionData parseLoaderV3WriteInstruction(Instruction ix) =>
    getLoaderV3WriteInstructionDataDecoder().decode(ix.data!);

Instruction getDeployWithMaxProgramLenInstruction({
  required Address payerAccount,
  required Address programDataAccount,
  required Address programAccount,
  required Address bufferAccount,
  required Address authority,
  required BigInt maxDataLen,
  Address rentSysvar = rentSysvarAddress,
  Address clockSysvar = clockSysvarAddress,
  Address systemProgram = systemProgramAddress,
  Address instructionProgramAddress = bpfLoaderUpgradeableProgramAddress,
}) => Instruction(
  programAddress: instructionProgramAddress,
  accounts: [
    _account(payerAccount, writable: true, signer: true),
    _account(programDataAccount, writable: true),
    _account(programAccount, writable: true),
    _account(bufferAccount, writable: true),
    _account(rentSysvar, writable: false),
    _account(clockSysvar, writable: false),
    _account(systemProgram, writable: false),
    _account(authority, writable: false, signer: true),
  ],
  data: getDeployWithMaxProgramLenInstructionDataEncoder().encode(
    DeployWithMaxProgramLenInstructionData(maxDataLen: maxDataLen),
  ),
);

DeployWithMaxProgramLenInstructionData parseDeployWithMaxProgramLenInstruction(
  Instruction ix,
) => getDeployWithMaxProgramLenInstructionDataDecoder().decode(ix.data!);

Instruction getUpgradeInstruction({
  required Address programDataAccount,
  required Address programAccount,
  required Address bufferAccount,
  required Address spillAccount,
  required Address authority,
  Address rentSysvar = rentSysvarAddress,
  Address clockSysvar = clockSysvarAddress,
  Address programAddress = bpfLoaderUpgradeableProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(programDataAccount, writable: true),
    _account(programAccount, writable: true),
    _account(bufferAccount, writable: true),
    _account(spillAccount, writable: true),
    _account(rentSysvar, writable: false),
    _account(clockSysvar, writable: false),
    _account(authority, writable: false, signer: true),
  ],
  data: _discriminatorData(upgradeDiscriminator),
);

Instruction getSetAuthorityInstruction({
  required Address bufferOrProgramDataAccount,
  required Address currentAuthority,
  Address? newAuthority,
  Address programAddress = bpfLoaderUpgradeableProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(bufferOrProgramDataAccount, writable: true),
    _account(currentAuthority, writable: false, signer: true),
    if (newAuthority != null) _account(newAuthority, writable: false),
  ],
  data: _discriminatorData(setAuthorityDiscriminator),
);

Instruction getCloseInstruction({
  required Address bufferOrProgramDataAccount,
  required Address destinationAccount,
  required Address authority,
  Address? programAccount,
  Address programAddress = bpfLoaderUpgradeableProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(bufferOrProgramDataAccount, writable: true),
    _account(destinationAccount, writable: true),
    _account(authority, writable: false, signer: true),
    if (programAccount != null) _account(programAccount, writable: false),
  ],
  data: _discriminatorData(closeDiscriminator),
);

Instruction getExtendProgramInstruction({
  required Address programDataAccount,
  required Address programAccount,
  required int additionalBytes,
  Address systemProgram = systemProgramAddress,
  Address? payer,
  Address instructionProgramAddress = bpfLoaderUpgradeableProgramAddress,
}) => Instruction(
  programAddress: instructionProgramAddress,
  accounts: [
    _account(programDataAccount, writable: true),
    _account(programAccount, writable: true),
    _account(systemProgram, writable: false),
    if (payer != null) _account(payer, writable: true, signer: true),
  ],
  data: getExtendProgramInstructionDataEncoder().encode(
    ExtendProgramInstructionData(additionalBytes: additionalBytes),
  ),
);

ExtendProgramInstructionData parseExtendProgramInstruction(Instruction ix) =>
    getExtendProgramInstructionDataDecoder().decode(ix.data!);

Instruction getSetAuthorityCheckedInstruction({
  required Address bufferOrProgramDataAccount,
  required Address currentAuthority,
  required Address newAuthority,
  Address programAddress = bpfLoaderUpgradeableProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(bufferOrProgramDataAccount, writable: true),
    _account(currentAuthority, writable: false, signer: true),
    _account(newAuthority, writable: false, signer: true),
  ],
  data: _discriminatorData(setAuthorityCheckedDiscriminator),
);
