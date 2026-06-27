// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import './plan_terms.dart';

@immutable
class PlanData {
  const PlanData({
    required this.planId,
    required this.mint,
    required this.terms,
    required this.endTs,
    required this.destinations,
    required this.pullers,
    required this.metadataUri,
  });

  final BigInt planId;
  final Address mint;
  final PlanTerms terms;
  final BigInt endTs;
  final List<Address> destinations;
  final List<Address> pullers;
  final String metadataUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanData &&
          runtimeType == other.runtimeType &&
          planId == other.planId &&
          mint == other.mint &&
          terms == other.terms &&
          endTs == other.endTs &&
          destinations == other.destinations &&
          pullers == other.pullers &&
          metadataUri == other.metadataUri;

  @override
  int get hashCode => Object.hash(
    planId,
    mint,
    terms,
    endTs,
    destinations,
    pullers,
    metadataUri,
  );

  @override
  String toString() =>
      'PlanData(planId: $planId, mint: $mint, terms: $terms, endTs: $endTs, destinations: $destinations, pullers: $pullers, metadataUri: $metadataUri)';
}

Encoder<PlanData> getPlanDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('planId', getU64Encoder()),
    ('mint', getAddressEncoder()),
    ('terms', getPlanTermsEncoder()),
    ('endTs', getI64Encoder()),
    (
      'destinations',
      getArrayEncoder(getAddressEncoder(), size: FixedArraySize(4)),
    ),
    ('pullers', getArrayEncoder(getAddressEncoder(), size: FixedArraySize(4))),
    ('metadataUri', fixEncoderSize(getUtf8Encoder(), 128)),
  ]);

  return transformEncoder(
    structEncoder,
    (PlanData value) => <String, Object?>{
      'planId': value.planId,
      'mint': value.mint,
      'terms': value.terms,
      'endTs': value.endTs,
      'destinations': value.destinations,
      'pullers': value.pullers,
      'metadataUri': value.metadataUri,
    },
  );
}

Decoder<PlanData> getPlanDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('planId', getU64Decoder()),
    ('mint', getAddressDecoder()),
    ('terms', getPlanTermsDecoder()),
    ('endTs', getI64Decoder()),
    (
      'destinations',
      getArrayDecoder(getAddressDecoder(), size: FixedArraySize(4)),
    ),
    ('pullers', getArrayDecoder(getAddressDecoder(), size: FixedArraySize(4))),
    ('metadataUri', fixDecoderSize(getUtf8Decoder(), 128)),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => PlanData(
      planId: map['planId']! as BigInt,
      mint: map['mint']! as Address,
      terms: map['terms']! as PlanTerms,
      endTs: map['endTs']! as BigInt,
      destinations: map['destinations']! as List<Address>,
      pullers: map['pullers']! as List<Address>,
      metadataUri: map['metadataUri']! as String,
    ),
  );
}

Codec<PlanData, PlanData> getPlanDataCodec() {
  return combineCodec(getPlanDataEncoder(), getPlanDataDecoder());
}
