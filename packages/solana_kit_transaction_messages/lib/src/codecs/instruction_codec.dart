import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import 'package:solana_kit_transaction_messages/src/compiled_transaction_message.dart';

/// Returns a variable-size encoder for [CompiledInstruction].
///
/// The instruction is encoded as:
/// - programAddressIndex: u8
/// - accountIndices: shortU16-prefixed array of u8
/// - data: shortU16-prefixed byte array
VariableSizeEncoder<CompiledInstruction> getInstructionEncoder() {
  final u8Enc = getU8Encoder();
  final shortU16Enc = getShortU16Encoder();
  final arrayEnc = getArrayEncoder<num>(
    u8Enc,
    size: PrefixedArraySize(shortU16Enc),
  );
  final bytesEnc = addEncoderSizePrefix(getBytesEncoder(), shortU16Enc);

  return VariableSizeEncoder<CompiledInstruction>(
    getSizeFromValue: (instruction) {
      final accountIndices = instruction.accountIndices ?? const <int>[];
      final data = instruction.data ?? Uint8List(0);
      return getEncodedSize(instruction.programAddressIndex, u8Enc) +
          getEncodedSize(accountIndices, arrayEnc) +
          getEncodedSize(data, bytesEnc);
    },
    write: (instruction, bytes, offset) {
      var pos = offset;
      pos = u8Enc.write(instruction.programAddressIndex, bytes, pos);
      pos = arrayEnc.write(
        instruction.accountIndices ?? const <int>[],
        bytes,
        pos,
      );
      pos = bytesEnc.write(instruction.data ?? Uint8List(0), bytes, pos);
      return pos;
    },
  );
}

/// Returns a variable-size decoder for [CompiledInstruction].
///
/// Decodes a compiled instruction from the wire format. Empty account indices
/// or data arrays result in `null` for those fields on the decoded
/// [CompiledInstruction].
VariableSizeDecoder<CompiledInstruction> getInstructionDecoder() {
  final u8Dec = getU8Decoder();
  final shortU16Dec = getShortU16Decoder();
  final arrayDec = getArrayDecoder<int>(
    u8Dec,
    size: PrefixedArraySize(shortU16Dec),
  );
  final bytesDec = addDecoderSizePrefix(getBytesDecoder(), shortU16Dec);

  return VariableSizeDecoder<CompiledInstruction>(
    read: (bytes, offset) {
      final (programAddressIndex, o1) = u8Dec.read(bytes, offset);
      final (accountIndices, o2) = arrayDec.read(bytes, o1);
      final (data, o3) = bytesDec.read(bytes, o2);
      return (
        CompiledInstruction(
          programAddressIndex: programAddressIndex,
          accountIndices:
              accountIndices.isNotEmpty ? accountIndices : null,
          data: data.isNotEmpty ? data : null,
        ),
        o3,
      );
    },
  );
}

/// Returns a variable-size codec for [CompiledInstruction].
Codec<CompiledInstruction, CompiledInstruction> getInstructionCodec() {
  return combineCodec(getInstructionEncoder(), getInstructionDecoder());
}
