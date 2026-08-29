/// Decoding of SPL Name Service name-registry accounts.
///
/// A name registry (the account type created by the SPL Name Service program)
/// stores a 96-byte header of three 32-byte addresses — parent name account,
/// owner, and class — followed by an optional, program-defined data section.
///
/// The layout mirrors `RegistryState` from the TypeScript SDK
/// (`js-kit/src/states/registry.ts`).
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

/// The byte length of the fixed name-registry header.
///
/// Three 32-byte addresses (`parentName`, `owner`, `class`) stored
/// contiguously at the start of the account data.
const nameRegistryHeaderLength = 96;

/// The decoded state of an SPL Name Service name-registry account.
class NameRegistryState {
  /// Creates a registry state.
  NameRegistryState({
    required this.parentName,
    required this.owner,
    required this.registryClass,
    Uint8List? data,
  }) : data = data ?? Uint8List(0);

  /// The parent name account, or the zero address for top-level domains.
  final Address parentName;

  /// The owner of the name account.
  final Address owner;

  /// The class of the name account, or the zero address when unset.
  final Address registryClass;

  /// The data section following the 96-byte header.
  ///
  /// For reverse-lookup accounts this holds a length-prefixed name (see
  /// [getNameValueCodec]); for record accounts it holds the record payload.
  final Uint8List data;

  /// Returns `true` when the account carries a non-empty data section.
  bool get hasData => data.isNotEmpty;
}

/// Returns the encoder for a name-registry account: a 96-byte header
/// ([NameRegistryState.parentName], [NameRegistryState.owner],
/// [NameRegistryState.registryClass]) followed by [NameRegistryState.data].
VariableSizeEncoder<NameRegistryState> getNameRegistryStateEncoder() {
  final headerEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('parentName', fixEncoderSize(getBytesEncoder(), 32)),
    ('owner', fixEncoderSize(getBytesEncoder(), 32)),
    ('class', fixEncoderSize(getBytesEncoder(), 32)),
  ]);

  return VariableSizeEncoder<NameRegistryState>(
    getSizeFromValue: (value) => nameRegistryHeaderLength + value.data.length,
    write: (value, bytes, offset) {
      final currentOffset = headerEncoder.write(
        <String, Object?>{
          'parentName': getAddressEncoder().encode(value.parentName),
          'owner': getAddressEncoder().encode(value.owner),
          'class': getAddressEncoder().encode(value.registryClass),
        },
        bytes,
        offset,
      );
      bytes.setRange(
        currentOffset,
        currentOffset + value.data.length,
        value.data,
      );
      return currentOffset + value.data.length;
    },
  );
}

/// Returns the decoder for a name-registry account.
///
/// The first 96 bytes are decoded as the header and every remaining byte is
/// exposed through [NameRegistryState.data], mirroring the TypeScript SDK's
/// `RegistryState.deserialize`.
VariableSizeDecoder<NameRegistryState> getNameRegistryStateDecoder() {
  final headerDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('parentName', fixDecoderSize(getBytesDecoder(), 32)),
    ('owner', fixDecoderSize(getBytesDecoder(), 32)),
    ('class', fixDecoderSize(getBytesDecoder(), 32)),
  ]);
  final addressDecoder = getAddressDecoder();

  return VariableSizeDecoder<NameRegistryState>(
    read: (bytes, offset) {
      final (header, headerEnd) = headerDecoder.read(bytes, offset);
      final state = NameRegistryState(
        parentName: addressDecoder.decode(header['parentName']! as Uint8List),
        owner: addressDecoder.decode(header['owner']! as Uint8List),
        registryClass: addressDecoder.decode(header['class']! as Uint8List),
        data: bytes.sublist(headerEnd),
      );
      return (state, bytes.length);
    },
  );
}

/// Returns the codec for a name-registry account.
VariableSizeCodec<NameRegistryState, NameRegistryState>
getNameRegistryStateCodec() {
  return combineCodec(
        getNameRegistryStateEncoder(),
        getNameRegistryStateDecoder(),
      )
      as VariableSizeCodec<NameRegistryState, NameRegistryState>;
}

/// Returns a codec for a length-prefixed UTF-8 string.
///
/// The value is encoded as a little-endian u32 byte length followed by the
/// UTF-8 bytes of the string. This is the data format of reverse-lookup
/// accounts and corresponds to borsh `string` encoding.
///
/// Leading NUL bytes are preserved: subdomain reverse records intentionally
/// start their name with `\x00`.
VariableSizeCodec<String, String> getNameValueCodec() {
  final utf8Codec = getUtf8Codec();

  return VariableSizeCodec<String, String>(
    getSizeFromValue: (value) => 4 + utf8Codec.getSizeFromValue(value),
    write: (value, bytes, offset) {
      final encoded = utf8Codec.encode(value);
      final currentOffset = getU32Encoder().write(
        encoded.length,
        bytes,
        offset,
      );
      final end = currentOffset + encoded.length;
      bytes.setRange(currentOffset, end, encoded);
      return end;
    },
    read: (bytes, offset) {
      final (length, afterLength) = getU32Decoder().read(bytes, offset);
      final start = afterLength;
      final end = start + length;
      if (end > bytes.length) {
        throw ArgumentError('Name value length $length exceeds input bytes');
      }
      final (value, _) = utf8Codec.read(bytes.sublist(0, end), start);
      return (value, end);
    },
  );
}

/// Encodes [value] as a u32-length-prefixed UTF-8 byte array.
Uint8List encodeNameValue(String value) => getNameValueCodec().encode(value);

/// Decodes a u32-length-prefixed UTF-8 byte array into a string.
String decodeNameValue(Uint8List bytes) => getNameValueCodec().decode(bytes);
