import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import 'package:solana_kit_transaction_messages/src/codecs/address_table_lookup_codec.dart';
import 'package:solana_kit_transaction_messages/src/codecs/header_codec.dart';
import 'package:solana_kit_transaction_messages/src/codecs/instruction_codec.dart';
import 'package:solana_kit_transaction_messages/src/codecs/transaction_version_codec.dart';
import 'package:solana_kit_transaction_messages/src/compiled_transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// Returns an encoder that you can use to encode a
/// [CompiledTransactionMessage] to a byte array.
///
/// The wire format of a Solana transaction consists of signatures followed by
/// a compiled transaction message. The byte array produced by this encoder is
/// the message part.
VariableSizeEncoder<CompiledTransactionMessage>
getCompiledTransactionMessageEncoder() {
  return VariableSizeEncoder<CompiledTransactionMessage>(
    getSizeFromValue: (message) {
      if (message.version == TransactionVersion.legacy) {
        return _getLegacyEncoderSize(message);
      } else {
        return _getVersionedEncoderSize(message);
      }
    },
    write: (message, bytes, offset) {
      if (message.version == TransactionVersion.legacy) {
        return _writeLegacyMessage(message, bytes, offset);
      } else {
        return _writeVersionedMessage(message, bytes, offset);
      }
    },
  );
}

/// Returns a decoder that you can use to decode a byte array representing a
/// [CompiledTransactionMessage].
///
/// The wire format of a Solana transaction consists of signatures followed by
/// a compiled transaction message. You can use this decoder to decode the
/// message part.
VariableSizeDecoder<CompiledTransactionMessage>
getCompiledTransactionMessageDecoder() {
  return VariableSizeDecoder<CompiledTransactionMessage>(
    read: (bytes, offset) {
      final versionDec = getTransactionVersionDecoder();
      final headerDec = getMessageHeaderDecoder();
      final shortU16Dec = getShortU16Decoder();
      final addrDec = getAddressDecoder();
      final lifetimeDec = fixDecoderSize(getBase58Decoder(), 32);
      final instructionDec = getInstructionDecoder();
      final lookupDec = getAddressTableLookupDecoder();

      // Decode version.
      final (version, o1) = versionDec.read(bytes, offset);

      // Decode header.
      final (header, o2) = headerDec.read(bytes, o1);

      // Decode static accounts.
      final accountArrayDec = getArrayDecoder<Address>(
        addrDec,
        size: PrefixedArraySize(shortU16Dec),
      );
      final (staticAccounts, o3) = accountArrayDec.read(bytes, o2);

      // Decode lifetime token.
      final (lifetimeToken, o4) = lifetimeDec.read(bytes, o3);

      // Decode instructions.
      final instructionArrayDec = getArrayDecoder<CompiledInstruction>(
        instructionDec,
        size: PrefixedArraySize(shortU16Dec),
      );
      final (instructions, o5) = instructionArrayDec.read(bytes, o4);

      // Decode address table lookups (present for all messages in the wire
      // format, but semantically only meaningful for versioned messages).
      List<AddressTableLookup>? addressTableLookups;
      var finalOffset = o5;
      if (o5 < bytes.length) {
        final lookupArrayDec = getArrayDecoder<AddressTableLookup>(
          lookupDec,
          size: PrefixedArraySize(shortU16Dec),
        );
        final (lookups, o6) = lookupArrayDec.read(bytes, o5);
        finalOffset = o6;
        if (version != TransactionVersion.legacy && lookups.isNotEmpty) {
          addressTableLookups = lookups;
        }
      }

      return (
        CompiledTransactionMessage(
          version: version,
          header: header,
          staticAccounts: staticAccounts,
          lifetimeToken: lifetimeToken,
          instructions: instructions,
          addressTableLookups: addressTableLookups,
        ),
        finalOffset,
      );
    },
  );
}

/// Returns a codec that you can use to encode from or decode to
/// [CompiledTransactionMessage].
///
/// See [getCompiledTransactionMessageDecoder] and
/// [getCompiledTransactionMessageEncoder].
Codec<CompiledTransactionMessage, CompiledTransactionMessage>
getCompiledTransactionMessageCodec() {
  return combineCodec(
    getCompiledTransactionMessageEncoder(),
    getCompiledTransactionMessageDecoder(),
  );
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

int _getLegacyEncoderSize(CompiledTransactionMessage message) {
  final versionEnc = getTransactionVersionEncoder();
  final headerEnc = getMessageHeaderEncoder();
  final addrEnc = getAddressEncoder();
  final shortU16Enc = getShortU16Encoder();
  final lifetimeEnc = _getLifetimeTokenEncoder(message.lifetimeToken);
  final instructionEnc = getInstructionEncoder();

  final accountArrayEnc = getArrayEncoder<Address>(
    addrEnc,
    size: PrefixedArraySize(shortU16Enc),
  );
  final instructionArrayEnc = getArrayEncoder<CompiledInstruction>(
    instructionEnc,
    size: PrefixedArraySize(shortU16Enc),
  );

  return getEncodedSize(message.version, versionEnc) +
      getEncodedSize(message.header, headerEnc) +
      getEncodedSize(message.staticAccounts, accountArrayEnc) +
      getEncodedSize(message.lifetimeToken, lifetimeEnc) +
      getEncodedSize(message.instructions, instructionArrayEnc);
}

int _getVersionedEncoderSize(CompiledTransactionMessage message) {
  final lookupEnc = getAddressTableLookupEncoder();
  final shortU16Enc = getShortU16Encoder();
  final lookupArrayEnc = getArrayEncoder<AddressTableLookup>(
    lookupEnc,
    size: PrefixedArraySize(shortU16Enc),
  );
  final lookups = message.addressTableLookups ?? const <AddressTableLookup>[];

  return _getLegacyEncoderSize(message) +
      getEncodedSize(lookups, lookupArrayEnc);
}

int _writeLegacyMessage(
  CompiledTransactionMessage message,
  Uint8List bytes,
  int offset,
) {
  final versionEnc = getTransactionVersionEncoder();
  final headerEnc = getMessageHeaderEncoder();
  final addrEnc = getAddressEncoder();
  final shortU16Enc = getShortU16Encoder();
  final lifetimeEnc = _getLifetimeTokenEncoder(message.lifetimeToken);
  final instructionEnc = getInstructionEncoder();

  final accountArrayEnc = getArrayEncoder<Address>(
    addrEnc,
    size: PrefixedArraySize(shortU16Enc),
  );
  final instructionArrayEnc = getArrayEncoder<CompiledInstruction>(
    instructionEnc,
    size: PrefixedArraySize(shortU16Enc),
  );

  var pos = offset;
  pos = versionEnc.write(message.version, bytes, pos);
  pos = headerEnc.write(message.header, bytes, pos);
  pos = accountArrayEnc.write(message.staticAccounts, bytes, pos);
  pos = lifetimeEnc.write(message.lifetimeToken, bytes, pos);
  pos = instructionArrayEnc.write(message.instructions, bytes, pos);
  return pos;
}

int _writeVersionedMessage(
  CompiledTransactionMessage message,
  Uint8List bytes,
  int offset,
) {
  final lookupEnc = getAddressTableLookupEncoder();
  final shortU16Enc = getShortU16Encoder();
  final lookupArrayEnc = getArrayEncoder<AddressTableLookup>(
    lookupEnc,
    size: PrefixedArraySize(shortU16Enc),
  );
  final lookups = message.addressTableLookups ?? const <AddressTableLookup>[];

  return lookupArrayEnc.write(
    lookups,
    bytes,
    _writeLegacyMessage(message, bytes, offset),
  );
}

/// Returns an encoder for the lifetime token field.
///
/// When the lifetime token is null, writes 32 zero bytes (constant).
/// When present, writes the base58-decoded 32 bytes.
Encoder<String?> _getLifetimeTokenEncoder(String? token) {
  if (token == null) {
    final constantEnc = getConstantEncoder(Uint8List(32));
    return FixedSizeEncoder<String?>(
      fixedSize: 32,
      write: (_, bytes, offset) => constantEnc.write(null, bytes, offset),
    );
  }
  final base58Enc = fixEncoderSize(getBase58Encoder(), 32);
  return FixedSizeEncoder<String?>(
    fixedSize: 32,
    write: (value, bytes, offset) => base58Enc.write(value!, bytes, offset),
  );
}
