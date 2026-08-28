// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class ProgrammableConfig {
  const ProgrammableConfig();
}

final class ProgrammableConfigV1 extends ProgrammableConfig {
  const ProgrammableConfigV1({
    required this.ruleSet,
  });

  final Address? ruleSet;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgrammableConfigV1 && ruleSet == other.ruleSet;

  @override
  int get hashCode => ruleSet.hashCode;

  @override
  String toString() => 'ProgrammableConfig.V1(ruleSet: $ruleSet)';
}

Encoder<ProgrammableConfig> getProgrammableConfigEncoder() {
  return transformEncoder<Map<String, Object?>, ProgrammableConfig>(
    getDiscriminatedUnionEncoder([
      (
        0,
        getStructEncoder([
          ('ruleSet', getNullableEncoder<Address>(getAddressEncoder())),
        ]),
      ),
    ], size: getU8Encoder()),
    (ProgrammableConfig value) => switch (value) {
      ProgrammableConfigV1(ruleSet: final ruleSet) => <String, Object?>{
        '__kind': 0,
        'ruleSet': ruleSet,
      },
    },
  );
}

Decoder<ProgrammableConfig> getProgrammableConfigDecoder() {
  return transformDecoder<Map<String, Object?>, ProgrammableConfig>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('ruleSet', getNullableDecoder<Address>(getAddressDecoder())),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return ProgrammableConfigV1(ruleSet: map['ruleSet'] as Address?);
      }
      throw StateError(
        'Unsupported ProgrammableConfig discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<ProgrammableConfig, ProgrammableConfig> getProgrammableConfigCodec() {
  return combineCodec(
    getProgrammableConfigEncoder(),
    getProgrammableConfigDecoder(),
  );
}
