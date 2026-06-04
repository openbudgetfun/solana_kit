// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import '../types/plan_data.dart';

@immutable
class Plan {
  const Plan({
    required this.discriminator,
    required this.owner,
    required this.bump,
    required this.status,
    required this.data,
  });

  final int discriminator;
  final Address owner;
  final int bump;
  final int status;
  final PlanData data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Plan &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          owner == other.owner &&
          bump == other.bump &&
          status == other.status &&
          data == other.data;

  @override
  int get hashCode => Object.hash(discriminator, owner, bump, status, data);

  @override
  String toString() =>
      'Plan(discriminator: $discriminator, owner: $owner, bump: $bump, status: $status, data: $data)';
}

Encoder<Plan> getPlanEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('owner', getAddressEncoder()),
    ('bump', getU8Encoder()),
    ('status', getU8Encoder()),
    ('data', getPlanDataEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Plan value) => <String, Object?>{
      'discriminator': value.discriminator,
      'owner': value.owner,
      'bump': value.bump,
      'status': value.status,
      'data': value.data,
    },
  );
}

Decoder<Plan> getPlanDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('owner', getAddressDecoder()),
    ('bump', getU8Decoder()),
    ('status', getU8Decoder()),
    ('data', getPlanDataDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Plan(
      discriminator: map['discriminator']! as int,
      owner: map['owner']! as Address,
      bump: map['bump']! as int,
      status: map['status']! as int,
      data: map['data']! as PlanData,
    ),
  );
}

Codec<Plan, Plan> getPlanCodec() {
  return combineCodec(getPlanEncoder(), getPlanDecoder());
}

Account<Plan> decodePlan(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getPlanDecoder());
}
