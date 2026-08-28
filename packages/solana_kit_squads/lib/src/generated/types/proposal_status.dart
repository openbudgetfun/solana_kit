// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

sealed class ProposalStatus {
  const ProposalStatus();
}

final class ProposalStatusDraft extends ProposalStatus {
  const ProposalStatusDraft({
    required this.timestamp,
  });

  final BigInt timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalStatusDraft && timestamp == other.timestamp;

  @override
  int get hashCode => timestamp.hashCode;

  @override
  String toString() => 'ProposalStatus.Draft(timestamp: $timestamp)';
}

final class ProposalStatusActive extends ProposalStatus {
  const ProposalStatusActive({
    required this.timestamp,
  });

  final BigInt timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalStatusActive && timestamp == other.timestamp;

  @override
  int get hashCode => timestamp.hashCode;

  @override
  String toString() => 'ProposalStatus.Active(timestamp: $timestamp)';
}

final class ProposalStatusRejected extends ProposalStatus {
  const ProposalStatusRejected({
    required this.timestamp,
  });

  final BigInt timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalStatusRejected && timestamp == other.timestamp;

  @override
  int get hashCode => timestamp.hashCode;

  @override
  String toString() => 'ProposalStatus.Rejected(timestamp: $timestamp)';
}

final class ProposalStatusApproved extends ProposalStatus {
  const ProposalStatusApproved({
    required this.timestamp,
  });

  final BigInt timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalStatusApproved && timestamp == other.timestamp;

  @override
  int get hashCode => timestamp.hashCode;

  @override
  String toString() => 'ProposalStatus.Approved(timestamp: $timestamp)';
}

final class ProposalStatusExecuting extends ProposalStatus {
  const ProposalStatusExecuting();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProposalStatusExecuting;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ProposalStatus.Executing()';
}

final class ProposalStatusExecuted extends ProposalStatus {
  const ProposalStatusExecuted({
    required this.timestamp,
  });

  final BigInt timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalStatusExecuted && timestamp == other.timestamp;

  @override
  int get hashCode => timestamp.hashCode;

  @override
  String toString() => 'ProposalStatus.Executed(timestamp: $timestamp)';
}

final class ProposalStatusCancelled extends ProposalStatus {
  const ProposalStatusCancelled({
    required this.timestamp,
  });

  final BigInt timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalStatusCancelled && timestamp == other.timestamp;

  @override
  int get hashCode => timestamp.hashCode;

  @override
  String toString() => 'ProposalStatus.Cancelled(timestamp: $timestamp)';
}

Encoder<ProposalStatus> getProposalStatusEncoder() {
  return transformEncoder<Map<String, Object?>, ProposalStatus>(
    getDiscriminatedUnionEncoder([
      (0, getStructEncoder([('timestamp', getI64Encoder())])),
      (1, getStructEncoder([('timestamp', getI64Encoder())])),
      (2, getStructEncoder([('timestamp', getI64Encoder())])),
      (3, getStructEncoder([('timestamp', getI64Encoder())])),
      (4, getStructEncoder(<(String, Encoder<Object?>)>[])),
      (5, getStructEncoder([('timestamp', getI64Encoder())])),
      (6, getStructEncoder([('timestamp', getI64Encoder())])),
    ], size: getU8Encoder()),
    (ProposalStatus value) => switch (value) {
      ProposalStatusDraft(timestamp: final timestamp) => <String, Object?>{
        '__kind': 0,
        'timestamp': timestamp,
      },
      ProposalStatusActive(timestamp: final timestamp) => <String, Object?>{
        '__kind': 1,
        'timestamp': timestamp,
      },
      ProposalStatusRejected(timestamp: final timestamp) => <String, Object?>{
        '__kind': 2,
        'timestamp': timestamp,
      },
      ProposalStatusApproved(timestamp: final timestamp) => <String, Object?>{
        '__kind': 3,
        'timestamp': timestamp,
      },
      ProposalStatusExecuting() => <String, Object?>{'__kind': 4},
      ProposalStatusExecuted(timestamp: final timestamp) => <String, Object?>{
        '__kind': 5,
        'timestamp': timestamp,
      },
      ProposalStatusCancelled(timestamp: final timestamp) => <String, Object?>{
        '__kind': 6,
        'timestamp': timestamp,
      },
    },
  );
}

Decoder<ProposalStatus> getProposalStatusDecoder() {
  return transformDecoder<Map<String, Object?>, ProposalStatus>(
    getDiscriminatedUnionDecoder([
      (
        0,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('timestamp', getI64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        1,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('timestamp', getI64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        2,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('timestamp', getI64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        3,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('timestamp', getI64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        4,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder(<(String, Decoder<Object?>)>[]),
          (Map<String, Object?> map, Uint8List bytes, int offset) =>
              <String, Object?>{},
        ),
      ),
      (
        5,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('timestamp', getI64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
      (
        6,
        transformDecoder<Map<String, Object?>, Map<String, Object?>>(
          getStructDecoder([('timestamp', getI64Decoder())]),
          (Map<String, Object?> map, Uint8List bytes, int offset) => map,
        ),
      ),
    ], size: getU8Decoder()),
    (Map<String, Object?> map, Uint8List bytes, int offset) {
      switch (map['__kind']) {
        case 0:
          return ProposalStatusDraft(timestamp: map['timestamp']! as BigInt);
        case 1:
          return ProposalStatusActive(timestamp: map['timestamp']! as BigInt);
        case 2:
          return ProposalStatusRejected(timestamp: map['timestamp']! as BigInt);
        case 3:
          return ProposalStatusApproved(timestamp: map['timestamp']! as BigInt);
        case 4:
          return const ProposalStatusExecuting();
        case 5:
          return ProposalStatusExecuted(timestamp: map['timestamp']! as BigInt);
        case 6:
          return ProposalStatusCancelled(
            timestamp: map['timestamp']! as BigInt,
          );
      }
      throw StateError(
        'Unsupported ProposalStatus discriminator: ${map['__kind']}',
      );
    },
  );
}

Codec<ProposalStatus, ProposalStatus> getProposalStatusCodec() {
  return combineCodec(getProposalStatusEncoder(), getProposalStatusDecoder());
}
