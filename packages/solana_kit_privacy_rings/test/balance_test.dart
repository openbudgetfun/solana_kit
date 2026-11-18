import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_privacy_rings/solana_kit_privacy_rings.dart';
import 'package:test/test.dart';

Uint8List _u64(int value) {
  final data = ByteData(8)..setUint64(0, value, Endian.little);
  return data.buffer.asUint8List();
}

Uint8List _frame(int encoding, int scheme, List<int> body) {
  final blob = [scheme, ...body];
  final length = ByteData(4)..setUint32(0, blob.length, Endian.little);
  return Uint8List.fromList([
    encoding,
    ...length.buffer.asUint8List(),
    ...blob,
  ]);
}

void main() {
  test('a confidential slot decrypts by output index and a proofless deposit stays in the clear', () async {
    final sender = ViewingKey.fromBytes(
      Uint8List.fromList(List.generate(32, (i) => i + 1)),
    );
    final recipient = ViewingKey.fromBytes(Uint8List(32)..[0] = 9);
    final salt = Uint8List(16)..[0] = 3;
    final plaintext = Uint8List.fromList([
      ..._u64(1),
      ..._u64(42),
      ...Uint8List(32),
      0,
      1,
      3,
      4,
      0,
      1,
      2,
      3,
      4,
    ]);
    final ciphertext = await sender.encryptSlot(
      recipientPublicKey: await recipient.publicKey(),
      plaintext: plaintext,
      salt: salt,
      slotIndex: 1,
    );
    final payload = _frame(encryptedEncoding, confidentialScheme, [
      ...await sender.publicKey(),
      ...ciphertext,
    ]);
    final wrongSlot = ShieldedTransaction(
      slot: BigInt.one,
      txSignature: getBase58Decoder().decode(Uint8List(64)..[0] = 1),
      outputSlots: [
        OutputSlot(
          viewTag: getBase58Decoder().decode(Uint8List(32)..[0] = 2),
          outputContext: OutputContext(
            treeId: 1,
            hash: getBase58Decoder().decode(Uint8List(32)..[0] = 2),
            tree: stateMerkleTree,
            leafIndex: BigInt.zero,
          ),
          payload: payload,
        ),
        OutputSlot(
          viewTag: getBase58Decoder().decode(Uint8List(32)..[0] = 2),
          outputContext: OutputContext(
            treeId: 1,
            hash: getBase58Decoder().decode(Uint8List(32)..[0] = 3),
            tree: stateMerkleTree,
            leafIndex: BigInt.one,
          ),
          payload: payload,
        ),
      ],
      messages: const [],
      nullifiers: const [],
      proofless: false,
      txViewingPk: await sender.publicKey(),
      salt: salt,
    );
    final confidential = await readConfidentialNotes(
      viewingKey: recipient,
      transactions: [wrongSlot],
    );
    expect(confidential.notes, hasLength(1));
    expect(confidential.notes.single.amount, BigInt.from(42));
    expect(confidential.notes.single.mint, solMint);
    expect(confidential.skipped, 1);

    final depositBody = Uint8List.fromList([
      ...Uint8List(32),
      ...Uint8List(32),
      ...getAddressEncoder().encode(solMint),
      ..._u64(9),
      0,
      0,
      0,
      0,
      0,
      0,
    ]);
    final deposit = EncryptedUtxoMatch(
      slot: BigInt.one,
      txSignature: wrongSlot.txSignature,
      outputSlot: OutputSlot(
        viewTag: wrongSlot.outputSlots.first.viewTag,
        outputContext: wrongSlot.outputSlots.first.outputContext,
        payload: _frame(plaintextEncoding, prooflessScheme, depositBody),
      ),
    );
    final encrypted = EncryptedUtxoMatch(
      slot: BigInt.one,
      txSignature: wrongSlot.txSignature,
      txViewingPk: await sender.publicKey(),
      salt: salt,
      outputSlot: deposit.outputSlot,
    );
    final proofless = await readProoflessDeposits([deposit, encrypted]);
    expect(proofless.notes.single.amount, BigInt.from(9));
    expect(proofless.skipped, 1);
    final combined = combineBalanceReports(confidential, proofless);
    expect(
      combined.balances
          .singleWhere((balance) => balance.mint == solMint)
          .amount,
      BigInt.from(51),
    );
  });
}
