// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class Header {
  const Header({
    required this.discriminator,
    required this.version,
    required this.bump,
    required this.delegator,
    required this.delegatee,
    required this.payer,
    required this.initId,
  });

  final int discriminator;
  final int version;
  final int bump;
  final Address delegator;
  final Address delegatee;
  final Address payer;
  final BigInt initId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Header &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          version == other.version &&
          bump == other.bump &&
          delegator == other.delegator &&
          delegatee == other.delegatee &&
          payer == other.payer &&
          initId == other.initId;

  @override
  int get hashCode => Object.hash(
    discriminator,
    version,
    bump,
    delegator,
    delegatee,
    payer,
    initId,
  );

  @override
  String toString() =>
      'Header(discriminator: $discriminator, version: $version, bump: $bump, delegator: $delegator, delegatee: $delegatee, payer: $payer, initId: $initId)';
}

Encoder<Header> getHeaderEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('version', getU8Encoder()),
    ('bump', getU8Encoder()),
    ('delegator', getAddressEncoder()),
    ('delegatee', getAddressEncoder()),
    ('payer', getAddressEncoder()),
    ('initId', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Header value) => <String, Object?>{
      'discriminator': value.discriminator,
      'version': value.version,
      'bump': value.bump,
      'delegator': value.delegator,
      'delegatee': value.delegatee,
      'payer': value.payer,
      'initId': value.initId,
    },
  );
}

Decoder<Header> getHeaderDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('version', getU8Decoder()),
    ('bump', getU8Decoder()),
    ('delegator', getAddressDecoder()),
    ('delegatee', getAddressDecoder()),
    ('payer', getAddressDecoder()),
    ('initId', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Header(
      discriminator: map['discriminator']! as int,
      version: map['version']! as int,
      bump: map['bump']! as int,
      delegator: map['delegator']! as Address,
      delegatee: map['delegatee']! as Address,
      payer: map['payer']! as Address,
      initId: map['initId']! as BigInt,
    ),
  );
}

Codec<Header, Header> getHeaderCodec() {
  return combineCodec(getHeaderEncoder(), getHeaderDecoder());
}
