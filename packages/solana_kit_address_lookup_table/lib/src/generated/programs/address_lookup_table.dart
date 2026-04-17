// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:solana_kit_address_lookup_table/src/generated/instructions/close_lookup_table.dart';
import 'package:solana_kit_address_lookup_table/src/generated/instructions/create_lookup_table.dart';
import 'package:solana_kit_address_lookup_table/src/generated/instructions/deactivate_lookup_table.dart';
import 'package:solana_kit_address_lookup_table/src/generated/instructions/extend_lookup_table.dart';
import 'package:solana_kit_address_lookup_table/src/generated/instructions/freeze_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The canonical Address Lookup Table program address.
const addressLookupTableProgramAddress = Address(
  'AddressLookupTab1e1111111111111111111111111',
);

/// Known instruction types for the Address Lookup Table program.
enum AddressLookupTableInstruction {
  /// Create a new address lookup table (discriminator 0).
  createLookupTable,

  /// Freeze a lookup table, preventing further modifications (discriminator 1).
  freezeLookupTable,

  /// Extend a lookup table with additional addresses (discriminator 2).
  extendLookupTable,

  /// Deactivate a lookup table (discriminator 3).
  deactivateLookupTable,

  /// Close a deactivated lookup table and reclaim lamports (discriminator 4).
  closeLookupTable,
}

/// Identifies the instruction type from raw instruction [data].
///
/// Returns the matching [AddressLookupTableInstruction] variant based on the
/// u32 LE discriminator at offset 0.
///
/// Throws [ArgumentError] if the discriminator is unrecognized.
AddressLookupTableInstruction identifyAddressLookupTableInstruction(
  Uint8List data,
) {
  if (data.length < 4) {
    throw ArgumentError('Instruction data too short for u32 discriminator');
  }
  final discriminator =
      data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
  return switch (discriminator) {
    0 => AddressLookupTableInstruction.createLookupTable,
    1 => AddressLookupTableInstruction.freezeLookupTable,
    2 => AddressLookupTableInstruction.extendLookupTable,
    3 => AddressLookupTableInstruction.deactivateLookupTable,
    4 => AddressLookupTableInstruction.closeLookupTable,
    _ => throw ArgumentError(
      'Unrecognized Address Lookup Table instruction discriminator: '
      '$discriminator',
    ),
  };
}

/// A parsed Address Lookup Table instruction with its identified type and data.
sealed class ParsedAddressLookupTableInstruction {
  /// The instruction type.
  AddressLookupTableInstruction get instructionType;
}

/// A parsed [AddressLookupTableInstruction.createLookupTable] instruction.
class ParsedCreateLookupTable
    implements ParsedAddressLookupTableInstruction {
  /// Creates a [ParsedCreateLookupTable].
  const ParsedCreateLookupTable(this.data);

  @override
  AddressLookupTableInstruction get instructionType =>
      AddressLookupTableInstruction.createLookupTable;

  /// The decoded instruction data.
  final CreateLookupTableInstructionData data;
}

/// A parsed [AddressLookupTableInstruction.freezeLookupTable] instruction.
class ParsedFreezeLookupTable
    implements ParsedAddressLookupTableInstruction {
  /// Creates a [ParsedFreezeLookupTable].
  const ParsedFreezeLookupTable(this.data);

  @override
  AddressLookupTableInstruction get instructionType =>
      AddressLookupTableInstruction.freezeLookupTable;

  /// The decoded instruction data.
  final FreezeLookupTableInstructionData data;
}

/// A parsed [AddressLookupTableInstruction.extendLookupTable] instruction.
class ParsedExtendLookupTable
    implements ParsedAddressLookupTableInstruction {
  /// Creates a [ParsedExtendLookupTable].
  const ParsedExtendLookupTable(this.data);

  @override
  AddressLookupTableInstruction get instructionType =>
      AddressLookupTableInstruction.extendLookupTable;

  /// The decoded instruction data.
  final ExtendLookupTableInstructionData data;
}

/// A parsed [AddressLookupTableInstruction.deactivateLookupTable] instruction.
class ParsedDeactivateLookupTable
    implements ParsedAddressLookupTableInstruction {
  /// Creates a [ParsedDeactivateLookupTable].
  const ParsedDeactivateLookupTable(this.data);

  @override
  AddressLookupTableInstruction get instructionType =>
      AddressLookupTableInstruction.deactivateLookupTable;

  /// The decoded instruction data.
  final DeactivateLookupTableInstructionData data;
}

/// A parsed [AddressLookupTableInstruction.closeLookupTable] instruction.
class ParsedCloseLookupTable
    implements ParsedAddressLookupTableInstruction {
  /// Creates a [ParsedCloseLookupTable].
  const ParsedCloseLookupTable(this.data);

  @override
  AddressLookupTableInstruction get instructionType =>
      AddressLookupTableInstruction.closeLookupTable;

  /// The decoded instruction data.
  final CloseLookupTableInstructionData data;
}

/// Parses an Address Lookup Table [instruction] into a typed
/// [ParsedAddressLookupTableInstruction].
///
/// Throws [ArgumentError] if the instruction cannot be identified.
ParsedAddressLookupTableInstruction parseAddressLookupTableInstruction(
  Instruction instruction,
) {
  final data = instruction.data;
  if (data == null || data.length < 4) {
    throw ArgumentError('Instruction has no data or data too short');
  }

  final type = identifyAddressLookupTableInstruction(data);

  return switch (type) {
    AddressLookupTableInstruction.createLookupTable =>
      ParsedCreateLookupTable(
        getCreateLookupTableInstructionDataDecoder().decode(data),
      ),
    AddressLookupTableInstruction.freezeLookupTable =>
      ParsedFreezeLookupTable(
        getFreezeLookupTableInstructionDataDecoder().decode(data),
      ),
    AddressLookupTableInstruction.extendLookupTable =>
      ParsedExtendLookupTable(
        getExtendLookupTableInstructionDataDecoder().decode(data),
      ),
    AddressLookupTableInstruction.deactivateLookupTable =>
      ParsedDeactivateLookupTable(
        getDeactivateLookupTableInstructionDataDecoder().decode(data),
      ),
    AddressLookupTableInstruction.closeLookupTable =>
      ParsedCloseLookupTable(
        getCloseLookupTableInstructionDataDecoder().decode(data),
      ),
  };
}
