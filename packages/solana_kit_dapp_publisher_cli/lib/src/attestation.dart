import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_signer.dart';
import 'package:solana_kit_dapp_publisher_cli/src/workflow_client.dart';

/// Creates an attestation payload using block data from [getBlockData].
Future<PublicationAttestation> createAttestationPayloadFromClient(
  PublicationAttestationClient getBlockData,
  PublicationSigner signer, {
  String Function()? requestIdGenerator,
}) async {
  final blockData = await getBlockData();
  return createAttestationPayload(
    blockData,
    signer,
    requestIdGenerator: requestIdGenerator,
  );
}

/// Builds and signs an attestation payload for [blockData].
///
/// The payload is `base64(signature || attestationJson)` where the attestation
/// JSON declares the block slot, blockhash, and a unique request id.
Future<PublicationAttestation> createAttestationPayload(
  ({num slot, String blockhash}) blockData,
  PublicationSigner signer, {
  String Function()? requestIdGenerator,
}) async {
  final requestUniqueId = (requestIdGenerator ?? createRequestUniqueId)();
  final attestationJson = _attestationJson(
    slot: blockData.slot,
    blockhash: blockData.blockhash,
    requestUniqueId: requestUniqueId,
  );
  final attestationBytes = _utf8(attestationJson);

  final signedMessage = await signer.signMessage(attestationBytes);
  final payloadBytes = signedMessage.length == 64
      ? (Uint8List(64 + attestationBytes.length)
          ..setRange(0, 64, signedMessage)
          ..setRange(64, 64 + attestationBytes.length, attestationBytes))
      : signedMessage;
  final signature = payloadBytes.length >= 64
      ? Uint8List.sublistView(payloadBytes, 0, 64)
      : payloadBytes;
  if (signature.length != 64) {
    throw PublisherCliException(
      'Invalid signature length: expected 64, got ${signature.length}',
    );
  }

  final payload = base64Encode(payloadBytes);
  return PublicationAttestation(
    payload: payload,
    attestationPayload: payload,
    requestUniqueId: requestUniqueId,
    slotNumber: blockData.slot,
    blockhash: blockData.blockhash,
  );
}

/// Serializes the attestation with the exact upstream field order.
String _attestationJson({
  required num slot,
  required String blockhash,
  required String requestUniqueId,
}) =>
    '{"slot_number":$slot,"blockhash":"$blockhash",'
    '"request_unique_id":"$requestUniqueId"}';

/// UTF-8 encodes [value].
Uint8List _utf8(String value) => Uint8List.fromList(_utf8CodeUnits(value));

/// The UTF-8 code units of [value].
List<int> _utf8CodeUnits(String value) => utf8.encode(value);

/// Generates a 32-digit request unique identifier.
String createRequestUniqueId() {
  const length = 32;
  const charset = '0123456789';
  final random = Random.secure();
  return List.generate(
    length,
    (_) => charset[random.nextInt(charset.length)],
  ).join();
}
