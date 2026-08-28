// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './proof_info.dart';
import './seeds_vec.dart';

sealed class PayloadType {
  const PayloadType();
}

final class PayloadTypePubkey extends PayloadType {
  const PayloadTypePubkey(this.value);

  final Address value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayloadTypePubkey && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PayloadType.Pubkey($value)';
}

final class PayloadTypeSeeds extends PayloadType {
  const PayloadTypeSeeds(this.value);

  final SeedsVec value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayloadTypeSeeds && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PayloadType.Seeds($value)';
}

final class PayloadTypeMerkleProof extends PayloadType {
  const PayloadTypeMerkleProof(this.value);

  final ProofInfo value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayloadTypeMerkleProof && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PayloadType.MerkleProof($value)';
}

final class PayloadTypeNumber extends PayloadType {
  const PayloadTypeNumber(this.value);

  final BigInt value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayloadTypeNumber && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PayloadType.Number($value)';
}

Encoder<PayloadType> getPayloadTypeEncoder() {
  return transformEncoder<Map<String, Object?>, PayloadType>(
    getDiscriminatedUnionEncoder([
      (
        0,
        transformEncoder<Address, Map<String, Object?>>(
          getAddressEncoder(),
          (Map<String, Object?> map) => map['value']! as Address,
        ),
      ),
      (
        1,
        transformEncoder<SeedsVec, Map<String, Object?>>(
          getSeedsVecEncoder(),
          (Map<String, Object?> map) => map['value']! as SeedsVec,
        ),
      ),
      (
        2,
        transformEncoder<ProofInfo, Map<String, Object?>>(
          getProofInfoEncoder(),
          (Map<String, Object?> map) => map['value']! as ProofInfo,
        ),
      ),
      (
        3,
        transformEncoder<BigInt, Map<String, Object?>>(
          getU64Encoder(),
          (Map<String, Object?> map) => map['value']! as BigInt,
        ),
      ),
    ], size: getU8Encoder()),
    (PayloadType value) => switch (value) {
      PayloadTypePubkey(value: final value) => <String, Object?>{
        '__kind': 0,
        'value': value,
      },
      PayloadTypeSeeds(value: final value) => <String, Object?>{
        '__kind': 1,
        'value': value,
      },
      PayloadTypeMerkleProof(value: final value) => <String, Object?>{
        '__kind': 2,
        'value': value,
      },
      PayloadTypeNumber(value: final value) => <String, Object?>{
        '__kind': 3,
        'value': value,
      },
    },
  );
}

Decoder<PayloadType> getPayloadTypeDecoder() {
  return transformDecoder<Map<String, Object?>, PayloadType>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Address, Map<String, Object?>>(
          getAddressDecoder(),
          (Address value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        1,
        transformDecoder<SeedsVec, Map<String, Object?>>(
          getSeedsVecDecoder(),
          (SeedsVec value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        2,
        transformDecoder<ProofInfo, Map<String, Object?>>(
          getProofInfoDecoder(),
          (ProofInfo value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
      (
        3,
        transformDecoder<BigInt, Map<String, Object?>>(
          getU64Decoder(),
          (BigInt value, Uint8List bytes, int offset) => <String, Object?>{
            'value': value,
          },
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return PayloadTypePubkey(map['value']! as Address);
        case 1:
          return PayloadTypeSeeds(map['value']! as SeedsVec);
        case 2:
          return PayloadTypeMerkleProof(map['value']! as ProofInfo);
        case 3:
          return PayloadTypeNumber(map['value']! as BigInt);
      }
      throw StateError(
        'Unsupported PayloadType discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<PayloadType, PayloadType> getPayloadTypeCodec() {
  return combineCodec(getPayloadTypeEncoder(), getPayloadTypeDecoder());
}
