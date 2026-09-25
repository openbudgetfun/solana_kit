import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import 'package:solana_kit_transaction_messages/src/compiled_transaction_message.dart';

/// Returns a variable-size encoder for [AddressTableLookup].
///
/// The lookup is encoded as:
/// - lookupTableAddress: 32 bytes (base58-encoded address)
/// - writableIndexes: shortU16-prefixed array of u8
/// - readonlyIndexes: shortU16-prefixed array of u8
VariableSizeEncoder<AddressTableLookup> getAddressTableLookupEncoder() {
  final addrEnc = getAddressEncoder();
  final shortU16Enc = getShortU16Encoder();
  final indexArrayEnc = getArrayEncoder<num>(
    getU8Encoder(),
    size: PrefixedArraySize(shortU16Enc),
  );

  return VariableSizeEncoder<AddressTableLookup>(
    getSizeFromValue: (lookup) {
      return getEncodedSize(lookup.lookupTableAddress, addrEnc) +
          getEncodedSize(lookup.writableIndexes, indexArrayEnc) +
          getEncodedSize(lookup.readonlyIndexes, indexArrayEnc);
    },
    write: (lookup, bytes, offset) {
      var pos = offset;
      pos = addrEnc.write(lookup.lookupTableAddress, bytes, pos);
      pos = indexArrayEnc.write(lookup.writableIndexes, bytes, pos);
      pos = indexArrayEnc.write(lookup.readonlyIndexes, bytes, pos);
      return pos;
    },
  );
}

/// Returns a variable-size decoder for [AddressTableLookup].
VariableSizeDecoder<AddressTableLookup> getAddressTableLookupDecoder() {
  final addrDec = getAddressDecoder();
  final shortU16Dec = getShortU16Decoder();
  final indexArrayDec = getArrayDecoder<int>(
    getU8Decoder(),
    size: PrefixedArraySize(shortU16Dec),
  );

  return VariableSizeDecoder<AddressTableLookup>(
    read: (bytes, offset) {
      final (lookupTableAddress, o1) = addrDec.read(bytes, offset);
      final (writableIndexes, o2) = indexArrayDec.read(bytes, o1);
      final (readonlyIndexes, o3) = indexArrayDec.read(bytes, o2);
      return (
        AddressTableLookup(
          lookupTableAddress: lookupTableAddress,
          writableIndexes: writableIndexes,
          readonlyIndexes: readonlyIndexes,
        ),
        o3,
      );
    },
  );
}

/// Returns a variable-size codec for [AddressTableLookup].
Codec<AddressTableLookup, AddressTableLookup> getAddressTableLookupCodec() {
  return combineCodec(
    getAddressTableLookupEncoder(),
    getAddressTableLookupDecoder(),
  );
}
