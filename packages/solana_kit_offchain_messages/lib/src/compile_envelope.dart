import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_offchain_messages/src/codecs/message_v0.dart';
import 'package:solana_kit_offchain_messages/src/codecs/message_v1.dart';
import 'package:solana_kit_offchain_messages/src/envelope.dart';
import 'package:solana_kit_offchain_messages/src/message.dart';

/// Returns an [OffchainMessageEnvelope] for the given [OffchainMessage].
///
/// The envelope includes the compiled bytes and a signatures map with `null`
/// entries for each required signatory.
OffchainMessageEnvelope compileOffchainMessageEnvelope(
  OffchainMessage offchainMessage,
) {
  return switch (offchainMessage) {
    OffchainMessageV0() => compileOffchainMessageV0Envelope(offchainMessage),
    OffchainMessageV1() => compileOffchainMessageV1Envelope(offchainMessage),
  };
}

/// Returns an [OffchainMessageEnvelope] for the given [OffchainMessageV0].
OffchainMessageEnvelope compileOffchainMessageV0Envelope(
  OffchainMessageV0 offchainMessage,
) {
  final encoder = getOffchainMessageV0Encoder();
  final content = encoder.encode(offchainMessage);
  final signatures = <Address, SignatureBytes?>{};
  for (final signatory in offchainMessage.requiredSignatories) {
    signatures[signatory.address] = null;
  }
  return OffchainMessageEnvelope(
    content: content,
    signatures: Map<Address, SignatureBytes?>.unmodifiable(signatures),
  );
}

/// Returns an [OffchainMessageEnvelope] for the given [OffchainMessageV1].
OffchainMessageEnvelope compileOffchainMessageV1Envelope(
  OffchainMessageV1 offchainMessage,
) {
  final encoder = getOffchainMessageV1Encoder();
  final content = encoder.encode(offchainMessage);
  final signatures = <Address, SignatureBytes?>{};
  for (final signatory in offchainMessage.requiredSignatories) {
    signatures[signatory.address] = null;
  }
  return OffchainMessageEnvelope(
    content: content,
    signatures: Map<Address, SignatureBytes?>.unmodifiable(signatures),
  );
}
