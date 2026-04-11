// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_compute_budget/src/generated/programs/compute_budget.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Discriminator byte for the RequestHeapFrame instruction.
const requestHeapFrameDiscriminator = 1;

/// Data for the RequestHeapFrame instruction.
@immutable
class RequestHeapFrameInstructionData {
  /// Creates [RequestHeapFrameInstructionData].
  const RequestHeapFrameInstructionData({
    required this.bytes, this.discriminator = requestHeapFrameDiscriminator,
  });

  /// The instruction discriminator byte.
  final int discriminator;

  /// Requested transaction-wide program heap size in bytes.
  ///
  /// Must be a multiple of 1024. Applies to each program, including CPIs.
  final int bytes;

  @override
  String toString() =>
      'RequestHeapFrameInstructionData('
      'discriminator: $discriminator, '
      'bytes: $bytes)';

  @override
  bool operator ==(Object other) =>
      other is RequestHeapFrameInstructionData &&
      other.discriminator == discriminator &&
      other.bytes == bytes;

  @override
  int get hashCode => Object.hash(discriminator, bytes);
}

/// Returns the encoder for [RequestHeapFrameInstructionData].
Encoder<RequestHeapFrameInstructionData>
getRequestHeapFrameInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('bytes', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RequestHeapFrameInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'bytes': value.bytes,
    },
  );
}

/// Returns the decoder for [RequestHeapFrameInstructionData].
Decoder<RequestHeapFrameInstructionData>
getRequestHeapFrameInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('bytes', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        RequestHeapFrameInstructionData(
          discriminator: map['discriminator']! as int,
          bytes: map['bytes']! as int,
        ),
  );
}

/// Returns the codec for [RequestHeapFrameInstructionData].
Codec<RequestHeapFrameInstructionData, RequestHeapFrameInstructionData>
getRequestHeapFrameInstructionDataCodec() {
  return combineCodec(
    getRequestHeapFrameInstructionDataEncoder(),
    getRequestHeapFrameInstructionDataDecoder(),
  );
}

/// Creates a RequestHeapFrame instruction.
///
/// Requests a specific heap frame size (in [bytes]) for the transaction.
/// Must be a multiple of 1024.
Instruction getRequestHeapFrameInstruction({
  required int bytes,
  Address programAddress = computeBudgetProgramAddress,
}) {
  final data = RequestHeapFrameInstructionData(bytes: bytes);
  return Instruction(
    programAddress: programAddress,
    accounts: const [],
    data: getRequestHeapFrameInstructionDataEncoder().encode(data),
  );
}

/// Parses a RequestHeapFrame instruction from [instruction].
RequestHeapFrameInstructionData parseRequestHeapFrameInstruction(
  Instruction instruction,
) {
  return getRequestHeapFrameInstructionDataDecoder().decode(instruction.data!);
}
