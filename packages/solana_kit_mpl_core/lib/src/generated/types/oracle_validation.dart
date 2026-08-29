// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './external_validation_result.dart';

sealed class OracleValidation {
  const OracleValidation();
}

final class OracleValidationUninitialized extends OracleValidation {
  const OracleValidationUninitialized();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OracleValidationUninitialized;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'OracleValidation.Uninitialized()';
}

final class OracleValidationV1 extends OracleValidation {
  const OracleValidationV1({
    required this.create,
    required this.transfer,
    required this.burn,
    required this.update,
  });

  final ExternalValidationResult create;
  final ExternalValidationResult transfer;
  final ExternalValidationResult burn;
  final ExternalValidationResult update;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OracleValidationV1 &&
          create == other.create &&
          transfer == other.transfer &&
          burn == other.burn &&
          update == other.update;

  @override
  int get hashCode => Object.hash(create, transfer, burn, update);

  @override
  String toString() =>
      'OracleValidation.V1(create: $create, transfer: $transfer, burn: $burn, update: $update)';
}

Encoder<OracleValidation> getOracleValidationEncoder() {
  return transformEncoder<Map<String, Object?>, OracleValidation>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (
        1,
        getStructEncoder([
          ('create', getExternalValidationResultEncoder()),
          ('transfer', getExternalValidationResultEncoder()),
          ('burn', getExternalValidationResultEncoder()),
          ('update', getExternalValidationResultEncoder()),
        ]),
      ),
    ], size: getU8Encoder()),
    (OracleValidation value) => switch (value) {
      OracleValidationUninitialized() => <String, Object?>{'__kind': 0},
      OracleValidationV1(
        create: final create,
        transfer: final transfer,
        burn: final burn,
        update: final update,
      ) =>
        <String, Object?>{
          '__kind': 1,
          'create': create,
          'transfer': transfer,
          'burn': burn,
          'update': update,
        },
    },
  );
}

Decoder<OracleValidation> getOracleValidationDecoder() {
  return transformDecoder<Map<String, Object?>, OracleValidation>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
      (
        1,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([
            ('create', getExternalValidationResultDecoder()),
            ('transfer', getExternalValidationResultDecoder()),
            ('burn', getExternalValidationResultDecoder()),
            ('update', getExternalValidationResultDecoder()),
          ]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return const OracleValidationUninitialized();
        case 1:
          return OracleValidationV1(
            create: map['create']! as ExternalValidationResult,
            transfer: map['transfer']! as ExternalValidationResult,
            burn: map['burn']! as ExternalValidationResult,
            update: map['update']! as ExternalValidationResult,
          );
      }
      throw StateError(
        'Unsupported OracleValidation discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<OracleValidation, OracleValidation> getOracleValidationCodec() {
  return combineCodec(
    getOracleValidationEncoder(),
    getOracleValidationDecoder(),
  );
}
