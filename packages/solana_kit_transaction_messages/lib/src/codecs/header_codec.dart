import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import 'package:solana_kit_transaction_messages/src/compiled_transaction_message.dart';

/// Returns a fixed-size encoder for [MessageHeader].
///
/// The header is encoded as three consecutive u8 values:
/// - numSignerAccounts
/// - numReadonlySignerAccounts
/// - numReadonlyNonSignerAccounts
FixedSizeEncoder<MessageHeader> getMessageHeaderEncoder() {
  final u8Enc = getU8Encoder();
  return FixedSizeEncoder<MessageHeader>(
    fixedSize: 3,
    write: (value, bytes, offset) {
      var pos = offset;
      pos = u8Enc.write(value.numSignerAccounts, bytes, pos);
      pos = u8Enc.write(value.numReadonlySignerAccounts, bytes, pos);
      pos = u8Enc.write(value.numReadonlyNonSignerAccounts, bytes, pos);
      return pos;
    },
  );
}

/// Returns a fixed-size decoder for [MessageHeader].
///
/// Decodes three consecutive u8 values into a [MessageHeader].
FixedSizeDecoder<MessageHeader> getMessageHeaderDecoder() {
  final u8Dec = getU8Decoder();
  return FixedSizeDecoder<MessageHeader>(
    fixedSize: 3,
    read: (bytes, offset) {
      final (numSignerAccounts, o1) = u8Dec.read(bytes, offset);
      final (numReadonlySignerAccounts, o2) = u8Dec.read(bytes, o1);
      final (numReadonlyNonSignerAccounts, o3) = u8Dec.read(bytes, o2);
      return (
        MessageHeader(
          numSignerAccounts: numSignerAccounts,
          numReadonlySignerAccounts: numReadonlySignerAccounts,
          numReadonlyNonSignerAccounts: numReadonlyNonSignerAccounts,
        ),
        o3,
      );
    },
  );
}

/// Returns a fixed-size codec for [MessageHeader].
FixedSizeCodec<MessageHeader, MessageHeader> getMessageHeaderCodec() {
  return combineCodec(getMessageHeaderEncoder(), getMessageHeaderDecoder())
      as FixedSizeCodec<MessageHeader, MessageHeader>;
}
