import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_memo/src/constants.dart';

/// A memo extracted from an instruction by [getMemosFromInstructions].
@immutable
class ExtractedMemo {
  /// Creates an extracted memo.
  const ExtractedMemo({
    required this.memo,
    required this.bytes,
    required this.programAddress,
    required this.index,
  });

  /// The UTF-8 decoded memo text. Instructions with no data yield an empty
  /// string.
  final String memo;

  /// The raw, undecoded instruction data. Instructions with no data yield an
  /// empty array.
  final Uint8List bytes;

  /// The address of the Memo program that emitted this memo.
  final Address programAddress;

  /// The index of the source instruction within the list passed to the
  /// helper.
  final int index;
}

/// Extracts every memo from a list of instructions, regardless of which
/// version of the Memo program emitted it.
///
/// The Memo program has been deployed under several addresses over time (see
/// [supportedMemoProgramAddresses]). This helper matches instructions against
/// all of them, so consumers do not need to know about the individual program
/// addresses. Matching instructions are decoded as UTF-8, matching the
/// program's own contract; the original ordering is preserved and each result
/// carries the source program address and instruction index.
///
/// ```dart
/// import 'package:solana_kit_instructions/solana_kit_instructions.dart';
/// import 'package:solana_kit_memo/solana_kit_memo.dart';
///
/// void printMemos(List<Instruction> instructions) {
///   final memos = getMemosFromInstructions(instructions);
///   print(memos.first.memo);
/// }
/// ```
List<ExtractedMemo> getMemosFromInstructions(
  List<Instruction> instructions,
) {
  final decoder = getUtf8Decoder();
  final memos = <ExtractedMemo>[];

  for (final (index, instruction) in instructions.indexed) {
    if (!supportedMemoProgramAddresses.contains(instruction.programAddress)) {
      continue;
    }

    final bytes = instruction.data ?? Uint8List(0);
    memos.add(
      ExtractedMemo(
        memo: decoder.decode(bytes),
        bytes: bytes,
        programAddress: instruction.programAddress,
        index: index,
      ),
    );
  }

  return memos;
}
