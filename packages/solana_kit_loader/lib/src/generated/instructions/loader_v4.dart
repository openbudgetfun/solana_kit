// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

const loaderV4WriteDiscriminator = 0;
const truncateDiscriminator = 1;
const deployDiscriminator = 2;
const retractDiscriminator = 3;
const transferAuthorityDiscriminator = 4;
const finalizeDiscriminator = 5;

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

@immutable
class LoaderV4WriteInstructionData {
  const LoaderV4WriteInstructionData({
    required this.offset,
    required this.bytes,
    this.discriminator = loaderV4WriteDiscriminator,
  });

  final int discriminator;
  final int offset;
  final Uint8List bytes;
}

Encoder<LoaderV4WriteInstructionData> getLoaderV4WriteInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('offset', getU32Encoder()),
    ('bytes', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
  ]);
  return transformEncoder(
    structEncoder,
    (LoaderV4WriteInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'offset': value.offset,
      'bytes': value.bytes,
    },
  );
}

Decoder<LoaderV4WriteInstructionData> getLoaderV4WriteInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('offset', getU32Decoder()),
    ('bytes', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
  ]);
  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, _, _) => LoaderV4WriteInstructionData(
      discriminator: map['discriminator']! as int,
      offset: map['offset']! as int,
      bytes: map['bytes']! as Uint8List,
    ),
  );
}

@immutable
class TruncateInstructionData {
  const TruncateInstructionData({
    required this.newSize,
    this.discriminator = truncateDiscriminator,
  });

  final int discriminator;
  final int newSize;
}

Encoder<TruncateInstructionData> getTruncateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('newSize', getU32Encoder()),
  ]);
  return transformEncoder(
    structEncoder,
    (TruncateInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'newSize': value.newSize,
    },
  );
}

Decoder<TruncateInstructionData> getTruncateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('newSize', getU32Decoder()),
  ]);
  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, _, _) => TruncateInstructionData(
      discriminator: map['discriminator']! as int,
      newSize: map['newSize']! as int,
    ),
  );
}

Uint8List _discriminatorData(int discriminator) =>
    getU8Encoder().encode(discriminator);

int parseLoaderV4Discriminator(Instruction instruction) =>
    getU8Decoder().decode(instruction.data!);

Instruction getLoaderV4WriteInstruction({
  required Address program,
  required Address authority,
  required int offset,
  required Uint8List bytes,
  Address programAddress = loaderV4ProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(program, writable: true),
    _account(authority, writable: false, signer: true),
  ],
  data: getLoaderV4WriteInstructionDataEncoder().encode(
    LoaderV4WriteInstructionData(offset: offset, bytes: bytes),
  ),
);

LoaderV4WriteInstructionData parseLoaderV4WriteInstruction(Instruction ix) =>
    getLoaderV4WriteInstructionDataDecoder().decode(ix.data!);

Instruction getLoaderV4TruncateInstruction({
  required Address program,
  required Address authority,
  required Address destination,
  required int newSize,
  Address programAddress = loaderV4ProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(program, writable: true, signer: true),
    _account(authority, writable: false, signer: true),
    _account(destination, writable: true),
  ],
  data: getTruncateInstructionDataEncoder().encode(
    TruncateInstructionData(newSize: newSize),
  ),
);

TruncateInstructionData parseLoaderV4TruncateInstruction(Instruction ix) =>
    getTruncateInstructionDataDecoder().decode(ix.data!);

Instruction getLoaderV4DeployInstruction({
  required Address program,
  required Address authority,
  required Address source,
  Address programAddress = loaderV4ProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(program, writable: true),
    _account(authority, writable: false, signer: true),
    _account(source, writable: true),
  ],
  data: _discriminatorData(deployDiscriminator),
);

Instruction getLoaderV4RetractInstruction({
  required Address program,
  required Address authority,
  Address programAddress = loaderV4ProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(program, writable: true),
    _account(authority, writable: false, signer: true),
  ],
  data: _discriminatorData(retractDiscriminator),
);

Instruction getLoaderV4TransferAuthorityInstruction({
  required Address program,
  required Address newAuthority,
  Address programAddress = loaderV4ProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(program, writable: true),
    _account(newAuthority, writable: false, signer: true),
  ],
  data: _discriminatorData(transferAuthorityDiscriminator),
);

Instruction getLoaderV4FinalizeInstruction({
  required Address program,
  required Address authority,
  required Address nextVersion,
  Address programAddress = loaderV4ProgramAddress,
}) => Instruction(
  programAddress: programAddress,
  accounts: [
    _account(program, writable: true),
    _account(authority, writable: false, signer: true),
    _account(nextVersion, writable: false),
  ],
  data: _discriminatorData(finalizeDiscriminator),
);
