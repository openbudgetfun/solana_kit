import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_transaction_messages/src/codecs/address_table_lookup_codec.dart';
import 'package:solana_kit_transaction_messages/src/codecs/header_codec.dart';
import 'package:solana_kit_transaction_messages/src/codecs/instruction_codec.dart';
import 'package:solana_kit_transaction_messages/src/codecs/transaction_version_codec.dart';
import 'package:solana_kit_transaction_messages/src/compiled_transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/v1_transaction_config.dart';

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
      } else if (message.version == TransactionVersion.v1) {
        return _getV1EncoderSize(message);
      } else {
        return _getVersionedEncoderSize(message);
      }
    },
    write: (message, bytes, offset) {
      if (message.version == TransactionVersion.legacy) {
        return _writeLegacyMessage(message, bytes, offset);
      } else if (message.version == TransactionVersion.v1) {
        return _writeV1Message(message, bytes, offset);
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
      if (version == TransactionVersion.v1) {
        return _readV1Message(bytes, offset);
      }

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

int _getV1EncoderSize(CompiledTransactionMessage message) {
  final configValues =
      message.configValues ?? const <CompiledTransactionConfigValue>[];
  final instructionHeaders =
      message.instructionHeaders ?? const <V1InstructionHeader>[];
  final instructionPayloads =
      message.instructionPayloads ?? const <V1InstructionPayload>[];
  var size = 1 + 3 + 4 + 32 + 1 + 1 + message.staticAccounts.length * 32;
  for (final value in configValues) {
    size += value.kind == 'u64' ? 8 : 4;
  }
  size += instructionHeaders.length * 4;
  for (final payload in instructionPayloads) {
    size +=
        payload.instructionAccountIndices.length +
        payload.instructionData.length;
  }
  return size;
}

int _writeV1Message(
  CompiledTransactionMessage message,
  Uint8List bytes,
  int offset,
) {
  final versionEnc = getTransactionVersionEncoder();
  final headerEnc = getMessageHeaderEncoder();
  final u8Enc = getU8Encoder();
  final u16Enc = getU16Encoder();
  final u32Enc = getU32Encoder();
  final u64Enc = getU64Encoder();
  final addrEnc = getAddressEncoder();
  final lifetimeEnc = _getLifetimeTokenEncoder(message.lifetimeToken);
  final configValues =
      message.configValues ?? const <CompiledTransactionConfigValue>[];
  final instructionHeaders =
      message.instructionHeaders ?? const <V1InstructionHeader>[];
  final instructionPayloads =
      message.instructionPayloads ?? const <V1InstructionPayload>[];

  var pos = offset;
  pos = versionEnc.write(TransactionVersion.v1, bytes, pos);
  pos = headerEnc.write(message.header, bytes, pos);
  pos = u32Enc.write(message.configMask ?? 0, bytes, pos);
  pos = lifetimeEnc.write(message.lifetimeToken, bytes, pos);
  pos = u8Enc.write(
    message.numInstructions ?? instructionHeaders.length,
    bytes,
    pos,
  );
  pos = u8Enc.write(
    message.numStaticAccounts ?? message.staticAccounts.length,
    bytes,
    pos,
  );
  for (final address in message.staticAccounts) {
    pos = addrEnc.write(address, bytes, pos);
  }
  for (final value in configValues) {
    switch (value.kind) {
      case 'u32':
        pos = u32Enc.write(value.value as int, bytes, pos);
      case 'u64':
        pos = u64Enc.write(value.value as BigInt, bytes, pos);
      default:
        throw SolanaError(SolanaErrorCode.transactionInvalidConfigValueKind, {
          'kind': value.kind,
        });
    }
  }
  for (final header in instructionHeaders) {
    pos = u8Enc.write(header.programAccountIndex, bytes, pos);
    pos = u8Enc.write(header.numInstructionAccounts, bytes, pos);
    pos = u16Enc.write(header.numInstructionDataBytes, bytes, pos);
  }
  for (final payload in instructionPayloads) {
    for (final index in payload.instructionAccountIndices) {
      pos = u8Enc.write(index, bytes, pos);
    }
    bytes.setRange(
      pos,
      pos + payload.instructionData.length,
      payload.instructionData,
    );
    pos += payload.instructionData.length;
  }
  return pos;
}

(CompiledTransactionMessage, int) _readV1Message(Uint8List bytes, int offset) {
  final versionDec = getTransactionVersionDecoder();
  final headerDec = getMessageHeaderDecoder();
  final u8Dec = getU8Decoder();
  final u16Dec = getU16Decoder();
  final u32Dec = getU32Decoder();
  final addrDec = getAddressDecoder();
  final lifetimeDec = fixDecoderSize(getBase58Decoder(), 32);

  var (version, pos) = versionDec.read(bytes, offset);
  final (header, o2) = headerDec.read(bytes, pos);
  pos = o2;
  final (configMaskNum, o3) = u32Dec.read(bytes, pos);
  final configMask = configMaskNum;
  pos = o3;
  final (lifetimeToken, o4) = lifetimeDec.read(bytes, pos);
  pos = o4;
  final (numInstructions, o5) = u8Dec.read(bytes, pos);
  pos = o5;
  final (numStaticAccounts, o6) = u8Dec.read(bytes, pos);
  pos = o6;

  final staticAccounts = <Address>[];
  for (var i = 0; i < numStaticAccounts; i++) {
    final (address, next) = addrDec.read(bytes, pos);
    staticAccounts.add(address);
    pos = next;
  }

  final (configValues, afterConfig) = _readV1ConfigValues(
    bytes,
    pos,
    configMask,
  );
  pos = afterConfig;

  final instructionHeaders = <V1InstructionHeader>[];
  for (var i = 0; i < numInstructions; i++) {
    final (programAccountIndex, h1) = u8Dec.read(bytes, pos);
    final (numInstructionAccounts, h2) = u8Dec.read(bytes, h1);
    final (numInstructionDataBytes, h3) = u16Dec.read(bytes, h2);
    instructionHeaders.add(
      V1InstructionHeader(
        programAccountIndex: programAccountIndex,
        numInstructionAccounts: numInstructionAccounts,
        numInstructionDataBytes: numInstructionDataBytes,
      ),
    );
    pos = h3;
  }

  final instructionPayloads = <V1InstructionPayload>[];
  for (final header in instructionHeaders) {
    final accountIndices = <int>[];
    for (var i = 0; i < header.numInstructionAccounts; i++) {
      final (index, next) = u8Dec.read(bytes, pos);
      accountIndices.add(index);
      pos = next;
    }
    final dataEnd = pos + header.numInstructionDataBytes;
    instructionPayloads.add(
      V1InstructionPayload(
        instructionAccountIndices: accountIndices,
        instructionData: Uint8List.fromList(bytes.sublist(pos, dataEnd)),
      ),
    );
    pos = dataEnd;
  }

  return (
    CompiledTransactionMessage(
      version: version,
      header: header,
      staticAccounts: staticAccounts,
      lifetimeToken: lifetimeToken,
      instructions: const [],
      configMask: configMask,
      configValues: configValues,
      instructionHeaders: instructionHeaders,
      instructionPayloads: instructionPayloads,
      numInstructions: numInstructions,
      numStaticAccounts: numStaticAccounts,
    ),
    pos,
  );
}

(List<CompiledTransactionConfigValue>, int) _readV1ConfigValues(
  Uint8List bytes,
  int offset,
  int mask,
) {
  final u32Dec = getU32Decoder();
  final u64Dec = getU64Decoder();
  final values = <CompiledTransactionConfigValue>[];
  var pos = offset;
  if (transactionConfigMaskHasPriorityFee(mask)) {
    final (value, next) = u64Dec.read(bytes, pos);
    values.add(CompiledTransactionConfigValue.u64(value));
    pos = next;
  }
  if (transactionConfigMaskHasComputeUnitLimit(mask)) {
    final (value, next) = u32Dec.read(bytes, pos);
    values.add(CompiledTransactionConfigValue.u32(value));
    pos = next;
  }
  if (transactionConfigMaskHasLoadedAccountsDataSizeLimit(mask)) {
    final (value, next) = u32Dec.read(bytes, pos);
    values.add(CompiledTransactionConfigValue.u32(value));
    pos = next;
  }
  if (transactionConfigMaskHasHeapSize(mask)) {
    final (value, next) = u32Dec.read(bytes, pos);
    values.add(CompiledTransactionConfigValue.u32(value));
    pos = next;
  }
  return (values, pos);
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
