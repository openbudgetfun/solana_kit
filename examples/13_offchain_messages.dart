// ignore_for_file: avoid_print
/// Example 13: Create and encode offchain messages (SIWS / sign-in with Solana).
///
/// Offchain messages let wallets sign arbitrary text for authentication without
/// broadcasting a transaction.  This example shows [OffchainMessageV0],
/// [OffchainMessageV1], and their codec round-trips.
///
/// Run:
///   dart examples/13_offchain_messages.dart
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_offchain_messages/solana_kit_offchain_messages.dart';

void main() {
  // ── 1. Define signatories ─────────────────────────────────────────────────
  // OffchainMessageSignatory wraps a Solana address.
  const signatoryAddr = Address('9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g');
  const signatory = OffchainMessageSignatory(address: signatoryAddr);

  // ── 2. Build a v0 message ─────────────────────────────────────────────────
  // V0 messages include an application domain (a 32-byte address), a format
  // specifier, and the text content.
  //
  // OffchainMessageApplicationDomain is a typedef for Address.
  const domain = OffchainMessageApplicationDomain(
    '11111111111111111111111111111111', // system program as the app domain
  );

  final textContent = OffchainMessageContent(
    format: OffchainMessageContentFormat.restrictedAscii1232BytesMax,
    text: 'Sign in to MyDApp',
  );

  final v0 = OffchainMessageV0(
    applicationDomain: domain,
    content: textContent,
    requiredSignatories: [signatory],
  );

  print('OffchainMessageV0 version: ${v0.version}');
  print('Required signatories: ${v0.requiredSignatories.length}');
  print('Content text: ${v0.content.text}');
  print('Format: ${v0.content.format}');

  // ── 3. Compile to envelope bytes ──────────────────────────────────────────
  // compileOffchainMessageEnvelope produces an OffchainMessageEnvelope that
  // holds the serialised bytes and an (unsigned) signatures map.
  final envelope = compileOffchainMessageEnvelope(v0);
  print('\nEnvelope content bytes: ${envelope.content.length}');
  print('Signature slots: ${envelope.signatures.length}');

  // ── 4. Encode envelope with codec ─────────────────────────────────────────
  final encodedBytes = getOffchainMessageEnvelopeCodec().encode(envelope);
  print('Fully encoded size: ${encodedBytes.length} bytes');

  // ── 5. V1 message (simpler – just text and signatories, no domain) ────────
  final v1 = OffchainMessageV1(
    content: 'A longer message that requires the v1 format.',
    requiredSignatories: [signatory],
  );

  print('\nOffchainMessageV1 version: ${v1.version}');
  print('Content: ${v1.content}');

  final v1Envelope = compileOffchainMessageEnvelope(v1);
  final v1Encoded = getOffchainMessageEnvelopeCodec().encode(v1Envelope);
  print('V1 encoded size: ${v1Encoded.length} bytes');

  // ── 6. Decode back ────────────────────────────────────────────────────────
  final decoded = getOffchainMessageEnvelopeCodec().decode(encodedBytes);
  print('\nDecoded content bytes: ${decoded.content.length}');
}
