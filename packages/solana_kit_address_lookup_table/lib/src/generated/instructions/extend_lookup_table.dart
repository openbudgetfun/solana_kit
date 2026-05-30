// ignore_for_file: public_member_api_docs

import 'package:meta/meta.dart';
import 'package:solana_kit_address_lookup_table/src/generated/programs/address_lookup_table.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Discriminator value for the ExtendLookupTable instruction.
const extendLookupTableDiscriminator = 2;

/// Data for the ExtendLookupTable instruction.
@immutable
class ExtendLookupTableInstructionData {
  /// Creates [ExtendLookupTableInstructionData].
  const ExtendLookupTableInstructionData({
    required this.addresses,
    this.discriminator = extendLookupTableDiscriminator,
  });

  /// The instruction discriminator (u32).
  final int discriminator;

  /// The list of addresses to add to the lookup table.
  final List<Address> addresses;

  @override
  String toString() =>
      'ExtendLookupTableInstructionData('
      'discriminator: $discriminator, '
      'addresses: $addresses)';

  @override
  bool operator ==(Object other) {
    if (other is! ExtendLookupTableInstructionData) return false;
    if (other.discriminator != discriminator) return false;
    if (other.addresses.length != addresses.length) return false;
    for (var i = 0; i < addresses.length; i++) {
      if (other.addresses[i] != addresses[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(discriminator, Object.hashAll(addresses));
}

/// Returns the encoder for [ExtendLookupTableInstructionData].
///
/// Wire format: u32 LE discriminator + u64 LE address count + N * 32-byte
/// addresses.
Encoder<ExtendLookupTableInstructionData>
getExtendLookupTableInstructionDataEncoder() {
  final discEncoder = getU32Encoder();
  final countEncoder = getU64Encoder();
  final addrEncoder = getAddressEncoder();

  return VariableSizeEncoder<ExtendLookupTableInstructionData>(
    getSizeFromValue: (value) =>
        4 + 8 + value.addresses.length * 32, // disc + count + addrs
    write: (value, bytes, offset) {
      var pos = offset;
      pos = discEncoder.write(value.discriminator, bytes, pos);
      pos = countEncoder.write(
        BigInt.from(value.addresses.length),
        bytes,
        pos,
      );
      for (final addr in value.addresses) {
        pos = addrEncoder.write(addr, bytes, pos);
      }
      return pos;
    },
  );
}

/// Returns the decoder for [ExtendLookupTableInstructionData].
Decoder<ExtendLookupTableInstructionData>
getExtendLookupTableInstructionDataDecoder() {
  final discDecoder = getU32Decoder();
  final countDecoder = getU64Decoder();
  final addrDecoder = getAddressDecoder();

  return VariableSizeDecoder<ExtendLookupTableInstructionData>(
    read: (bytes, offset) {
      var pos = offset;
      final (discriminator, nextPos1) = discDecoder.read(bytes, pos);
      pos = nextPos1;
      final (count, nextPos2) = countDecoder.read(bytes, pos);
      pos = nextPos2;
      final numAddresses = count.toInt();
      final addresses = <Address>[];
      for (var i = 0; i < numAddresses; i++) {
        final (addr, nextPos) = addrDecoder.read(bytes, pos);
        pos = nextPos;
        addresses.add(addr);
      }
      return (
        ExtendLookupTableInstructionData(
          discriminator: discriminator,
          addresses: addresses,
        ),
        pos,
      );
    },
  );
}

/// Returns the codec for [ExtendLookupTableInstructionData].
Codec<ExtendLookupTableInstructionData, ExtendLookupTableInstructionData>
getExtendLookupTableInstructionDataCodec() {
  return combineCodec(
    getExtendLookupTableInstructionDataEncoder(),
    getExtendLookupTableInstructionDataDecoder(),
  );
}

/// Creates an ExtendLookupTable instruction.
///
/// Extends the lookup table at [address] with the given [addresses].
/// The [authority] must sign, and [payer] pays for the reallocation.
Instruction getExtendLookupTableInstruction({
  required Address address,
  required Address authority,
  required Address payer,
  required List<Address> addresses,
  Address programAddress = addressLookupTableProgramAddress,
  Address systemProgramAddress = const Address(
    '11111111111111111111111111111111',
  ),
}) {
  final data = ExtendLookupTableInstructionData(addresses: addresses);
  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: address, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgramAddress, role: AccountRole.readonly),
    ],
    data: getExtendLookupTableInstructionDataEncoder().encode(data),
  );
}

/// Parses an ExtendLookupTable instruction from [instruction].
ExtendLookupTableInstructionData parseExtendLookupTableInstruction(
  Instruction instruction,
) {
  return getExtendLookupTableInstructionDataDecoder().decode(
    instruction.data!,
  );
}
