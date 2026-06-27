// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


@immutable
class TransferData {
  const TransferData({
    required this.amount,
    required this.delegator,
    required this.mint,
  });

  final BigInt amount;
  final Address delegator;
  final Address mint;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferData &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          delegator == other.delegator &&
          mint == other.mint;

  @override
  int get hashCode => Object.hash(amount, delegator, mint);

  @override
  String toString() => 'TransferData(amount: $amount, delegator: $delegator, mint: $mint)';
}

Encoder<TransferData> getTransferDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('amount', getU64Encoder()),
    ('delegator', getAddressEncoder()),
    ('mint', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferData value) => <String, Object?>{
      'amount': value.amount,
      'delegator': value.delegator,
      'mint': value.mint,
    },
  );
}

Decoder<TransferData> getTransferDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('amount', getU64Decoder()),
    ('delegator', getAddressDecoder()),
    ('mint', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => TransferData(
      amount: map['amount']! as BigInt,
      delegator: map['delegator']! as Address,
      mint: map['mint']! as Address,
    ),
  );
}

Codec<TransferData, TransferData> getTransferDataCodec() {
  return combineCodec(getTransferDataEncoder(), getTransferDataDecoder());
}
