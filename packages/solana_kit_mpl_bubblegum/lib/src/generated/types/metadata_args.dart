// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_bubblegum/src/generated/types/types.dart';

/// MetadataArgs for V1 compressed NFTs.
///
/// This is the on-chain data structure that gets serialized using borsh
/// encoding and hashed into the Merkle tree leaf.
@immutable
class MetadataArgs {
  const MetadataArgs({
    required this.name,
    this.symbol = '',
    required this.uri,
    required this.sellerFeeBasisPoints,
    this.primarySaleHappened = false,
    this.isMutable = true,
    this.editionNonce,
    this.tokenStandard = TokenStandard.nonFungible,
    this.collection,
    this.uses,
    this.tokenProgramVersion = TokenProgramVersion.original,
    required this.creators,
  });

  /// The name of the asset.
  final String name;

  /// The symbol for the asset.
  final String symbol;

  /// URI pointing to JSON representing the asset.
  final String uri;

  /// Royalty basis points that goes to creators in secondary sales (0-10000).
  final int sellerFeeBasisPoints;

  /// Immutable, once flipped, all sales of this metadata are considered secondary.
  final bool primarySaleHappened;

  /// Whether or not the data struct is mutable, default is not.
  final bool isMutable;

  /// Nonce for easy calculation of editions, if present.
  final int? editionNonce;

  /// Token standard. Currently only `NonFungible` is allowed.
  final TokenStandard tokenStandard;

  /// Collection information.
  final Collection? collection;

  /// Uses information.
  final Uses? uses;

  /// Token program version.
  final TokenProgramVersion tokenProgramVersion;

  /// Creators.
  final List<Creator> creators;
}

/// Borsh-encodes a MetadataArgs.
Uint8List encodeMetadataArgs(MetadataArgs args) {
  final buffer = BytesBuilder();

  // Write borsh string (u32 length prefix + UTF-8 bytes)
  _writeBorshString(buffer, args.name);
  _writeBorshString(buffer, args.symbol);
  _writeBorshString(buffer, args.uri);

  // sellerFeeBasisPoints (u16 LE)
  buffer.addByte(args.sellerFeeBasisPoints & 0xFF);
  buffer.addByte((args.sellerFeeBasisPoints >> 8) & 0xFF);

  // primarySaleHappened (bool)
  buffer.addByte(args.primarySaleHappened ? 1 : 0);

  // isMutable (bool)
  buffer.addByte(args.isMutable ? 1 : 0);

  // editionNonce (Option<u8>)
  if (args.editionNonce != null) {
    buffer.addByte(1); // Some
    buffer.addByte(args.editionNonce!);
  } else {
    buffer.addByte(0); // None
  }

  // tokenStandard (Option<u8>)
  buffer.addByte(1); // Some
  buffer.addByte(args.tokenStandard.value);

  // collection (Option<Collection>)
  if (args.collection != null) {
    buffer.addByte(1); // Some
    buffer.addByte(args.collection!.verified ? 1 : 0);
    buffer.add(getAddressEncoder().encode(args.collection!.key));
  } else {
    buffer.addByte(0); // None
  }

  // uses (Option<Uses>)
  if (args.uses != null) {
    buffer.addByte(1); // Some
    buffer.addByte(args.uses!.useMethod.value);
    _writeU64LE(buffer, args.uses!.remaining);
    _writeU64LE(buffer, args.uses!.total);
  } else {
    buffer.addByte(0); // None
  }

  // tokenProgramVersion (u8)
  buffer.addByte(args.tokenProgramVersion.value);

  // creators (Vec<Creator>)
  _writeU32LE(buffer, args.creators.length);
  for (final creator in args.creators) {
    buffer.add(getAddressEncoder().encode(creator.address));
    buffer.addByte(creator.verified ? 1 : 0);
    buffer.addByte(creator.share);
  }

  return buffer.toBytes();
}

/// Borsh-encodes a MetadataArgsV2.
Uint8List encodeMetadataArgsV2({
  required String name,
  required String symbol,
  required String uri,
  required int sellerFeeBasisPoints,
  required bool primarySaleHappened,
  required bool isMutable,
  required int? editionNonce,
  required int tokenStandard,
  required Address? collection,
  required Uses? uses,
  required int tokenProgramVersion,
  required List<Creator> creators,
}) {
  final buffer = BytesBuilder();

  _writeBorshString(buffer, name);
  _writeBorshString(buffer, symbol);
  _writeBorshString(buffer, uri);

  // sellerFeeBasisPoints (u16 LE)
  buffer.addByte(sellerFeeBasisPoints & 0xFF);
  buffer.addByte((sellerFeeBasisPoints >> 8) & 0xFF);

  // primarySaleHappened (bool)
  buffer.addByte(primarySaleHappened ? 1 : 0);

  // isMutable (bool)
  buffer.addByte(isMutable ? 1 : 0);

  // editionNonce (Option<u8>)
  if (editionNonce != null) {
    buffer.addByte(1); // Some
    buffer.addByte(editionNonce);
  } else {
    buffer.addByte(0); // None
  }

  // tokenStandard (Option<u8>)
  buffer.addByte(1); // Some
  buffer.addByte(tokenStandard);

  // collection (Option<Address>)
  if (collection != null) {
    buffer.addByte(1); // Some
    buffer.add(getAddressEncoder().encode(collection));
  } else {
    buffer.addByte(0); // None
  }

  // uses (Option<Uses>)
  if (uses != null) {
    buffer.addByte(1); // Some
    buffer.addByte(uses.useMethod.value);
    _writeU64LE(buffer, uses.remaining);
    _writeU64LE(buffer, uses.total);
  } else {
    buffer.addByte(0); // None
  }

  // tokenProgramVersion (u8)
  buffer.addByte(tokenProgramVersion);

  // creators (Vec<Creator>)
  _writeU32LE(buffer, creators.length);
  for (final creator in creators) {
    buffer.add(getAddressEncoder().encode(creator.address));
    buffer.addByte(creator.verified ? 1 : 0);
    buffer.addByte(creator.share);
  }

  return buffer.toBytes();
}

void _writeBorshString(BytesBuilder buffer, String value) {
  final bytes = utf8.encode(value);
  _writeU32LE(buffer, bytes.length);
  buffer.add(bytes);
}

void _writeU32LE(BytesBuilder buffer, int value) {
  buffer.addByte(value & 0xFF);
  buffer.addByte((value >> 8) & 0xFF);
  buffer.addByte((value >> 16) & 0xFF);
  buffer.addByte((value >> 24) & 0xFF);
}

void _writeU64LE(BytesBuilder buffer, int value) {
  for (var i = 0; i < 8; i++) {
    buffer.addByte((value >> (8 * i)) & 0xFF);
  }
}
