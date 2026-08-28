// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './multisig_compiled_instruction.dart';
import './multisig_message_address_table_lookup.dart';

@immutable
class VaultTransactionMessage {
  const VaultTransactionMessage({
    required this.numSigners,
    required this.numWritableSigners,
    required this.numWritableNonSigners,
    required this.accountKeys,
    required this.instructions,
    required this.addressTableLookups,
  });

  final int numSigners;
  final int numWritableSigners;
  final int numWritableNonSigners;
  final List<Address> accountKeys;
  final List<MultisigCompiledInstruction> instructions;
  final List<MultisigMessageAddressTableLookup> addressTableLookups;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultTransactionMessage &&
          runtimeType == other.runtimeType &&
          numSigners == other.numSigners &&
          numWritableSigners == other.numWritableSigners &&
          numWritableNonSigners == other.numWritableNonSigners &&
          accountKeys == other.accountKeys &&
          instructions == other.instructions &&
          addressTableLookups == other.addressTableLookups;

  @override
  int get hashCode => Object.hash(
    numSigners,
    numWritableSigners,
    numWritableNonSigners,
    accountKeys,
    instructions,
    addressTableLookups,
  );

  @override
  String toString() =>
      'VaultTransactionMessage(numSigners: $numSigners, numWritableSigners: $numWritableSigners, numWritableNonSigners: $numWritableNonSigners, accountKeys: $accountKeys, instructions: $instructions, addressTableLookups: $addressTableLookups)';
}

Encoder<VaultTransactionMessage> getVaultTransactionMessageEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('numSigners', getU8Encoder()),
    ('numWritableSigners', getU8Encoder()),
    ('numWritableNonSigners', getU8Encoder()),
    (
      'accountKeys',
      getArrayEncoder<Address>(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
    (
      'instructions',
      getArrayEncoder<MultisigCompiledInstruction>(
        transformEncoder(
          getMultisigCompiledInstructionEncoder(),
          (MultisigCompiledInstruction value) => value,
        ),
      ),
    ),
    (
      'addressTableLookups',
      getArrayEncoder<MultisigMessageAddressTableLookup>(
        transformEncoder(
          getMultisigMessageAddressTableLookupEncoder(),
          (MultisigMessageAddressTableLookup value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (VaultTransactionMessage value) => <String, Object?>{
      'numSigners': value.numSigners,
      'numWritableSigners': value.numWritableSigners,
      'numWritableNonSigners': value.numWritableNonSigners,
      'accountKeys': value.accountKeys,
      'instructions': value.instructions,
      'addressTableLookups': value.addressTableLookups,
    },
  );
}

Decoder<VaultTransactionMessage> getVaultTransactionMessageDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('numSigners', getU8Decoder()),
    ('numWritableSigners', getU8Decoder()),
    ('numWritableNonSigners', getU8Decoder()),
    ('accountKeys', getArrayDecoder(getAddressDecoder())),
    ('instructions', getArrayDecoder(getMultisigCompiledInstructionDecoder())),
    (
      'addressTableLookups',
      getArrayDecoder(getMultisigMessageAddressTableLookupDecoder()),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        VaultTransactionMessage(
          numSigners: map['numSigners']! as int,
          numWritableSigners: map['numWritableSigners']! as int,
          numWritableNonSigners: map['numWritableNonSigners']! as int,
          accountKeys: map['accountKeys']! as List<Address>,
          instructions:
              map['instructions']! as List<MultisigCompiledInstruction>,
          addressTableLookups:
              map['addressTableLookups']!
                  as List<MultisigMessageAddressTableLookup>,
        ),
  );
}

Codec<VaultTransactionMessage, VaultTransactionMessage>
getVaultTransactionMessageCodec() {
  return combineCodec(
    getVaultTransactionMessageEncoder(),
    getVaultTransactionMessageDecoder(),
  );
}
