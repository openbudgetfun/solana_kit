// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


@immutable
class TransferFee {
  const TransferFee({
    required this.epoch,
    required this.maximumFee,
    required this.transferFeeBasisPoints,
  });

  final BigInt epoch;
  final BigInt maximumFee;
  final int transferFeeBasisPoints;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferFee &&
          runtimeType == other.runtimeType &&
          epoch == other.epoch &&
          maximumFee == other.maximumFee &&
          transferFeeBasisPoints == other.transferFeeBasisPoints;

  @override
  int get hashCode => Object.hash(epoch, maximumFee, transferFeeBasisPoints);

  @override
  String toString() => 'TransferFee(epoch: $epoch, maximumFee: $maximumFee, transferFeeBasisPoints: $transferFeeBasisPoints)';
}

Encoder<TransferFee> getTransferFeeEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('epoch', getU64Encoder()),
    ('maximumFee', getU64Encoder()),
    ('transferFeeBasisPoints', getU16Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferFee value) => <String, Object?>{
      'epoch': value.epoch,
      'maximumFee': value.maximumFee,
      'transferFeeBasisPoints': value.transferFeeBasisPoints,
    },
  );
}

Decoder<TransferFee> getTransferFeeDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('epoch', getU64Decoder()),
    ('maximumFee', getU64Decoder()),
    ('transferFeeBasisPoints', getU16Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => TransferFee(
      epoch: map['epoch']! as BigInt,
      maximumFee: map['maximumFee']! as BigInt,
      transferFeeBasisPoints: map['transferFeeBasisPoints']! as int,
    ),
  );
}

Codec<TransferFee, TransferFee> getTransferFeeCodec() {
  return combineCodec(getTransferFeeEncoder(), getTransferFeeDecoder());
}
