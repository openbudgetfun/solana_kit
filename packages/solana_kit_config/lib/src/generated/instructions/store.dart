// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_config/src/generated/programs/solana_config.dart';
import 'package:solana_kit_config/src/generated/types/config_keys.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Data for the Store instruction.
@immutable
class StoreInstructionData {
  /// Creates [StoreInstructionData].
  const StoreInstructionData({required this.keys, required this.data});

  /// List of pubkeys to store in the config account.
  final ConfigKeys keys;

  /// Arbitrary data to store in the config account.
  final Uint8List data;

  @override
  String toString() => 'StoreInstructionData(keys: $keys, data: $data)';

  @override
  bool operator ==(Object other) =>
      other is StoreInstructionData &&
      _configKeysEqual(other.keys, keys) &&
      _bytesEqual(other.data, data);

  @override
  int get hashCode => Object.hash(Object.hashAll(keys), Object.hashAll(data));
}

/// Returns the encoder for [StoreInstructionData].
Encoder<StoreInstructionData> getStoreInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('keys', getConfigKeysEncoder()),
    ('data', getBytesEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (StoreInstructionData value) => <String, Object?>{
      'keys': value.keys,
      'data': value.data,
    },
  );
}

/// Returns the decoder for [StoreInstructionData].
Decoder<StoreInstructionData> getStoreInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('keys', getConfigKeysDecoder()),
    ('data', getBytesDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, bytes, offset) => StoreInstructionData(
      keys: map['keys']! as ConfigKeys,
      data: map['data']! as Uint8List,
    ),
  );
}

/// Returns the codec for [StoreInstructionData].
Codec<StoreInstructionData, StoreInstructionData>
getStoreInstructionDataCodec() => combineCodec(
  getStoreInstructionDataEncoder(),
  getStoreInstructionDataDecoder(),
);

/// Creates a Store instruction.
Instruction getStoreInstruction({
  required Address configAccount,
  required ConfigKeys keys,
  required Uint8List data,
  List<Address> signers = const [],
  bool configAccountIsSigner = false,
  Address programAddress = solanaConfigProgramAddress,
}) {
  final instructionData = StoreInstructionData(keys: keys, data: data);
  final accounts = <AccountMeta>[
    AccountMeta(
      address: configAccount,
      role: configAccountIsSigner
          ? AccountRole.writableSigner
          : AccountRole.writable,
    ),
    for (final signer in signers)
      AccountMeta(address: signer, role: AccountRole.readonlySigner),
  ];

  return Instruction(
    programAddress: programAddress,
    accounts: accounts,
    data: getStoreInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a Store instruction from [instruction].
StoreInstructionData parseStoreInstruction(Instruction instruction) =>
    getStoreInstructionDataDecoder().decode(instruction.data!);

bool _configKeysEqual(ConfigKeys left, ConfigKeys right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool _bytesEqual(Uint8List left, Uint8List right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
