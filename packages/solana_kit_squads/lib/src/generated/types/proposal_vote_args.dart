// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

@immutable
class ProposalVoteArgs {
  const ProposalVoteArgs({
    required this.memo,
  });

  final String? memo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalVoteArgs &&
          runtimeType == other.runtimeType &&
          memo == other.memo;

  @override
  int get hashCode => memo.hashCode;

  @override
  String toString() => 'ProposalVoteArgs(memo: $memo)';
}

Encoder<ProposalVoteArgs> getProposalVoteArgsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'memo',
      getNullableEncoder<String>(
        addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ProposalVoteArgs value) => <String, Object?>{
      'memo': value.memo,
    },
  );
}

Decoder<ProposalVoteArgs> getProposalVoteArgsDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'memo',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ProposalVoteArgs(
      memo: map['memo'] as String?,
    ),
  );
}

Codec<ProposalVoteArgs, ProposalVoteArgs> getProposalVoteArgsCodec() {
  return combineCodec(
    getProposalVoteArgsEncoder(),
    getProposalVoteArgsDecoder(),
  );
}
